import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veil_mobile/core/veil/veil_runtime_evaluator.dart';
import 'package:veil_mobile/core/veil/veil_track.dart';
import 'package:veil_mobile/features/player/application/player_display_settings_provider.dart';
import 'package:veil_mobile/features/player/application/player_runtime_state.dart';
import 'package:veil_mobile/features/player/application/player_setup_controller.dart';
import 'package:veil_mobile/features/player/application/player_setup_state.dart';
import 'package:veil_mobile/features/player/domain/player_display_settings.dart';
import 'package:video_player/video_player.dart';

final playerRuntimeControllerProvider =
    NotifierProvider<PlayerRuntimeController, PlayerRuntimeState>(
      PlayerRuntimeController.new,
    );

/// Applies mask/mute/skip effects during video playback.
class PlayerRuntimeController extends Notifier<PlayerRuntimeState> {
  VideoPlayerController? _attachedController;
  double? _lastOutputVolume;
  bool _skipInProgress = false;
  bool _syncScheduled = false;
  PlayerSetupState? _lastSyncedSetup;

  @override
  PlayerRuntimeState build() {
    ref.listen(playerSetupControllerProvider, (_, _) {
      _scheduleSetupSync();
    });
    ref.listen(playerDisplaySettingsProvider, (_, _) {
      _reapplyOutputVolume();
    });

    ref.onDispose(_detachVideoListener);
    _scheduleSetupSync();

    return const PlayerRuntimeState();
  }

  void _scheduleSetupSync() {
    if (_syncScheduled) {
      return;
    }
    _syncScheduled = true;
    Future.microtask(() {
      _syncScheduled = false;
      if (!ref.mounted) {
        return;
      }
      final next = ref.read(playerSetupControllerProvider);
      final previous = _lastSyncedSetup;
      _lastSyncedSetup = next;
      _applySetupChange(previous, next);
    });
  }

  void _applySetupChange(PlayerSetupState? previous, PlayerSetupState next) {
    final trackChanged = previous?.selectedTrack != next.selectedTrack;
    final videoChanged = previous?.videoRevision != next.videoRevision;

    if (trackChanged || videoChanged || !next.isVideoReady) {
      _resetEffects();
      state = const PlayerRuntimeState();
    }

    final controller = next.isVideoReady
        ? ref.read(playerSetupControllerProvider.notifier).videoController
        : null;

    _attachVideoListener(controller);
  }

  void _attachVideoListener(VideoPlayerController? controller) {
    if (_attachedController == controller) {
      return;
    }
    _detachVideoListener();
    _attachedController = controller;
    controller?.addListener(_onVideoTick);
    if (controller != null && controller.value.isInitialized) {
      Future.microtask(_onVideoTick);
    }
  }

  void _detachVideoListener() {
    _attachedController?.removeListener(_onVideoTick);
    _attachedController = null;
  }

  void _resetEffects() {
    _lastOutputVolume = null;
    _skipInProgress = false;
    _reapplyOutputVolume(forceVeilMute: false);
  }

  void _onVideoTick() {
    if (!ref.mounted) {
      return;
    }

    final controller = _attachedController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    final setup = ref.read(playerSetupControllerProvider);
    if (!setup.isVideoReady) {
      return;
    }

    final positionMs = controller.value.position.inMilliseconds;
    final track = setup.selectedTrack;
    if (track == null) {
      _reapplyOutputVolume(forceVeilMute: false);
      state = const PlayerRuntimeState();
      ref
          .read(playerSetupControllerProvider.notifier)
          .syncActiveSubtitle(positionMs);
      return;
    }

    final active = VeilRuntimeEvaluator.activeSegmentsAt(track, positionMs);
    final masks = VeilRuntimeEvaluator.activeMasks(active);
    final muted = VeilRuntimeEvaluator.hasActiveMute(active);
    final skipCluster = VeilRuntimeEvaluator.activeSkipClusterAt(
      track,
      positionMs,
    );

    _reapplyOutputVolume(forceVeilMute: muted);
    _rearmSkipIfNeeded(skipCluster);
    _maybeApplySkip(
      controller: controller,
      track: track,
      positionMs: positionMs,
      skipCluster: skipCluster,
    );

    state = PlayerRuntimeState(
      activeMaskSegments: masks,
      isMutedByVeil: muted,
      lastAppliedSkipSegmentId: state.lastAppliedSkipSegmentId,
      activeSegmentCount: active.length,
      hasActiveMask: masks.isNotEmpty,
      hasActiveMute: muted,
      hasActiveSkip: skipCluster != null,
      isRuntimeEnabled: true,
    );

    ref
        .read(playerSetupControllerProvider.notifier)
        .syncActiveSubtitle(positionMs);
  }

