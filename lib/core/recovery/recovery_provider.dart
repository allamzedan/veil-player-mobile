import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:veil_mobile/core/recovery/recovery_autosave_throttle.dart';
import 'package:veil_mobile/core/recovery/recovery_draft.dart';
import 'package:veil_mobile/core/recovery/recovery_storage_service.dart';
import 'package:veil_mobile/core/logging/app_logger.dart';
import 'package:veil_mobile/core/storage/storage_providers.dart';
import 'package:veil_mobile/core/veil/veil_track.dart';
import 'package:veil_mobile/core/veil/veil_track_codec.dart';
import 'package:veil_mobile/features/player/application/player_setup_controller.dart';
import 'package:veil_mobile/features/player/application/player_setup_state.dart';
import 'package:veil_mobile/features/track_builder/application/track_builder_controller.dart';
import 'package:veil_mobile/features/track_builder/application/track_builder_state.dart';
import 'package:veil_mobile/shared/utils/local_file_access.dart';

final recoveryStorageServiceProvider = Provider<RecoveryStorageService>(
  (ref) => RecoveryStorageService(ref.watch(sharedPreferencesProvider)),
);

class RecoveryState {
  const RecoveryState({
    this.playerDraft,
    this.trackBuilderDraft,
  });

  final RecoveryDraft? playerDraft;
  final RecoveryDraft? trackBuilderDraft;

  List<RecoveryDraft> get dirtyDrafts => [
    if (playerDraft?.isDirty == true) playerDraft!,
    if (trackBuilderDraft?.isDirty == true) trackBuilderDraft!,
  ];

  RecoveryDraft? get newestDirtyDraft {
    final dirty = dirtyDrafts;
    if (dirty.isEmpty) {
      return null;
    }
    dirty.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return dirty.first;
  }

  RecoveryState copyWith({
    RecoveryDraft? playerDraft,
    RecoveryDraft? trackBuilderDraft,
    bool clearPlayerDraft = false,
    bool clearTrackBuilderDraft = false,
  }) {
    return RecoveryState(
      playerDraft: clearPlayerDraft ? null : (playerDraft ?? this.playerDraft),
      trackBuilderDraft: clearTrackBuilderDraft
          ? null
          : (trackBuilderDraft ?? this.trackBuilderDraft),
    );
  }
}

final recoveryControllerProvider =
    NotifierProvider<RecoveryController, RecoveryState>(RecoveryController.new);

class RecoveryController extends Notifier<RecoveryState> {
  static const _uuid = Uuid();

  final RecoveryAutosaveThrottle _playerThrottle = RecoveryAutosaveThrottle();
  final RecoveryAutosaveThrottle _trackBuilderThrottle =
      RecoveryAutosaveThrottle();

  RecoveryStorageService get _storage => ref.read(recoveryStorageServiceProvider);

  @override
  RecoveryState build() {
    return RecoveryState(
      playerDraft: _storage.loadPlayerDraft(),
      trackBuilderDraft: _storage.loadTrackBuilderDraft(),
    );
  }

  Future<void> reloadFromStorage() async {
    state = RecoveryState(
      playerDraft: _storage.loadPlayerDraft(),
      trackBuilderDraft: _storage.loadTrackBuilderDraft(),
    );
  }

  Future<bool> autosavePlayer({
    RecoveryDraftReason reason = RecoveryDraftReason.autosave,
    bool force = false,
  }) async {
    final setup = ref.read(playerSetupControllerProvider);
    if (!_shouldAutosavePlayer(setup)) {
      return true;
    }
    if (!force && !_playerThrottle.shouldSave(force: false)) {
      return true;
    }

    final track = setup.selectedTrack!;
    final draft = _buildDraft(
      source: RecoveryDraftSource.player,
      track: track,
      trackTitle: setup.selectedTrackTitle ?? track.title,
      trackId: track.id,
      videoName: setup.selectedVideoName,
      videoPath: setup.selectedVideoPath,
      reason: reason,
      existingId: state.playerDraft?.id,
    );

    try {
      await _storage.saveDraft(draft);
    } on Object catch (error, stackTrace) {
      AppLogger.error('Player recovery autosave failed', error, stackTrace);
      return false;
    }

    _playerThrottle.markSaved();
    state = state.copyWith(playerDraft: draft);
    return true;
  }

