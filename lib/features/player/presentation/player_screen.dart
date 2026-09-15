import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veil_mobile/core/veil/veil_segment.dart';
import 'package:veil_mobile/core/veil/veil_segment_type.dart';
import 'package:veil_mobile/core/veil/bookmark_segments.dart';
import 'package:veil_mobile/features/library/application/media_history_controller.dart';
import 'package:veil_mobile/features/library/application/video_folder_controller.dart';
import 'package:veil_mobile/features/player/application/player_playback_settings_provider.dart';
import 'package:veil_mobile/features/player/application/player_runtime_controller.dart';
import 'package:veil_mobile/features/player/application/player_runtime_state.dart';
import 'package:veil_mobile/features/player/application/player_setup_controller.dart';
import 'package:veil_mobile/features/player/application/player_setup_state.dart';
import 'package:veil_mobile/core/subtitles/subtitle_settings.dart';
import 'package:veil_mobile/features/player/application/subtitle_settings_provider.dart';
import 'package:veil_mobile/features/player/domain/next_video_suggestion.dart';
import 'package:veil_mobile/features/player/presentation/subtitle_settings_sheet.dart';
import 'package:veil_mobile/features/player/presentation/widgets/player_subtitle_overlay.dart';
import 'package:veil_mobile/features/player/presentation/widgets/veil_mask_overlay.dart';
import 'package:veil_mobile/features/player/application/player_display_settings_provider.dart';
import 'package:veil_mobile/features/player/presentation/widgets/player_brightness_overlay.dart';
import 'package:veil_mobile/features/player/presentation/widgets/player_bookmarks_sheet.dart';
import 'package:veil_mobile/features/player/presentation/widgets/player_end_screen_overlay.dart';
import 'package:veil_mobile/features/player/presentation/widgets/player_gesture_overlay.dart';
import 'package:veil_mobile/features/player/presentation/widgets/player_compact_toast.dart';
import 'package:veil_mobile/features/player/presentation/widgets/player_playback_controls.dart';
import 'package:veil_mobile/features/player/presentation/player_fullscreen_mode.dart';
import 'package:veil_mobile/features/player/presentation/mask_placement_screen.dart';
import 'package:veil_mobile/features/player/presentation/widgets/player_segment_editor_sheet.dart';
import 'package:veil_mobile/features/player/presentation/widgets/player_track_segments_sheet.dart';
import 'package:veil_mobile/core/tracks/track_summary.dart';
import 'package:veil_mobile/features/player/presentation/widgets/player_veil_quick_actions.dart';
import 'package:veil_mobile/features/track_builder/presentation/track_json_dialog.dart';
import 'package:veil_mobile/features/tracks/presentation/track_details_sheet.dart';
import 'package:veil_mobile/features/tracks/presentation/track_preview_dialog.dart';
import 'package:veil_mobile/shared/constants/app_strings.dart';
import 'package:veil_mobile/shared/utils/veil_track_file_export.dart';
import 'package:veil_mobile/shared/utils/video_folder_scanner.dart';
import 'package:veil_mobile/shared/widgets/app_bottom_sheet.dart';
import 'package:veil_mobile/shared/widgets/app_brand_mark.dart';
import 'package:veil_mobile/shared/widgets/app_scaffold.dart';
import 'package:veil_mobile/shared/widgets/app_snackbar.dart';
import 'package:video_player/video_player.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  const PlayerScreen({super.key});

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  bool _trackSuggestionVisible = false;
  bool _trackSuggestionDismissed = false;
  bool _trackSuggestionScheduled = false;
  Timer? _trackSuggestionTimer;
  Timer? _chromeHideTimer;
  Timer? _sessionSaveTimer;
  VideoPlayerController? _attachedController;
  bool _maskPlacementRouteOpen = false;
  bool _playerFullscreen = false;
  bool _playerChromeVisible = true;
  bool _endScreenVisible = false;
  int? _endScreenDismissedForRevision;
  static const Duration _chromeAutoHideDelay = Duration(milliseconds: 2800);
  static const Duration _sessionSaveInterval = Duration(seconds: 10);

  @override
  void initState() {
    super.initState();
    _sessionSaveTimer = Timer.periodic(_sessionSaveInterval, (_) {
      unawaited(_persistSessionSnapshot());
    });
  }

  @override
  void activate() {
    super.activate();
    _playerChromeVisible = true;
    _chromeHideTimer?.cancel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final controller = ref.read(playerSetupControllerProvider.notifier).videoController;
      _attachVideoListener(controller);
      if (controller != null && controller.value.isInitialized) {
        _syncPlaybackChrome(controller);
      }
    });
  }

  @override
  void deactivate() {
    unawaited(_exitFullscreenIfActive());
    ref.read(playerSetupControllerProvider.notifier).pausePlayback();
    unawaited(_persistSessionSnapshot(refreshHistory: true));
    super.deactivate();
  }

  @override
  void dispose() {
    unawaited(_exitFullscreenIfActive());
    ref.read(playerSetupControllerProvider.notifier).pausePlayback();
    _sessionSaveTimer?.cancel();
    unawaited(_persistSessionSnapshot(refreshHistory: true));
    _detachVideoListener();
    _trackSuggestionTimer?.cancel();
    _chromeHideTimer?.cancel();
    super.dispose();
  }

  Future<void> _persistSessionSnapshot({bool refreshHistory = false}) async {
    await ref
        .read(playerSetupControllerProvider.notifier)
        .persistPlaybackSnapshot();
    if (refreshHistory && mounted) {
      await ref.read(mediaHistoryControllerProvider.notifier).refresh();
    }
  }

  void _detachVideoListener() {
    _attachedController?.removeListener(_onVideoChanged);
    _attachedController = null;
  }

  void _attachVideoListener(VideoPlayerController? controller) {
    if (_attachedController == controller) {
      return;
    }
    _detachVideoListener();
    _attachedController = controller;
    controller?.addListener(_onVideoChanged);
  }

  void _resetTrackSuggestion() {
    _trackSuggestionTimer?.cancel();
    _trackSuggestionTimer = null;
    _trackSuggestionScheduled = false;
    _trackSuggestionVisible = false;
    _trackSuggestionDismissed = false;
  }

  void _onVideoChanged() {
    final controller = _attachedController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    _syncPlaybackChrome(controller);

    if (_detectVideoEnded(controller)) {
      _maybeShowEndScreen();
    }

    final setup = ref.read(playerSetupControllerProvider);
    if (setup.selectedTrack != null) {
      if (_trackSuggestionVisible) {
        setState(() => _trackSuggestionVisible = false);
      }
      return;
    }

    if (_trackSuggestionDismissed) {
      return;
    }

    if (controller.value.isPlaying) {
      if (!_trackSuggestionScheduled) {
        _trackSuggestionScheduled = true;
        _trackSuggestionTimer?.cancel();
        _trackSuggestionTimer = Timer(const Duration(seconds: 3), () {
          if (!mounted) {
            return;
          }
          final current = ref.read(playerSetupControllerProvider);
          if (current.isVideoReady &&
              current.selectedTrack == null &&
              (_attachedController?.value.isPlaying ?? false)) {
            setState(() => _trackSuggestionVisible = true);
          }
        });
      }
    } else {
      _trackSuggestionScheduled = false;
      _trackSuggestionTimer?.cancel();
    }
  }

  void _syncPlaybackChrome(VideoPlayerController controller) {
    final setup = ref.read(playerSetupControllerProvider);
    if (!setup.isVideoReady || _maskPlacementRouteOpen) {
      _chromeHideTimer?.cancel();
      if (!_playerChromeVisible) {
        setState(() => _playerChromeVisible = true);
      }
      return;
    }

    if (controller.value.isPlaying) {
      _scheduleChromeHide();
      return;
    }

    _chromeHideTimer?.cancel();
    if (!_playerChromeVisible) {
      setState(() => _playerChromeVisible = true);
    }
  }

  void _scheduleChromeHide() {
    _chromeHideTimer?.cancel();
    _chromeHideTimer = Timer(_chromeAutoHideDelay, () {
      if (!mounted) {
        return;
      }
      final controller = _attachedController;
      final setup = ref.read(playerSetupControllerProvider);
      if (controller == null ||
          !setup.isVideoReady ||
          !controller.value.isPlaying ||
          _maskPlacementRouteOpen) {
        return;
      }
      setState(() => _playerChromeVisible = false);
    });
  }

  bool _detectVideoEnded(VideoPlayerController controller) {
    final value = controller.value;
    if (!value.isInitialized || value.duration <= Duration.zero) {
      return false;
    }
    if (value.isPlaying) {
      return false;
    }
    return value.position >= value.duration - const Duration(milliseconds: 500);
  }

  void _maybeShowEndScreen() {
    final setup = ref.read(playerSetupControllerProvider);
    if (!setup.isVideoReady || _maskPlacementRouteOpen) {
      return;
    }
    if (_endScreenDismissedForRevision == setup.videoRevision) {
      return;
    }
    if (!_endScreenVisible && mounted) {
      setState(() {
        _endScreenVisible = true;
        _playerChromeVisible = true;
      });
      _chromeHideTimer?.cancel();
    }
  }

  void _dismissEndScreen({bool permanent = false}) {
    if (permanent) {
      _endScreenDismissedForRevision =
          ref.read(playerSetupControllerProvider).videoRevision;
    }
    if (_endScreenVisible && mounted) {
      setState(() => _endScreenVisible = false);
    }
  }

  MediaHistoryState? _readMediaHistory() {
    final state = ref.read(mediaHistoryControllerProvider);
    return switch (state) {
      AsyncData(:final value) => value,
      _ => null,
    };
  }

  NextVideoSuggestion? _resolveNextVideo() {
    final setup = ref.read(playerSetupControllerProvider);
    final history = _readMediaHistory();
    if (history == null) {
      return null;
    }

    var folderVideos = const <FolderVideoEntry>[];
    final foldersState = ref.read(videoFolderControllerProvider);
    final folders = switch (foldersState) {
      AsyncData(:final value) => value,
      _ => const <SavedVideoFolder>[],
    };
    for (final folder in folders) {
      final scan = ref
          .read(videoFolderControllerProvider.notifier)
          .scanFolder(folder.path);
      if (!scan.restricted && scan.videos.isNotEmpty) {
        folderVideos = scan.videos;
        break;
      }
    }

    return NextVideoSuggestionResolver.resolve(
      currentVideoPath: setup.selectedVideoPath,
      history: history,
      folderVideos: folderVideos,
    );
  }

  Future<void> _replayCurrentVideo() async {
    _dismissEndScreen(permanent: true);
    final ctrl = ref.read(playerSetupControllerProvider.notifier);
    await ctrl.seekTo(Duration.zero);
    final controller = ctrl.videoController;
    if (controller != null && controller.value.isInitialized) {
      await controller.play();
    }
  }

  Future<void> _playNextSuggestedVideo() async {
    final next = _resolveNextVideo();
    _dismissEndScreen(permanent: true);
    if (next == null) {
      return;
    }
    final ctrl = ref.read(playerSetupControllerProvider.notifier);
    final error = await ctrl.openVideoFromPath(
      path: next.path,
      filename: next.filename,
    );
    if (!mounted) {
      return;
    }
    if (error != null) {
      showAppSnackBar(
        context,
        error,
        isError: true,
        abovePlayerControls: true,
      );
    }
  }

  void _handleVideoSurfaceTap() {
    if (!ref.read(playerSetupControllerProvider).isVideoReady ||
        _maskPlacementRouteOpen) {
      return;
    }

    ref.read(playerSetupControllerProvider.notifier).togglePlayPause();

    if (!_playerChromeVisible) {
      setState(() => _playerChromeVisible = true);
    }

    if (_attachedController?.value.isPlaying ?? false) {
      _scheduleChromeHide();
    } else {
      _chromeHideTimer?.cancel();
    }
  }

  Future<void> _exitFullscreenIfActive() async {
    if (!_playerFullscreen) {
      return;
    }
    _playerFullscreen = false;
    await PlayerFullscreenMode.exit();
  }

  Future<void> _toggleFullscreen() async {
    if (!PlayerFullscreenMode.isSupported) {
      return;
    }
    if (!ref.read(playerSetupControllerProvider).isVideoReady) {
      return;
    }

    if (_playerFullscreen) {
      await PlayerFullscreenMode.exit();
      if (!mounted) {
        return;
      }
      setState(() {
        _playerFullscreen = false;
        _playerChromeVisible = true;
      });
      _chromeHideTimer?.cancel();
      return;
    }

    await PlayerFullscreenMode.enter();
    if (!mounted) {
      return;
    }
    setState(() {
      _playerFullscreen = true;
      _playerChromeVisible = true;
    });
    if (_attachedController?.value.isPlaying ?? false) {
      _scheduleChromeHide();
    }
  }

  void _dismissTrackSuggestion({bool permanent = false}) {
    if (permanent) {
      _trackSuggestionDismissed = true;
    }
    setState(() => _trackSuggestionVisible = false);
  }

  void _showDetailsSheet(PlayerSetupState setup, PlayerSetupController ctrl) {
    AppBottomSheet.show<void>(
      context: context,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
        child: _PlayerDetailsSheet(
          setup: setup,
          onClearVideo: setup.hasVideoSelection ? ctrl.clearVideo : null,
          onClearTrack: setup.selectedTrack != null ? ctrl.clearTrack : null,
          onChangeVideo: ctrl.pickVideo,
          onOpenBookmarks: setup.selectedTrack != null
              ? () {
                  Navigator.pop(sheetContext);
                  _openBookmarksSheet(ctrl.videoController);
                }
              : null,
          onLoadTrack: () => _pickTrackWithPreview(ctrl),
          onExportTrack:
              setup.selectedTrack != null && (setup.segmentCount ?? 0) > 0
              ? _handleExportTrack
              : null,
          onPreviewJson:
              setup.selectedTrack != null && (setup.segmentCount ?? 0) > 0
              ? _handlePreviewJson
              : null,
          onOpenSegments: _openTrackSegmentsSheet,
          onViewTrackDetails: setup.selectedTrack != null
              ? () {
                  Navigator.pop(sheetContext);
                  TrackDetailsSheet.show(
                    context: context,
                    track: setup.selectedTrack!,
                    onViewAllSegments: _openTrackSegmentsSheet,
                  );
                }
              : null,
          onOpenSubtitleSettings: () {
            Navigator.pop(sheetContext);
            _showSubtitleSettingsSheet(ctrl);
          },
        ),
      ),
    );
  }

  Future<void> _pickTrackWithPreview(PlayerSetupController ctrl) async {
    final picked = await ctrl.pickVeilTrackFile();
    if (!mounted || picked == null) {
      return;
    }

    final load = await TrackPreviewDialog.show(
      context: context,
      track: picked.track,
    );
    if (!mounted || load != true) {
      return;
    }

    final error = await ctrl.loadPickedVeilTrack(picked);
    if (!mounted) {
      return;
    }
    if (error != null) {
      showAppSnackBar(
        context,
        error,
        isError: true,
        abovePlayerControls: true,
      );
    }
  }

  Future<void> _handlePickSubtitle(PlayerSetupController ctrl) async {
    final result = await ctrl.pickSubtitleFile();
    if (!mounted || result == null) {
      return;
    }
    showAppSnackBar(
      context,
      result.message,
      isError: !result.success,
      abovePlayerControls: true,
    );
  }

  void _handleToggleSubtitles(PlayerSetupController ctrl) {
    ctrl.toggleSubtitles();
  }

  void _showSubtitleSettingsSheet(PlayerSetupController ctrl) {
    SubtitleSettingsSheet.show(
      context: context,
      hasSubtitleFile: ref.read(playerSetupControllerProvider).hasSubtitleFile,
      onPickSubtitle: () => _handlePickSubtitle(ctrl),
    );
  }

  void _handleQuickSave(VeilSegmentType type, int startMs, int endMs) {
    final ctrl = ref.read(playerSetupControllerProvider.notifier);
    final error = ctrl.addQuickSegment(
      type: type,
      startMs: startMs,
      endMs: endMs,
    );
    if (!mounted) {
      return;
    }
    if (error != null) {
      showPlayerFloatingSnackBar(context, error);
      return;
    }
    _showQuickActionAddedToast();
  }

  void _handleQuickBookmark(String title, String? note) {
    final ctrl = ref.read(playerSetupControllerProvider.notifier);
    final error = ctrl.addQuickBookmark(title: title, note: note);
    if (!mounted) {
      return;
    }
    if (error != null) {
      showPlayerFloatingSnackBar(context, error);
      return;
    }
    _showQuickActionAddedToast();
  }

  void _handleMaskQuickSave(
    int startMs,
    int endMs,
    Map<String, dynamic> maskRect,
  ) {
    final ctrl = ref.read(playerSetupControllerProvider.notifier);
    final error = ctrl.addQuickSegment(
      type: VeilSegmentType.mask,
      startMs: startMs,
      endMs: endMs,
      maskRect: maskRect,
    );
    if (!mounted) {
      return;
    }
    if (error != null) {
      showPlayerFloatingSnackBar(context, error);
      return;
    }
    _showQuickActionAddedToast();
  }

  void _showQuickActionAddedToast() {
    showPlayerCompactToast(
      context,
      message: AppStrings.playerQuickActionAdded,
      secondary: AppStrings.playerQuickActionAddedHint,
    );
  }

  Future<void> _startMaskPlacement(
    VideoPlayerController? videoController,
  ) async {
    if (videoController == null || !videoController.value.isInitialized) {
      return;
    }
    ref.read(playerSetupControllerProvider.notifier).pausePlayback();
    setState(() => _maskPlacementRouteOpen = true);

    Map<String, dynamic>? rect;
    try {
      rect = await MaskPlacementScreen.open(context, videoController);
    } finally {
      if (mounted) {
        setState(() => _maskPlacementRouteOpen = false);
      }
    }

    if (!mounted || rect == null) {
      return;
    }

    PlayerVeilQuickActions.showMaskDurationSheet(
      context: context,
      videoController: videoController,
      maskRect: rect,
      onSave: _handleMaskQuickSave,
    );
  }

  Future<void> _handleExportTrack() async {
    final ctrl = ref.read(playerSetupControllerProvider.notifier);
    final json = ctrl.exportActiveTrackJson();
    if (!mounted || json == null) {
      return;
    }

    final result = await exportVeilTrackJsonFile(
      json: json,
      fileName: ctrl.suggestedExportFileName(),
    );
    if (!mounted) {
      return;
    }

    showPlayerFloatingSnackBar(
      context,
      result.success ? result.message : AppStrings.playerExportTrackFailed,
      backgroundColor: result.success
          ? null
          : Theme.of(context).colorScheme.error,
    );
    if (result.success) {
      ctrl.markTrackExported();
    }
  }

  Future<void> _handlePreviewJson() async {
    final json = ref
        .read(playerSetupControllerProvider.notifier)
        .exportActiveTrackJson();
    if (!mounted || json == null) {
      return;
    }
    await showTrackJsonDialog(
      context: context,
      title: AppStrings.playerPreviewJson,
      json: json,
    );
  }

  void _handleOpenManualBuilder() {
    ref
        .read(playerSetupControllerProvider.notifier)
        .handoffActiveTrackToBuilder();
  }

  void _openBookmarksSheet(VideoPlayerController? videoController) {
    final setup = ref.read(playerSetupControllerProvider);
    final ctrl = ref.read(playerSetupControllerProvider.notifier);

    PlayerBookmarksSheet.show(
      context: context,
      track: setup.selectedTrack,
      onSeek: ctrl.seekTo,
      onEdit: (segment) => _editSegment(segment, videoController),
      onDelete: _confirmDeleteSegment,
    );
  }

  void _openTrackSegmentsSheet() {
    final setup = ref.read(playerSetupControllerProvider);
    final ctrl = ref.read(playerSetupControllerProvider.notifier);
    final videoController = ctrl.videoController;

    PlayerTrackSegmentsSheet.show(
      context: context,
      ref: ref,
      canAddActions: setup.isVideoReady,
      onAddMask: () => _startMaskPlacement(videoController),
      onAddMute: () =>
          _openQuickDurationSheet(VeilSegmentType.mute, videoController),
      onAddSkip: () =>
          _openQuickDurationSheet(VeilSegmentType.skip, videoController),
      onAddBookmark: () => PlayerVeilQuickActions.showBookmarkSheet(
        context: context,
        videoController: videoController,
        canAddQuickActions: setup.isVideoReady,
        onSave: _handleQuickBookmark,
      ),
      onJumpTo: (segment) => ctrl.jumpToSegmentStart(segment.id),
      onEdit: (segment) => _editSegment(segment, videoController),
      onDuplicate: (segment) {
        ctrl.duplicateSegment(segment.id);
      },
      onDelete: (segment) => _confirmDeleteSegment(segment),
      onToggleEnabled: (segment, enabled) {
        ctrl.setSegmentEnabled(segment.id, enabled);
      },
    );
  }

  void _openQuickDurationSheet(
    VeilSegmentType type,
    VideoPlayerController? videoController,
  ) {
    PlayerVeilQuickActions.showDurationSheetForType(
      context: context,
      actionType: type,
      videoController: videoController,
      canAddQuickActions: ref.read(playerSetupControllerProvider).isVideoReady,
      onSave: (startMs, endMs) => _handleQuickSave(type, startMs, endMs),
    );
  }

  void _openVeilQuickMenu({
    required PlayerSetupState setup,
    required VideoPlayerController? videoController,
    required PlayerSetupController ctrl,
  }) {
    TrackSummary? trackSummary;
    if (setup.selectedTrack != null) {
      try {
        trackSummary = TrackSummary.fromTrack(setup.selectedTrack!);
      } on Object {
        trackSummary = null;
      }
    }

    PlayerVeilQuickActions.showMenu(
      context: context,
      videoController: videoController,
      canAddQuickActions: setup.isVideoReady,
      canExportTrack:
          setup.selectedTrack != null && (setup.segmentCount ?? 0) > 0,
      onLoadTrack: () => _pickTrackWithPreview(ctrl),
      trackSummary: trackSummary,
      onSaveQuickAction: _handleQuickSave,
      onSaveBookmark: _handleQuickBookmark,
      onStartMaskPlacement: () => _startMaskPlacement(videoController),
      onOpenSegments: _openTrackSegmentsSheet,
      onOpenBookmarks: setup.selectedTrack != null
          ? () => _openBookmarksSheet(videoController)
          : null,
      onOpenManualBuilder: _handleOpenManualBuilder,
      onExportTrack: _handleExportTrack,
      onPreviewJson: _handlePreviewJson,
    );
  }

  Future<void> _editSegment(
    VeilSegment segment,
    VideoPlayerController? videoController,
  ) async {
    await PlayerSegmentEditorSheet.show(
      context: context,
      segment: segment,
      videoController: videoController,
      onSave: (updated) {
        final ok = ref
            .read(playerSetupControllerProvider.notifier)
            .updateSegment(updated);
        if (!ok && mounted) {
          showPlayerFloatingSnackBar(
            context,
            AppStrings.segmentEditorInvalidTiming,
          );
        }
      },
    );
  }

  Future<void> _confirmDeleteSegment(VeilSegment segment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppStrings.playerSegmentDeleteTitle),
        content: Text(AppStrings.playerSegmentDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(AppStrings.delete),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    ref.read(playerSetupControllerProvider.notifier).deleteSegment(segment.id);
  }

  @override
  Widget build(BuildContext context) {
    final setup = ref.watch(playerSetupControllerProvider);
    final runtime = ref.watch(playerRuntimeControllerProvider);
    final subtitleSettings = ref.watch(subtitleSettingsProvider);
    final ctrl = ref.read(playerSetupControllerProvider.notifier);
    final videoController = ctrl.videoController;

    ref.listen(playerSetupControllerProvider, (previous, next) {
      if (previous?.videoRevision != next.videoRevision) {
        _dismissEndScreen();
        _endScreenDismissedForRevision = null;
      }
      if (!next.hasVideoSelection) {
        _resetTrackSuggestion();
        _dismissEndScreen();
        return;
      }
      if (next.selectedTrack != null && _trackSuggestionVisible) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() => _trackSuggestionVisible = false);
          }
        });
      }
    });

    ref.listen(
      playerSetupControllerProvider.select((state) => state.storageSnackMessage),
      (previous, next) {
        if (next == null || next.isEmpty || !mounted) {
          return;
        }
        showAppSnackBar(
          context,
          next,
          isError: true,
          abovePlayerControls: true,
        );
        ctrl.clearStorageSnack();
      },
    );

    _attachVideoListener(videoController);

    final inRuntime =
        setup.isVideoReady || setup.hasVideoSelection && !setup.isVideoReady;
    final immersivePlayback =
        setup.isVideoReady &&
        !_maskPlacementRouteOpen &&
        (videoController?.value.isInitialized ?? false);
    final hideShellChrome =
        _playerFullscreen || (immersivePlayback && !_playerChromeVisible);

    final playbackSettings = ref.watch(playerPlaybackSettingsProvider);
    final nextVideo = _endScreenVisible ? _resolveNextVideo() : null;

    return PopScope(
      canPop: !_playerFullscreen,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop || !_playerFullscreen) {
          return;
        }
        unawaited(_toggleFullscreen());
      },
      child: AppScaffold(
        title: AppStrings.playerTitle,
        cinemaMode: true,
        hideAppBar: hideShellChrome || inRuntime || !setup.hasVideoSelection,
        hideBottomNavigation: hideShellChrome,
        body: ColoredBox(
          color: Colors.black,
          child: Stack(
            fit: StackFit.expand,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 320),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: _PlayerViewport(
                  key: ValueKey(
                    inRuntime ? 'runtime-${setup.videoRevision}' : 'empty',
                  ),
                  setup: setup,
                  runtime: runtime,
                  videoController: videoController,
                  onOpenVideo: ctrl.pickVideo,
                  onLoadTrack: () => _pickTrackWithPreview(ctrl),
                  onTogglePlayPause: ctrl.togglePlayPause,
                  onSeek: ctrl.seekTo,
                  onSetSpeed: ctrl.setPlaybackSpeed,
                  onPickSubtitle: () => _handlePickSubtitle(ctrl),
                  onToggleSubtitles: () => _handleToggleSubtitles(ctrl),
                  onOpenSubtitleSettings: () => _showSubtitleSettingsSheet(ctrl),
                  subtitleSettings: subtitleSettings,
                  onShowDetails: () => _showDetailsSheet(setup, ctrl),
                  onVeilQuickAction: () => _openVeilQuickMenu(
                    setup: setup,
                    videoController: videoController,
                    ctrl: ctrl,
                  ),
                  hideVideoSurface: _maskPlacementRouteOpen,
                  playerChromeVisible: _playerChromeVisible,
                  onVideoSurfaceTap: _handleVideoSurfaceTap,
                  isFullscreen: _playerFullscreen,
                  onToggleFullscreen: _toggleFullscreen,
                ),
              ),
              if (_trackSuggestionVisible && _playerChromeVisible && inRuntime)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 88 + MediaQuery.paddingOf(context).bottom,
                  child: Center(
                    child: _TrackSuggestionChip(
                      onAdd: () {
                        _dismissTrackSuggestion(permanent: true);
                        _pickTrackWithPreview(ctrl);
                      },
                      onDismiss: () => _dismissTrackSuggestion(permanent: true),
                    ),
                  ),
                ),
              if (_endScreenVisible && setup.isVideoReady)
                PlayerEndScreenOverlay(
                  nextVideo: nextVideo,
                  autoplayEnabled: playbackSettings.autoplayNextVideo,
                  onReplay: () => unawaited(_replayCurrentVideo()),
                  onPlayNext: () => unawaited(_playNextSuggestedVideo()),
                  onChooseVideo: () {
                    _dismissEndScreen(permanent: true);
                    ctrl.pickVideo();
                  },
                  onDismiss: () => _dismissEndScreen(permanent: true),
                ),
              if (setup.isLoading)
                const ColoredBox(
                  color: Color(0x88000000),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayerViewport extends StatelessWidget {
  const _PlayerViewport({
    super.key,
    required this.setup,
    required this.runtime,
    required this.videoController,
    required this.onOpenVideo,
    required this.onLoadTrack,
    required this.onTogglePlayPause,
    required this.onSeek,
    required this.onSetSpeed,
    required this.onPickSubtitle,
    required this.onToggleSubtitles,
    required this.onOpenSubtitleSettings,
    required this.subtitleSettings,
    required this.onShowDetails,
    required this.onVeilQuickAction,
    this.hideVideoSurface = false,
    this.playerChromeVisible = true,
    required this.onVideoSurfaceTap,
    this.isFullscreen = false,
    required this.onToggleFullscreen,
  });

  final PlayerSetupState setup;
  final PlayerRuntimeState runtime;
  final VideoPlayerController? videoController;
  final VoidCallback onOpenVideo;
  final VoidCallback onLoadTrack;
  final VoidCallback onTogglePlayPause;
  final Future<void> Function(Duration position) onSeek;
  final ValueChanged<double> onSetSpeed;
  final VoidCallback onPickSubtitle;
  final VoidCallback onToggleSubtitles;
  final VoidCallback onOpenSubtitleSettings;
  final SubtitleSettings subtitleSettings;
  final VoidCallback onShowDetails;
  final VoidCallback onVeilQuickAction;
  final bool hideVideoSurface;
  final bool playerChromeVisible;
  final VoidCallback onVideoSurfaceTap;
  final bool isFullscreen;
  final VoidCallback onToggleFullscreen;

  bool get _isRuntime => setup.isVideoReady && videoController != null;

  bool get _hasSelection => setup.hasVideoSelection;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _MediaLayer(
          setup: setup,
          runtime: runtime,
          videoController: videoController,
          subtitleSettings: subtitleSettings,
          onSeekTo: onSeek,
          onSeekRelative: (offset) async {
            final ctrl = videoController;
            if (ctrl == null) {
              return;
            }
            final duration = ctrl.value.duration;
            var target = ctrl.value.position + offset;
            if (target < Duration.zero) {
              target = Duration.zero;
            } else if (target > duration) {
              target = duration;
            }
            await onSeek(target);
          },
          onSetPlaybackSpeed: (speed) async => onSetSpeed(speed),
          onSingleTap: _isRuntime ? onVideoSurfaceTap : null,
          hideVideoSurface: hideVideoSurface,
        ),
        if (!_isRuntime && !_hasSelection)
          _EmptyStateOverlay(
            isLoading: setup.isLoading,
            onOpenVideo: onOpenVideo,
            onLoadTrack: onLoadTrack,
          ),
        if (_hasSelection && !_isRuntime)
          _UnavailableOverlay(
            setup: setup,
            onOpenVideo: onOpenVideo,
            onShowDetails: onShowDetails,
          ),
        if (_isRuntime && videoController != null && !hideVideoSurface && playerChromeVisible)
          _RuntimeOverlay(
            setup: setup,
            runtime: runtime,
            controller: videoController!,
            chromeVisible: playerChromeVisible,
            onTogglePlayPause: onTogglePlayPause,
            onSeek: onSeek,
            onSetSpeed: onSetSpeed,
            onPickSubtitle: onPickSubtitle,
            onToggleSubtitles: onToggleSubtitles,
            onOpenSubtitleSettings: onOpenSubtitleSettings,
            onShowDetails: onShowDetails,
            onVeilQuickAction: onVeilQuickAction,
            isFullscreen: isFullscreen,
            onToggleFullscreen: onToggleFullscreen,
          ),
      ],
    );
  }
}

