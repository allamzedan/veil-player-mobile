import 'dart:async';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:veil_mobile/core/subtitles/subtitle_parser.dart';
import 'package:veil_mobile/features/player/application/subtitle_settings_provider.dart';
import 'package:veil_mobile/core/recovery/recovery_provider.dart';
import 'package:veil_mobile/core/storage/media_history_models.dart';
import 'package:veil_mobile/core/storage/media_history_storage_service.dart';
import 'package:veil_mobile/core/storage/storage_providers.dart';
import 'package:veil_mobile/core/veil/veil_segment.dart';
import 'package:veil_mobile/core/veil/veil_segment_type.dart';
import 'package:veil_mobile/core/veil/veil_track.dart';
import 'package:veil_mobile/core/veil/veil_track_codec.dart';
import 'package:veil_mobile/core/veil/veil_track_validator.dart';
import 'package:veil_mobile/features/player/application/player_runtime_controller.dart';
import 'package:veil_mobile/features/player/application/player_setup_state.dart';
import 'package:veil_mobile/features/player/application/video_source_loader.dart';
import 'package:veil_mobile/features/track_builder/application/track_builder_controller.dart';
import 'package:veil_mobile/shared/constants/app_strings.dart';
import 'package:veil_mobile/shared/utils/local_file_access.dart';
import 'package:veil_mobile/shared/utils/platform_video_path_resolver.dart';
import 'package:veil_mobile/shared/utils/storage_write_guard.dart';
import 'package:veil_mobile/shared/utils/veil_error_messages.dart';
import 'package:veil_mobile/shared/utils/veil_json_file_picker.dart';
import 'package:veil_mobile/shared/utils/veil_track_file_export.dart';
import 'package:veil_mobile/shared/utils/video_file_limits.dart';
import 'package:video_player/video_player.dart';

/// Parsed VEIL track file picked from the device (not yet loaded into player state).
class PickedVeilTrackFile {
  const PickedVeilTrackFile({
    required this.content,
    required this.track,
    required this.filename,
    this.path,
  });

  final String content;
  final VeilTrack track;
  final String? path;
  final String filename;
}

final playerSetupControllerProvider =
    NotifierProvider<PlayerSetupController, PlayerSetupState>(
      PlayerSetupController.new,
    );

class ResumeSessionResult {
  const ResumeSessionResult({
    required this.success,
    this.message,
    this.warning,
  });

  final bool success;
  final String? message;
  final String? warning;
}

class SubtitlePickResult {
  const SubtitlePickResult({required this.success, required this.message});

  final bool success;
  final String message;
}

class PlayerSetupController extends Notifier<PlayerSetupState> {
  static const _uuid = Uuid();
  static const int _duplicateOffsetMs = 1000;

  VideoPlayerController? _videoController;
  Future<void> Function()? _revokeVideoResource;

  VideoPlayerController? get videoController =>
      state.isVideoReady ? _videoController : null;

  MediaHistoryStorageService get _history =>
      ref.read(mediaHistoryStorageServiceProvider);

  @override
  PlayerSetupState build() {
    ref.onDispose(_disposeVideo);
    return const PlayerSetupState();
  }

  Future<void> pickVideo() async {
    await _disposeVideo();
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearWarnings: true,
      videoPlaybackStatus: PlayerVideoPlaybackStatus.loading,
      clearVideoUnavailable: true,
    );

    try {
      final result = await FilePicker.pickFiles(
        type: FileType.video,
        allowMultiple: false,
        withData: false,
      );

      if (result == null || result.files.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          videoPlaybackStatus: PlayerVideoPlaybackStatus.none,
        );
        return;
      }

      final file = result.files.single;
      final resolved = await resolvePlatformVideoPath(file);
      if (!resolved.isSuccess) {
        state = state.copyWith(
          isLoading: false,
          clearVideo: true,
          errorMessage:
              resolved.errorMessage ??
              AppStrings.playerVideoPlaybackUnavailable,
          isReadyForPlayback: false,
          videoPlaybackStatus: PlayerVideoPlaybackStatus.none,
        );
        return;
      }