  void _reapplyOutputVolume({bool? forceVeilMute}) {
    final veilMuted = forceVeilMute ?? state.isMutedByVeil;
    final userVolume = ref.read(playerDisplaySettingsProvider).volume;
    final target = PlayerDisplaySettings.effectiveVolume(
      userVolume: userVolume,
      veilMuteActive: veilMuted,
    );

    if (_lastOutputVolume == target) {
      return;
    }
    _lastOutputVolume = target;

    final controller = _attachedController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }
    controller.setVolume(target);
  }

  /// Applies the current user volume preference (respecting active VEIL mute).
  void refreshOutputVolume() {
    _lastOutputVolume = null;
    _reapplyOutputVolume();
  }

  /// Reconciles VEIL effects immediately after a manual seek completes.
  Future<void> reconcileAfterSeek() async {
    final controller = _attachedController;
    if (controller == null ||
        !controller.value.isInitialized ||
        _skipInProgress) {
      return;
    }
    final track = ref.read(playerSetupControllerProvider).selectedTrack;
    if (track == null) {
      _onVideoTick();
      return;
    }
    final positionMs = controller.value.position.inMilliseconds;
    final active = VeilRuntimeEvaluator.activeSegmentsAt(track, positionMs);
    final masks = VeilRuntimeEvaluator.activeMasks(active);
    final muted = VeilRuntimeEvaluator.hasActiveMute(active);
    final skipCluster = VeilRuntimeEvaluator.activeSkipClusterAt(
      track,
      positionMs,
    );
    _reapplyOutputVolume(forceVeilMute: muted);
    // A completed user seek is a genuinely new external event. It may re-arm
    // the same cluster; a paused seek remains undisplaced below.
    state = state.copyWith(clearLastAppliedSkip: true);
    _rearmSkipIfNeeded(skipCluster);
    state = PlayerRuntimeState(
      activeMaskSegments: masks,
      isMutedByVeil: muted,
      lastAppliedSkipSegmentId: state.lastAppliedSkipSegmentId,
      activeSegmentCount: active.length,
      hasActiveMask: masks.isNotEmpty,
      hasActiveMute: muted,
      hasActiveSkip: skipCluster != null,
      isRuntimeEnabled: true,
    );
    if (skipCluster != null) {
      await _maybeApplySkip(
        controller: controller,
        track: track,
        positionMs: positionMs,
        skipCluster: skipCluster,
      );
    }
    _onVideoTick();
  }

  void _rearmSkipIfNeeded(VeilSkipCluster? activeSkip) {
    final lastId = state.lastAppliedSkipSegmentId;
    if (lastId == null) {
      return;
    }
    if (activeSkip != null && activeSkip.runtimeKey == lastId) {
      return;
    }
    state = state.copyWith(clearLastAppliedSkip: true);
  }

  Future<void> _maybeApplySkip({
    required VideoPlayerController controller,
    required VeilTrack track,
    required int positionMs,
    required VeilSkipCluster? skipCluster,
  }) async {
    if (skipCluster == null || _skipInProgress || !controller.value.isPlaying) {
      return;
    }
    if (state.lastAppliedSkipSegmentId == skipCluster.runtimeKey) {
      return;
    }
    if (VeilRuntimeEvaluator.activeSkipClusterAt(
          track,
          positionMs,
        )?.runtimeKey !=
        skipCluster.runtimeKey) {
      return;
    }

    _skipInProgress = true;
    state = state.copyWith(lastAppliedSkipSegmentId: skipCluster.runtimeKey);

    final wasPlaying = controller.value.isPlaying;
    final reportedDurationMs = controller.value.duration.inMilliseconds;
    final clampedMs = VeilRuntimeEvaluator.skipHostTargetMs(
      track: track,
      cluster: skipCluster,
      hostDurationMs: reportedDurationMs > 0 ? reportedDurationMs : null,
    );

    try {
      await controller.seekTo(Duration(milliseconds: clampedMs));
      if (wasPlaying && !controller.value.isPlaying) {
        await controller.play();
      }
    } finally {
      _skipInProgress = false;
      if (ref.mounted) {
        Future.microtask(_onVideoTick);
      }
    }
  }
}