  Future<bool> autosaveTrackBuilder({
    RecoveryDraftReason reason = RecoveryDraftReason.autosave,
    bool force = false,
  }) async {
    final builder = ref.read(trackBuilderControllerProvider);
    if (!_shouldAutosaveTrackBuilder(builder)) {
      return true;
    }
    if (!force && !_trackBuilderThrottle.shouldSave(force: false)) {
      return true;
    }

    final track = builder.track;
    final draft = _buildDraft(
      source: RecoveryDraftSource.trackBuilder,
      track: track,
      trackTitle: track.title.trim().isEmpty
          ? track.id
          : track.title.trim(),
      trackId: track.id,
      reason: reason,
      existingId: state.trackBuilderDraft?.id,
    );

    try {
      await _storage.saveDraft(draft);
    } on Object catch (error, stackTrace) {
      AppLogger.error('Track builder recovery autosave failed', error, stackTrace);
      return false;
    }

    _trackBuilderThrottle.markSaved();
    state = state.copyWith(trackBuilderDraft: draft);
    return true;
  }

  Future<void> forceSaveAllDirty() async {
    await autosavePlayer(
      reason: RecoveryDraftReason.background,
      force: true,
    );
    await autosaveTrackBuilder(
      reason: RecoveryDraftReason.background,
      force: true,
    );
  }

  Future<void> clearPlayerDraft() async {
    await _storage.deleteDraft(RecoveryDraftSource.player);
    _playerThrottle.reset();
    state = state.copyWith(clearPlayerDraft: true);
  }

  Future<void> clearTrackBuilderDraft() async {
    await _storage.deleteDraft(RecoveryDraftSource.trackBuilder);
    _trackBuilderThrottle.reset();
    state = state.copyWith(clearTrackBuilderDraft: true);
  }

  Future<void> discardDraft(RecoveryDraftSource source) async {
    switch (source) {
      case RecoveryDraftSource.player:
        await clearPlayerDraft();
      case RecoveryDraftSource.trackBuilder:
        await clearTrackBuilderDraft();
    }
  }

  Future<bool> restoreDraft(RecoveryDraft draft) async {
    switch (draft.source) {
      case RecoveryDraftSource.player:
        return _restorePlayerDraft(draft);
      case RecoveryDraftSource.trackBuilder:
        return _restoreTrackBuilderDraft(draft);
    }
  }

  Future<bool> _restorePlayerDraft(RecoveryDraft draft) async {
    if (draft.trackJson.trim().isEmpty) {
      return false;
    }

    final player = ref.read(playerSetupControllerProvider.notifier);

    if (draft.videoPath != null &&
        draft.videoPath!.isNotEmpty &&
        localFileExists(draft.videoPath!)) {
      await player.openVideoFromPath(
        path: draft.videoPath!,
        filename: draft.videoName ?? draft.videoPath!.split(RegExp(r'[\\/]')).last,
      );
    }

    final trackError = await player.restoreTrackFromRecovery(
      content: draft.trackJson,
      title: draft.trackTitle,
    );
    return trackError == null;
  }

  Future<bool> _restoreTrackBuilderDraft(RecoveryDraft draft) async {
    try {
      final track = VeilTrackCodec.decode(draft.trackJson);
      ref.read(trackBuilderControllerProvider.notifier).loadTrackDraft(track);
      return true;
    } on Object {
      return false;
    }
  }

  RecoveryDraft _buildDraft({
    required RecoveryDraftSource source,
    required VeilTrack track,
    required String trackTitle,
    required RecoveryDraftReason reason,
    String? trackId,
    String? videoName,
    String? videoPath,
    String? existingId,
  }) {
    return RecoveryDraft(
      id: existingId ?? _uuid.v4(),
      source: source,
      trackId: trackId ?? track.id,
      trackTitle: trackTitle,
      trackJson: VeilTrackCodec.encode(track),
      videoName: videoName,
      videoPath: videoPath,
      updatedAt: DateTime.now().toUtc(),
      reason: reason,
      segmentCount: track.segments.length,
      isDirty: true,
    );
  }

  bool _shouldAutosavePlayer(PlayerSetupState setup) {
    final track = setup.selectedTrack;
    if (track == null) {
      return false;
    }
    return setup.hasUnsavedTrackChanges;
  }

  bool _shouldAutosaveTrackBuilder(TrackBuilderState builder) {
    return builder.hasUnsavedChanges;
  }
}