class _MediaLayer extends ConsumerWidget {
  const _MediaLayer({
    required this.setup,
    required this.runtime,
    required this.videoController,
    required this.subtitleSettings,
    required this.onSeekTo,
    required this.onSeekRelative,
    required this.onSetPlaybackSpeed,
    this.onSingleTap,
    this.hideVideoSurface = false,
  });

  final PlayerSetupState setup;
  final PlayerRuntimeState runtime;
  final VideoPlayerController? videoController;
  final SubtitleSettings subtitleSettings;
  final Future<void> Function(Duration position) onSeekTo;
  final Future<void> Function(Duration offset) onSeekRelative;
  final Future<void> Function(double speed) onSetPlaybackSpeed;
  final VoidCallback? onSingleTap;
  final bool hideVideoSurface;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final display = ref.watch(playerDisplaySettingsProvider);
    final controller = videoController;
    final showVideo =
        setup.isVideoReady && controller != null && !hideVideoSurface;

    final mediaStack = Stack(
      fit: StackFit.expand,
      children: [
        if (showVideo)
          Center(
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: controller.value.size.width,
                height: controller.value.size.height,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    VideoPlayer(controller),
                    PlayerSubtitleOverlay(
                      text: setup.activeSubtitleText,
                      visible: setup.subtitlesEnabled && setup.hasSubtitleFile,
                      settings: subtitleSettings,
                    ),
                    VeilMaskOverlay(segments: runtime.activeMaskSegments),
                    PlayerBrightnessOverlay(brightness: display.brightness),
                  ],
                ),
              ),
            ),
          ),
        if (!showVideo)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.15,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.5),
                  ],
                ),
              ),
            ),
          ),
      ],
    );

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF12141C), Color(0xFF050608), Color(0xFF0A0C10)],
        ),
      ),
      child: showVideo
          ? PlayerGestureOverlay(
              enabled: true,
              controller: controller,
              playbackSpeed: setup.playbackSpeed,
              volume: display.volume,
              brightness: display.brightness,
              onSeekTo: onSeekTo,
              onSeekRelative: onSeekRelative,
              onSetPlaybackSpeed: onSetPlaybackSpeed,
              onVolumeChanged: (level) {
                ref.read(playerDisplaySettingsProvider.notifier).setVolume(level);
                ref.read(playerRuntimeControllerProvider.notifier).refreshOutputVolume();
              },
              onBrightnessChanged: (level) {
                ref.read(playerDisplaySettingsProvider.notifier).setBrightness(level);
              },
              onSingleTap: onSingleTap,
              child: mediaStack,
            )
          : mediaStack,
    );
  }
}

