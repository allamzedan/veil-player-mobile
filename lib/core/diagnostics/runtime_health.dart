import 'package:veil_mobile/features/player/application/player_runtime_state.dart';
import 'package:veil_mobile/features/player/application/player_setup_state.dart';

/// Snapshot of player-related runtime health for diagnostics.
class RuntimeHealthSnapshot {
  const RuntimeHealthSnapshot({
    required this.trackLoaded,
    required this.videoLoaded,
    required this.subtitleLoaded,
    required this.runtimeActive,
  });

  final bool trackLoaded;
  final bool videoLoaded;
  final bool subtitleLoaded;
  final bool runtimeActive;
}

abstract final class RuntimeHealthChecker {
  static RuntimeHealthSnapshot evaluate({
    required PlayerSetupState setup,
    required PlayerRuntimeState runtime,
  }) {
    return RuntimeHealthSnapshot(
      trackLoaded: setup.selectedTrack != null,
      videoLoaded: setup.isVideoReady,
      subtitleLoaded: setup.hasSubtitleFile,
      runtimeActive: runtime.isRuntimeEnabled,
    );
  }
}