      final error = await openVideoFromPath(
        path: resolved.path!,
        filename: file.name,
        size: resolved.sizeBytes ?? file.size,
      );
      if (error != null) {
        state = state.copyWith(
          isLoading: false,
          clearVideo: true,
          errorMessage: error,
          isReadyForPlayback: false,
          videoPlaybackStatus: PlayerVideoPlaybackStatus.none,
        );
      }
    } on Object catch (error) {
      await _disposeVideo();
      state = state.copyWith(
        isLoading: false,
        clearVideo: true,
        errorMessage: VeilErrorMessages.fromException(error),
        isReadyForPlayback: false,
        videoPlaybackStatus: PlayerVideoPlaybackStatus.none,
      );
    }
  }

  Future<String?> openVideoFromPath({
    required String path,
    required String filename,
    int? size,
    Duration? initialPosition,
  }) async {
    if (path.trim().isEmpty) {
      return AppStrings.mediaHistorySourceUnavailable;
    }
    if (!localFileExists(path)) {
      return AppStrings.mediaHistorySourceMissing(filename);
    }

    final effectiveSize = size ?? await localVideoFileSize(path);
    if (!VideoFileLimits.isWithinLimit(effectiveSize)) {
      return AppStrings.playerVideoTooLarge(effectiveSize ?? size ?? 0);
    }

    await _disposeVideo();
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearWarnings: true,
      clearTrack: true,
      clearSubtitle: true,
      selectedVideoName: filename,
      selectedVideoPath: path,
      selectedVideoSize: effectiveSize ?? size,
      videoPlaybackStatus: PlayerVideoPlaybackStatus.loading,
      clearVideoUnavailable: true,
    );

    final videoResult = await loadVideoFromPath(path);
    _revokeVideoResource = videoResult.revokeOnDispose;

    if (videoResult.controller == null) {
      state = state.copyWith(
        isLoading: false,
        videoPlaybackStatus: PlayerVideoPlaybackStatus.unavailable,
        videoUnavailableMessage:
            videoResult.unavailableMessage ??
            AppStrings.playerVideoPlaybackUnavailable,
      );
      validatePairing();
      return state.videoUnavailableMessage;
    }

    _videoController = videoResult.controller;
    await _videoController!.setPlaybackSpeed(state.playbackSpeed);

    if (initialPosition != null && initialPosition > Duration.zero) {
      await _videoController!.seekTo(initialPosition);
    }

    state = state.copyWith(
      isLoading: false,
      videoPlaybackStatus: PlayerVideoPlaybackStatus.ready,
      clearVideoUnavailable: true,
      videoRevision: state.videoRevision + 1,
    );
    validatePairing();
    await _recordVideoOpened(filename: filename, path: path, size: size);
    return null;
  }

  /// Picks and parses a VEIL JSON file without loading it into player state.
  Future<PickedVeilTrackFile?> pickVeilTrackFile() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final picked = await VeilJsonFilePicker.pickJsonFile();
      if (picked == null) {
        state = state.copyWith(isLoading: false);
        return null;
      }

      final track = VeilTrackCodec.decode(picked.content);
      state = state.copyWith(isLoading: false);
      return PickedVeilTrackFile(
        content: picked.content,
        track: track,
        path: picked.path,
        filename: picked.name ?? 'track.json',
      );
    } on Object catch (error) {
      state = state.copyWith(
        isLoading: false,
        clearTrack: true,
        errorMessage: VeilErrorMessages.fromException(error),
        isReadyForPlayback: false,
      );
      return null;
    }
  }

  /// Loads a previously parsed VEIL track file into player state.
  Future<String?> loadPickedVeilTrack(PickedVeilTrackFile picked) {
    return loadTrackFromContent(
      content: picked.content,
      path: picked.path,
      filename: picked.filename,
    );
  }

  /// Appends a quick-action segment at the current playback position.
  ///
  /// Returns `null` on success, or an error message when the action cannot run.
  String? addQuickSegment({
    required VeilSegmentType type,
    Duration? duration,
    int? startMs,
    int? endMs,
    Map<String, dynamic>? maskRect,
  }) {
    if (!state.isVideoReady) {
      return AppStrings.playerQuickActionRequiresVideo;
    }

    final controller = _videoController;
    final resolvedStart =
        startMs ?? controller?.value.position.inMilliseconds ?? 0;

    final int resolvedEnd;
    if (endMs != null) {
      resolvedEnd = endMs;
    } else if (duration != null) {
      final durationMs = duration.inMilliseconds;
      if (durationMs <= 0) {
        return AppStrings.playerQuickInvalidDuration;
      }
      resolvedEnd = resolvedStart + durationMs;
    } else {
      return AppStrings.playerQuickInvalidDuration;
    }

    if (resolvedEnd <= resolvedStart) {
      return AppStrings.segmentEditorInvalidTiming;
    }

    var track = state.selectedTrack ?? _createDraftTrackForVideo();
    final segment = VeilSegment.quickAction(
      type: type,
      startMs: resolvedStart,
      endMs: resolvedEnd,
      maskRect: maskRect,
    );

    track = track
        .copyWith(
          segments: [...track.segments, segment],
          videoName: track.videoName ?? state.selectedVideoName,
        )
        .touchUpdated();

    final title = track.title.trim().isEmpty
        ? _defaultTrackTitle()
        : track.title.trim();

    state = state.copyWith(
      selectedTrack: track,
      selectedTrackTitle: title,
      hasUnsavedTrackChanges: true,
      clearError: true,
    );
    validatePairing();
    _schedulePlayerAutosave();
    return null;
  }

  /// Appends a bookmark at the current playback position (informational only).
  String? addQuickBookmark({
    required String title,
    String? note,
    int? positionMs,
  }) {
    if (!state.isVideoReady) {
      return AppStrings.playerQuickActionRequiresVideo;
    }

    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      return AppStrings.bookmarkTitleRequired;
    }

    final controller = _videoController;
    final point = positionMs ?? controller?.value.position.inMilliseconds ?? 0;

    var track = state.selectedTrack ?? _createDraftTrackForVideo();
    final segment = VeilSegment.bookmark(
      positionMs: point,
      title: trimmedTitle,
      note: note,
    );

    track = track
        .copyWith(
          segments: [...track.segments, segment],
          videoName: track.videoName ?? state.selectedVideoName,
        )
        .touchUpdated();

    final resolvedTitle = track.title.trim().isEmpty
        ? _defaultTrackTitle()
        : track.title.trim();

    state = state.copyWith(
      selectedTrack: track,
      selectedTrackTitle: resolvedTitle,
      hasUnsavedTrackChanges: true,
      clearError: true,
    );
    validatePairing();
    _schedulePlayerAutosave();
    return null;
  }

  List<VeilSegment> get sortedSegments {
    final segments = state.selectedTrack?.segments ?? const [];
    return [...segments]..sort((a, b) => a.startMs.compareTo(b.startMs));
  }

  bool deleteSegment(String segmentId) {
    final track = state.selectedTrack;
    if (track == null) {
      return false;
    }

    final segments = track.segments.where((s) => s.id != segmentId).toList();
    if (segments.length == track.segments.length) {
      return false;
    }

    _commitTrack(track.copyWith(segments: segments));
    return true;
  }

  VeilSegment? duplicateSegment(String segmentId) {
    final track = state.selectedTrack;
    if (track == null) {
      return null;
    }

    final index = track.segments.indexWhere((s) => s.id == segmentId);
    if (index < 0) {
      return null;
    }

    final source = track.segments[index];
    final duplicate = source.copyWith(
      id: _uuid.v4(),
      startMs: source.startMs + _duplicateOffsetMs,
      endMs: source.endMs + _duplicateOffsetMs,
    );
    if (!duplicate.hasValidTiming) {
      return null;
    }

    _commitTrack(track.copyWith(segments: [...track.segments, duplicate]));
    return duplicate;
  }

  bool updateSegment(VeilSegment segment) {
    if (!segment.hasValidTiming) {
      return false;
    }

    final track = state.selectedTrack;
    if (track == null) {
      return false;
    }

    final index = track.segments.indexWhere((s) => s.id == segment.id);
    if (index < 0) {
      return false;
    }

    final segments = [...track.segments];
    segments[index] = segment;
    _commitTrack(track.copyWith(segments: segments));
    return true;
  }

  bool setSegmentEnabled(String segmentId, bool enabled) {
    final track = state.selectedTrack;
    if (track == null) {
      return false;
    }

    final index = track.segments.indexWhere((s) => s.id == segmentId);
    if (index < 0) {
      return false;
    }

    final segments = [...track.segments];
    segments[index] = segments[index].copyWith(enabled: enabled);
    _commitTrack(track.copyWith(segments: segments));
    return true;
  }

  Future<void> jumpToSegmentStart(String segmentId) async {
    final track = state.selectedTrack;
    if (track == null) {
      return;
    }

    final index = track.segments.indexWhere((s) => s.id == segmentId);
    if (index < 0) {
      return;
    }

    final segment = track.segments[index];
    pausePlayback();
    await seekTo(Duration(milliseconds: segment.startMs));
  }

  void _commitTrack(VeilTrack track) {
    state = state.copyWith(
      selectedTrack: track.touchUpdated(),
      hasUnsavedTrackChanges: true,
      clearError: true,
    );
    validatePairing();
    _schedulePlayerAutosave();
  }

  void clearStorageSnack() {
    if (state.storageSnackMessage == null) {
      return;
    }
    state = state.copyWith(clearStorageSnack: true);
  }

  void _schedulePlayerAutosave() {
    unawaited(() async {
      final saved = await ref
          .read(recoveryControllerProvider.notifier)
          .autosavePlayer();
      if (!saved) {
        _reportStorageWriteFailure();
      }
    }());
  }

  void _reportStorageWriteFailure() {
    state = state.copyWith(
      storageSnackMessage: AppStrings.storageWriteFailedKeepVideoOpen,
    );
  }

  /// Restores a track from a local recovery draft (marks unsaved).
  Future<String?> restoreTrackFromRecovery({
    required String content,
    required String title,
  }) async {
    try {
      final track = VeilTrackCodec.decode(content);
      state = state.copyWith(
        selectedTrack: track,
        selectedTrackTitle: title.trim().isEmpty
            ? AppStrings.untitledVeilTrack
            : title.trim(),
        selectedTrackPath: null,
        selectedTrackFileName: null,
        hasUnsavedTrackChanges: true,
        clearError: true,
        clearWarnings: true,
      );
      validatePairing();
      return null;
    } on Object catch (error) {
      return VeilErrorMessages.fromException(error);
    }
  }

  void markTrackExported() {
    state = state.copyWith(hasUnsavedTrackChanges: false);
    unawaited(ref.read(recoveryControllerProvider.notifier).clearPlayerDraft());
  }

  String? exportActiveTrackJson() {
    final track = state.selectedTrack;
    if (track == null || track.segments.isEmpty) {
      return null;
    }
    return VeilTrackCodec.encode(_trackEnrichedForExport(track));
  }

  VeilTrack _trackEnrichedForExport(VeilTrack track) {
    final controller = _videoController;
    final initialized = controller != null && controller.value.isInitialized;

    final videoName = state.selectedVideoName ?? track.videoName;
    final durationSeconds = initialized
        ? controller.value.duration.inMilliseconds / 1000.0
        : (track.videoDurationSeconds ?? 0.0);
    final width = initialized
        ? controller.value.size.width.round()
        : (track.videoWidth ?? 0);
    final height = initialized
        ? controller.value.size.height.round()
        : (track.videoHeight ?? 0);
    final fileSize = state.selectedVideoSize ?? track.videoFileSize ?? 0;

    return track.copyWith(
      videoName: videoName,
      videoDurationSeconds: durationSeconds,
      videoFileSize: fileSize,
      videoWidth: width,
      videoHeight: height,
    );
  }

  String suggestedExportFileName() {
    return veilTrackExportFileName(
      trackTitle: state.selectedTrackTitle ?? state.selectedTrack?.title,
    );
  }

  void pausePlayback() {
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }
    if (controller.value.isPlaying) {
      controller.pause();
    }
  }

  void handoffActiveTrackToBuilder() {
    final track = state.selectedTrack;
    if (track == null) {
      return;
    }
    ref.read(trackBuilderControllerProvider.notifier).loadTrackDraft(track);
  }

  Future<void> clearVideo() async {
    await _disposeVideo();
    state = state.copyWith(
      clearVideo: true,
      clearSubtitle: true,
      clearWarnings: true,
      clearError: true,
      clearVideoUnavailable: true,
    );
    validatePairing();
  }

  void clearTrack() {
    state = state.copyWith(
      clearTrack: true,
      clearWarnings: true,
      clearError: true,
      hasUnsavedTrackChanges: false,
    );
    validatePairing();
    unawaited(ref.read(recoveryControllerProvider.notifier).clearPlayerDraft());
  }

  void togglePlayPause() {
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }
  }

  Future<void> seekTo(Duration position) async {
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }
    await controller.seekTo(position);
    await ref
        .read(playerRuntimeControllerProvider.notifier)
        .reconcileAfterSeek();
  }

  Future<void> seekRelative(Duration offset) async {
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }
    final duration = controller.value.duration;
    var target = controller.value.position + offset;
    if (target < Duration.zero) {
      target = Duration.zero;
    } else if (target > duration) {
      target = duration;
    }
    await controller.seekTo(target);
  }

  Future<void> setPlaybackSpeed(double speed) async {
    state = state.copyWith(playbackSpeed: speed);
    final controller = _videoController;
    if (controller != null && controller.value.isInitialized) {
      await controller.setPlaybackSpeed(speed);
    }
  }

  Future<SubtitlePickResult?> pickSubtitleFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['srt', 'vtt'],
      allowMultiple: false,
      withData: false,
    );
    if (result == null || result.files.isEmpty) {
      return null;
    }

    final file = result.files.single;
    final content = await _readSubtitleContent(file);
    if (content == null) {
      return SubtitlePickResult(
        success: false,
        message: AppStrings.playerSubtitleLoadError,
      );
    }

    return _applySubtitleContent(
      content: content,
      filename: file.name,
      path: file.path,
    );
  }

  Future<SubtitlePickResult?> loadSubtitleFromPath({
    required String path,
    String? filename,
    bool? enabled,
  }) async {
    if (!localFileExists(path)) {
      return SubtitlePickResult(
        success: false,
        message: AppStrings.mediaHistorySourceMissing(filename ?? path),
      );
    }

    final content = await readLocalTextFile(path);
    if (content == null) {
      return SubtitlePickResult(
        success: false,
        message: AppStrings.playerSubtitleLoadError,
      );
    }

    return _applySubtitleContent(
      content: content,
      filename: filename ?? _basename(path),
      path: path,
      enabled: enabled,
    );
  }

  Future<SubtitlePickResult> _applySubtitleContent({
    required String content,
    required String filename,
    String? path,
    bool? enabled,
  }) async {
    try {
      final cues = SubtitleParser.parse(content, filename: filename);
      if (cues.isEmpty) {
        return SubtitlePickResult(
          success: false,
          message: AppStrings.playerSubtitleEmpty,
        );
      }

      state = state.copyWith(
        selectedSubtitleName: filename,
        selectedSubtitlePath: path,
        subtitleCues: cues,
        subtitlesEnabled: enabled ?? true,
        clearActiveSubtitle: true,
      );
      _syncActiveSubtitleForCurrentPosition();

      return SubtitlePickResult(
        success: true,
        message: AppStrings.playerSubtitleLoaded(cues.length),
      );
    } on Object {
      return SubtitlePickResult(
        success: false,
        message: AppStrings.playerSubtitleLoadError,
      );
    }
  }

  Future<String?> _readSubtitleContent(PlatformFile file) async {
    final path = file.path;
    if (path != null && path.isNotEmpty) {
      return readLocalTextFile(path);
    }
    if (file.bytes != null && file.bytes!.isNotEmpty) {
      return utf8.decode(file.bytes!, allowMalformed: true);
    }
    return null;
  }

  void toggleSubtitles() {
    if (!state.hasSubtitleFile) {
      return;
    }
    final enabled = !state.subtitlesEnabled;
    state = state.copyWith(
      subtitlesEnabled: enabled,
      clearActiveSubtitle: !enabled,
    );
    if (enabled) {
      _syncActiveSubtitleForCurrentPosition();
    }
  }

  void clearSubtitles() {
    state = state.copyWith(clearSubtitle: true);
  }

  void syncActiveSubtitle(int positionMs) {
    if (!state.subtitlesEnabled || state.subtitleCues.isEmpty) {
      if (state.activeSubtitleText != null) {
        state = state.copyWith(clearActiveSubtitle: true);
      }
      return;
    }

    final settings = ref.read(subtitleSettingsProvider);
    final effectiveMs = settings.effectivePositionMs(positionMs);
    final text = SubtitleEvaluator.activeTextAt(
      state.subtitleCues,
      effectiveMs,
    );
    if (text == state.activeSubtitleText) {
      return;
    }
    state = state.copyWith(
      activeSubtitleText: text,
      clearActiveSubtitle: text == null,
    );
  }

  void resyncSubtitleAtCurrentPosition() {
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }
    final positionMs = controller.value.position.inMilliseconds;
    if (!state.subtitlesEnabled || state.subtitleCues.isEmpty) {
      return;
    }
    final settings = ref.read(subtitleSettingsProvider);
    final effectiveMs = settings.effectivePositionMs(positionMs);
    final text = SubtitleEvaluator.activeTextAt(
      state.subtitleCues,
      effectiveMs,
    );
    state = state.copyWith(
      activeSubtitleText: text,
      clearActiveSubtitle: text == null,
    );
  }

  void _syncActiveSubtitleForCurrentPosition() {
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }
    syncActiveSubtitle(controller.value.position.inMilliseconds);
  }

  /// Applies playback speed after controller init.
  Future<void> syncPlaybackSpeed() async {
    final controller = _videoController;
    if (controller != null && controller.value.isInitialized) {
      await controller.setPlaybackSpeed(state.playbackSpeed);
    }
  }

  Future<String?> loadTrackFromPath({
    required String path,
    String? filename,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    if (!localFileExists(path)) {
      state = state.copyWith(isLoading: false);
      return AppStrings.mediaHistorySourceMissing(filename ?? path);
    }
    final content = await readLocalTextFile(path);
    if (content == null) {
      state = state.copyWith(isLoading: false);
      return AppStrings.playerTrackLoadError;
    }
    return loadTrackFromContent(
      content: content,
      path: path,
      filename: filename ?? _basename(path),
    );
  }

  Future<String?> loadTrackFromContent({
    required String content,
    String? path,
    String? filename,
  }) async {
    try {
      final track = VeilTrackCodec.decode(content);
      final title = track.title.trim().isEmpty
          ? AppStrings.untitledVeilTrack
          : track.title.trim();

      state = state.copyWith(
        isLoading: false,
        selectedTrack: track,
        selectedTrackTitle: title,
        selectedTrackPath: path,
        selectedTrackFileName: filename,
        hasUnsavedTrackChanges: false,
        clearError: true,
        clearWarnings: true,
      );
      validatePairing();
      await _recordTrackOpened(
        filename: filename ?? title,
        path: path,
        segmentCount: track.segments.length,
      );
      return null;
    } on Object {
      return AppStrings.playerTrackLoadError;
    }
  }

  Future<ResumeSessionResult> resumeLastSession() async {
    final session = await _history.loadLastSession();
    if (session == null || !session.isResumable) {
      return ResumeSessionResult(
        success: false,
        message: AppStrings.lastSessionUnavailable,
      );
    }

    final videoPath = session.videoPath;
    final videoName = session.videoFilename ?? AppStrings.playerNoVideoSelected;
    if (videoPath == null || videoPath.isEmpty || !localFileExists(videoPath)) {
      return ResumeSessionResult(
        success: false,
        message: AppStrings.lastSessionVideoMissing(videoName),
      );
    }

    state = state.copyWith(isLoading: true, clearError: true);
    final videoError = await openVideoFromPath(
      path: videoPath,
      filename: videoName,
      initialPosition: Duration(milliseconds: session.playbackPositionMs),
    );
    if (videoError != null) {
      state = state.copyWith(isLoading: false, errorMessage: videoError);
      return ResumeSessionResult(success: false, message: videoError);
    }

    final warnings = <String>[];

    if (session.hasTrack) {
      final trackPath = session.trackPath;
      final trackName =
          session.trackFilename ?? AppStrings.playerNoTrackSelected;
      if (trackPath != null &&
          trackPath.isNotEmpty &&
          localFileExists(trackPath)) {
        final trackError = await loadTrackFromPath(
          path: trackPath,
          filename: session.trackFilename,
        );
        if (trackError != null) {
          warnings.add(AppStrings.lastSessionTrackMissing(trackName));
        }
      } else if (session.trackJson != null && session.trackJson!.isNotEmpty) {
        final trackError = await loadTrackFromContent(
          content: session.trackJson!,
          path: trackPath,
          filename: session.trackFilename,
        );
        if (trackError != null) {
          warnings.add(AppStrings.lastSessionTrackMissing(trackName));
        }
      } else {
        warnings.add(AppStrings.lastSessionTrackMissing(trackName));
      }
    }

    await setPlaybackSpeed(session.playbackSpeed);
    await seekTo(Duration(milliseconds: session.playbackPositionMs));

    final subtitlePath = session.subtitlePath;
    if (subtitlePath != null && subtitlePath.isNotEmpty) {
      final subtitleName =
          session.subtitleFilename ?? AppStrings.playerSubtitles;
      if (localFileExists(subtitlePath)) {
        final subtitleResult = await loadSubtitleFromPath(
          path: subtitlePath,
          filename: session.subtitleFilename,
          enabled: session.subtitlesEnabled,
        );
        if (subtitleResult != null && !subtitleResult.success) {
          warnings.add(AppStrings.lastSessionSubtitleMissing(subtitleName));
        }
      } else {
        warnings.add(AppStrings.lastSessionSubtitleMissing(subtitleName));
      }
    }

    state = state.copyWith(isLoading: false);
    return ResumeSessionResult(
      success: true,
      warning: warnings.isEmpty ? null : warnings.join('\n'),
    );
  }

  Future<void> persistPlaybackSnapshot() async {
    if (!state.isVideoReady || state.selectedVideoName == null) {
      return;
    }

    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    final positionMs = controller.value.position.inMilliseconds;
    final durationMs = controller.value.duration.inMilliseconds;

    await _safeRecordRecentVideo(
      RecentVideoEntry(
        filename: state.selectedVideoName!,
        path: state.selectedVideoPath,
        durationMs: durationMs,
        lastOpenedAt: DateTime.now().toUtc(),
        lastPlaybackPositionMs: positionMs,
      ),
    );

    await _safePersistLastSession(positionMs: positionMs);
  }

  Future<void> _recordVideoOpened({
    required String filename,
    String? path,
    int? size,
  }) async {
    final controller = _videoController;
    final durationMs = controller != null && controller.value.isInitialized
        ? controller.value.duration.inMilliseconds
        : 0;
    final positionMs = controller != null && controller.value.isInitialized
        ? controller.value.position.inMilliseconds
        : 0;

    if (size != null && state.selectedVideoSize == null) {
      state = state.copyWith(selectedVideoSize: size);
    }

    await _safeRecordRecentVideo(
      RecentVideoEntry(
        filename: filename,
        path: path,
        durationMs: durationMs,
        lastOpenedAt: DateTime.now().toUtc(),
        lastPlaybackPositionMs: positionMs,
      ),
    );
    await _safePersistLastSession(positionMs: positionMs);
  }

  Future<void> _recordTrackOpened({
    required String filename,
    String? path,
    required int segmentCount,
  }) async {
    await _safeRecordRecentTrack(
      RecentTrackEntry(
        filename: filename,
        path: path,
        lastOpenedAt: DateTime.now().toUtc(),
        segmentCount: segmentCount,
      ),
    );
    await _safePersistLastSession();
  }

  Future<void> _persistLastSession({int? positionMs}) async {
    if (state.selectedVideoName == null) {
      return;
    }

    final controller = _videoController;
    final resolvedPosition =
        positionMs ??
        (controller != null && controller.value.isInitialized
            ? controller.value.position.inMilliseconds
            : 0);
    final durationMs = controller != null && controller.value.isInitialized
        ? controller.value.duration.inMilliseconds
        : null;

    String? trackJson;
    final track = state.selectedTrack;
    if (track != null) {
      trackJson = VeilTrackCodec.encodeMobile(_trackEnrichedForExport(track));
    }

    await _safeSaveLastSession(
      LastSessionSnapshot(
        videoFilename: state.selectedVideoName,
        videoPath: state.selectedVideoPath,
        videoDurationMs: durationMs,
        trackFilename: state.selectedTrackFileName ?? state.selectedTrackTitle,
        trackPath: state.selectedTrackPath,
        trackJson: trackJson,
        subtitleFilename: state.selectedSubtitleName,
        subtitlePath: state.selectedSubtitlePath,
        subtitlesEnabled: state.subtitlesEnabled,
        playbackPositionMs: resolvedPosition,
        playbackSpeed: state.playbackSpeed,
        savedAt: DateTime.now().toUtc(),
      ),
    );
  }

  Future<void> _safeRecordRecentVideo(RecentVideoEntry entry) async {
    final saved = await StorageWriteGuard.runBool(
      () => _history.recordRecentVideo(entry),
      operation: 'recordRecentVideo',
    );
    if (!saved) {
      _reportStorageWriteFailure();
    }
  }

  Future<void> _safeRecordRecentTrack(RecentTrackEntry entry) async {
    final saved = await StorageWriteGuard.runBool(
      () => _history.recordRecentTrack(entry),
      operation: 'recordRecentTrack',
    );
    if (!saved) {
      _reportStorageWriteFailure();
    }
  }

  Future<void> _safePersistLastSession({int? positionMs}) async {
    await _persistLastSession(positionMs: positionMs);
  }

  Future<void> _safeSaveLastSession(LastSessionSnapshot session) async {
    final saved = await StorageWriteGuard.runBool(
      () => _history.saveLastSession(session),
      operation: 'saveLastSession',
    );
    if (!saved) {
      _reportStorageWriteFailure();
    }
  }

  static String _basename(String path) {
    final separator = path.contains('\\') ? '\\' : '/';
    return path.split(separator).last;
  }

  void validatePairing() {
    final warnings = <String>[];
    String? pairingError;

    if (state.selectedTrack != null) {
      if (state.selectedVideoName == null) {
        pairingError = AppStrings.playerErrorNoVideo;
      } else {
        final trackErrors = VeilTrackValidator.validate(
          state.selectedTrack!,
          forWriting: false,
        );
        if (trackErrors.isNotEmpty) {
          pairingError = AppStrings.playerErrorInvalidTrack;
          if (trackErrors.length == 1) {
            pairingError = trackErrors.first;
          }
        } else if (!_videoNamesLooselyMatch(
          state.selectedTrack!.videoName,
          state.selectedVideoName!,
        )) {
          warnings.add(AppStrings.playerWarningVideoNameMismatch);
        }
      }
    }

    final ready =
        state.isVideoReady &&
        state.selectedTrack != null &&
        pairingError == null;

    state = state.copyWith(
      validationMessages: warnings,
      errorMessage: pairingError,
      isReadyForPlayback: ready,
    );
  }

  VeilTrack _createDraftTrackForVideo() {
    return VeilTrack.empty(
      title: _defaultTrackTitle(),
    ).copyWith(videoName: state.selectedVideoName);
  }

  String _defaultTrackTitle() {
    final name = state.selectedVideoName;
    if (name == null || name.trim().isEmpty) {
      return AppStrings.untitledVeilTrack;
    }
    return _stripExtension(name);
  }

  static String _stripExtension(String fileName) {
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex > 0) {
      return fileName.substring(0, dotIndex);
    }
    return fileName;
  }

  Future<void> _disposeVideo() async {
    final controller = _videoController;
    _videoController = null;
    if (controller != null) {
      await controller.dispose();
    }
    final revoke = _revokeVideoResource;
    _revokeVideoResource = null;
    if (revoke != null) {
      await revoke();
    }
  }

  static bool _videoNamesLooselyMatch(String? trackVideoName, String fileName) {
    if (trackVideoName == null || trackVideoName.trim().isEmpty) {
      return true;
    }

    final trackNorm = _normalizeFileName(trackVideoName);
    final videoNorm = _normalizeFileName(fileName);

    if (trackNorm == videoNorm) {
      return true;
    }
    if (trackNorm.contains(videoNorm) || videoNorm.contains(trackNorm)) {
      return true;
    }
    return false;
  }

  static String _normalizeFileName(String value) {
    var name = value.trim().toLowerCase();
    final separator = name.contains('\\') ? '\\' : '/';
    if (name.contains(separator)) {
      name = name.split(separator).last;
    }
    final dotIndex = name.lastIndexOf('.');
    if (dotIndex > 0) {
      name = name.substring(0, dotIndex);
    }
    return name.replaceAll(RegExp(r'[^a-z0-9]+'), '');
  }
}