class _EmptyStateOverlay extends StatelessWidget {
  const _EmptyStateOverlay({
    required this.isLoading,
    required this.onOpenVideo,
    required this.onLoadTrack,
  });

  final bool isLoading;
  final VoidCallback onOpenVideo;
  final VoidCallback onLoadTrack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppBrandMark(size: 56),
              const SizedBox(height: 28),
              Text(
                AppStrings.playerEmptyMediaTitle,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.92),
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.playerEmptyOpenWithHint,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.45),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),
              FilledButton.icon(
                onPressed: isLoading ? null : onOpenVideo,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(220, 52),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                ),
                icon: const Icon(Icons.play_arrow_rounded, size: 24),
                label: Text(AppStrings.playerOpenVideo),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: isLoading ? null : onLoadTrack,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white.withValues(alpha: 0.65),
                ),
                icon: Icon(
                  Icons.layers_outlined,
                  size: 18,
                  color: Colors.white.withValues(alpha: 0.65),
                ),
                label: Text(AppStrings.playerLoadVeilTrack),
              ),
              if (isLoading) ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.primary.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _UnavailableOverlay extends StatelessWidget {
  const _UnavailableOverlay({
    required this.setup,
    required this.onOpenVideo,
    required this.onShowDetails,
  });

  final PlayerSetupState setup;
  final VoidCallback onOpenVideo;
  final VoidCallback onShowDetails;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading =
        setup.videoPlaybackStatus == PlayerVideoPlaybackStatus.loading;

    return SafeArea(
      child: Stack(
        children: [
          Center(
            child: isLoading
                ? const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.videocam_off_outlined,
                          size: 40,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.35,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          setup.videoUnavailableMessage ??
                              AppStrings.playerVideoPlaybackUnavailable,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.55),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
          ),
          Positioned(
            top: 4,
            right: 8,
            child: _SecondaryChromeButton(
              icon: Icons.more_horiz_rounded,
              onPressed: onShowDetails,
            ),
          ),
          Positioned(
            right: 12,
            bottom: 20,
            child: _SecondaryChromeButton(
              icon: Icons.video_file_outlined,
              tooltip: AppStrings.playerChangeVideo,
              onPressed: onOpenVideo,
            ),
          ),
        ],
      ),
    );
  }
}

class _RuntimeOverlay extends StatelessWidget {
  const _RuntimeOverlay({
    required this.setup,
    required this.runtime,
    required this.controller,
    required this.chromeVisible,
    required this.onTogglePlayPause,
    required this.onSeek,
    required this.onSetSpeed,
    required this.onPickSubtitle,
    required this.onToggleSubtitles,
    required this.onOpenSubtitleSettings,
    required this.onShowDetails,
    required this.onVeilQuickAction,
    required this.isFullscreen,
    required this.onToggleFullscreen,
  });

  final PlayerSetupState setup;
  final PlayerRuntimeState runtime;
  final VideoPlayerController controller;
  final bool chromeVisible;
  final VoidCallback onTogglePlayPause;
  final Future<void> Function(Duration position) onSeek;
  final ValueChanged<double> onSetSpeed;
  final VoidCallback onPickSubtitle;
  final VoidCallback onToggleSubtitles;
  final VoidCallback onOpenSubtitleSettings;
  final VoidCallback onShowDetails;
  final VoidCallback onVeilQuickAction;
  final bool isFullscreen;
  final VoidCallback onToggleFullscreen;

  String? _veilIndicatorLabel() {
    final track = setup.selectedTrack;
    if (track == null) {
      return null;
    }

    final summary = TrackSummary.fromTrack(track);
    if (summary.totalActions == 0) {
      return null;
    }

    if (runtime.hasActiveEffects) {
      return AppStrings.playerVeilActive;
    }
    return AppStrings.playerVeilActionsIndicator(summary.totalActions);
  }

  @override
  Widget build(BuildContext context) {
    final indicator = _veilIndicatorLabel();
    final bookmarks = BookmarkSegments.fromTrack(setup.selectedTrack);

    return AnimatedOpacity(
      opacity: chromeVisible ? 1 : 0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      child: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 6,
              left: 10,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (indicator != null)
                    _VeilIndicatorPill(
                      label: indicator,
                      active: runtime.hasActiveEffects,
                    ),
                  if (setup.hasUnsavedTrackChanges) ...[
                    if (indicator != null) const SizedBox(width: 6),
                    _VeilIndicatorPill(
                      label: AppStrings.playerUnsavedTrackHint,
                      active: false,
                    ),
                  ],
                ],
              ),
            ),
            Positioned(
              top: 4,
              right: 8,
              child: _SecondaryChromeButton(
                icon: Icons.more_horiz_rounded,
                onPressed: onShowDetails,
              ),
            ),
            Positioned(
              right: 12,
              bottom: 68,
              child: PlayerVeilFloatingButton(onPressed: onVeilQuickAction),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: PlayerPlaybackControls(
                controller: controller,
                setup: setup,
                onTogglePlayPause: onTogglePlayPause,
                onSeek: onSeek,
                onFullscreen: onToggleFullscreen,
                isFullscreen: isFullscreen,
                onPickSubtitle: onPickSubtitle,
                onToggleSubtitles: onToggleSubtitles,
                onOpenSubtitleSettings: onOpenSubtitleSettings,
                onSetSpeed: onSetSpeed,
                bookmarks: bookmarks,
                onBookmarkSeek: (bookmark) {
                  onSeek(Duration(milliseconds: bookmark.pointMs));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrackSuggestionChip extends StatelessWidget {
  const _TrackSuggestionChip({required this.onAdd, required this.onDismiss});

  final VoidCallback onAdd;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onAdd,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 6, 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppStrings.playerAddVeilTrackSuggestion,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.88),
                ),
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: onDismiss,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: Colors.white.withValues(alpha: 0.55),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VeilIndicatorPill extends StatelessWidget {
  const _VeilIndicatorPill({required this.label, required this.active});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = active
        ? theme.colorScheme.primary.withValues(alpha: 0.78)
        : Colors.black.withValues(alpha: 0.42);
    final fg = active
        ? theme.colorScheme.onPrimary
        : Colors.white.withValues(alpha: 0.88);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: active
            ? null
            : Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: fg,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}

class _SecondaryChromeButton extends StatelessWidget {
  const _SecondaryChromeButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      style: IconButton.styleFrom(
        minimumSize: const Size(32, 32),
        padding: const EdgeInsets.all(6),
        backgroundColor: Colors.black.withValues(alpha: 0.28),
        foregroundColor: Colors.white.withValues(alpha: 0.65),
      ),
      icon: Icon(icon, size: 18),
    );
  }
}

class _PlayerDetailsSheet extends StatelessWidget {
  const _PlayerDetailsSheet({
    required this.setup,
    this.onClearVideo,
    this.onClearTrack,
    required this.onChangeVideo,
    this.onOpenBookmarks,
    required this.onLoadTrack,
    this.onExportTrack,
    this.onPreviewJson,
    required this.onOpenSegments,
    this.onViewTrackDetails,
    required this.onOpenSubtitleSettings,
  });

  final PlayerSetupState setup;
  final VoidCallback? onClearVideo;
  final VoidCallback? onClearTrack;
  final VoidCallback onChangeVideo;
  final VoidCallback? onOpenBookmarks;
  final VoidCallback onLoadTrack;
  final Future<void> Function()? onExportTrack;
  final Future<void> Function()? onPreviewJson;
  final VoidCallback onOpenSegments;
  final VoidCallback? onViewTrackDetails;
  final VoidCallback onOpenSubtitleSettings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(AppStrings.playerDetails, style: theme.textTheme.titleMedium),
        const SizedBox(height: 16),
        _DetailLine(
          label: AppStrings.playerInfoVideo,
          value: setup.selectedVideoName ?? AppStrings.playerNoVideoSelected,
        ),
        const SizedBox(height: 12),
        _DetailLine(
          label: AppStrings.playerInfoTrack,
          value: setup.selectedTrackTitle ?? AppStrings.playerNoTrackSelected,
          subtitle: setup.selectedTrack != null
              ? '${setup.segmentCount ?? 0} ${AppStrings.playerTrackSegments.toLowerCase()}'
              : null,
        ),
        if (setup.selectedTrack != null) ...[
          const SizedBox(height: 20),
          Text(
            AppStrings.trackSummarySection,
            style: theme.textTheme.titleSmall?.copyWith(
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          TrackSummaryStatsCard(
            summary: TrackSummary.fromTrack(setup.selectedTrack!),
          ),
          if (onViewTrackDetails != null) ...[
            const SizedBox(height: 4),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton(
                onPressed: onViewTrackDetails,
                child: Text(AppStrings.trackViewTrackDetails),
              ),
            ),
          ],
        ],
        if (setup.hasSubtitleFile) ...[
          const SizedBox(height: 12),
          _DetailLine(
            label: AppStrings.playerSubtitles,
            value: setup.subtitleFileName!,
          ),
        ],
        const SizedBox(height: 12),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            onPressed: onOpenSubtitleSettings,
            icon: const Icon(Icons.tune_outlined, size: 18),
            label: Text(AppStrings.playerSubtitleSettings),
          ),
        ),
        const SizedBox(height: 12),
        _DetailLine(
          label: AppStrings.playerPlaybackSpeed,
          value: setup.playbackSpeedLabel,
        ),
        const SizedBox(height: 12),
        _DetailLine(
          label: AppStrings.playerInfoStatus,
          value: _statusText(setup),
        ),
        if (setup.validationMessages.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            setup.validationMessages.join('\n'),
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.tertiary,
            ),
          ),
        ],
        if (setup.errorMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            setup.errorMessage!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.error,
            ),
          ),
        ],
        const SizedBox(height: 20),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                onOpenSegments();
              },
              icon: const Icon(Icons.view_list_outlined, size: 18),
              label: Text(AppStrings.playerTrackSegments),
            ),
            if (onOpenBookmarks != null)
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  onOpenBookmarks!();
                },
                icon: const Icon(Icons.bookmarks_outlined, size: 18),
                label: Text(AppStrings.playerBookmarks),
              ),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                onChangeVideo();
              },
              icon: const Icon(Icons.video_file_outlined, size: 18),
              label: Text(AppStrings.playerChangeVideo),
            ),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                onLoadTrack();
              },
              icon: const Icon(Icons.layers_outlined, size: 18),
              label: Text(AppStrings.playerLoadVeilTrack),
            ),
            if (onExportTrack != null) ...[
              if (setup.selectedTrack != null &&
                  trackExportSummarySubtitle(
                        TrackSummary.fromTrack(setup.selectedTrack!),
                      ) !=
                      null) ...[
                Text(
                  trackExportSummarySubtitle(
                    TrackSummary.fromTrack(setup.selectedTrack!),
                  )!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  onExportTrack!();
                },
                icon: const Icon(Icons.upload_outlined, size: 18),
                label: Text(AppStrings.playerExportTrack),
              ),
            ],
            if (onPreviewJson != null)
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  onPreviewJson!();
                },
                icon: const Icon(Icons.code_outlined, size: 18),
                label: Text(AppStrings.playerPreviewJson),
              ),
            if (onClearVideo != null)
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  onClearVideo!();
                },
                child: Text(AppStrings.playerClearVideo),
              ),
            if (onClearTrack != null)
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  onClearTrack!();
                },
                child: Text(AppStrings.playerClearTrack),
              ),
          ],
        ),
      ],
    );
  }

  static String _statusText(PlayerSetupState setup) {
    if (setup.isReadyForPlayback) {
      return AppStrings.playerReadyWithVeilTrack;
    }
    if (setup.isVideoReady) {
      return AppStrings.playerVideoReady;
    }
    if (setup.videoPlaybackStatus == PlayerVideoPlaybackStatus.unavailable) {
      return AppStrings.playerVideoPlaybackUnavailable;
    }
    return AppStrings.playerStatusWaiting;
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value, this.subtitle});

  final String label;
  final String value;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(value, style: theme.textTheme.bodyMedium),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
