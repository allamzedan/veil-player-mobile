import 'package:veil_mobile/core/veil/veil_segment.dart';

/// Runtime playback effects driven by the loaded VEIL track.
class PlayerRuntimeState {
  const PlayerRuntimeState({
    this.activeMaskSegments = const [],
    this.isMutedByVeil = false,
    this.lastAppliedSkipSegmentId,
    this.activeSegmentCount = 0,
    this.hasActiveMask = false,
    this.hasActiveMute = false,
    this.hasActiveSkip = false,
    this.isRuntimeEnabled = false,
  });

  final List<VeilSegment> activeMaskSegments;
  final bool isMutedByVeil;
  final String? lastAppliedSkipSegmentId;
  final int activeSegmentCount;
  final bool hasActiveMask;
  final bool hasActiveMute;
  final bool hasActiveSkip;
  final bool isRuntimeEnabled;

  bool get hasActiveEffects =>
      isRuntimeEnabled && (hasActiveMask || hasActiveMute || hasActiveSkip);

  PlayerRuntimeState copyWith({
    List<VeilSegment>? activeMaskSegments,
    bool? isMutedByVeil,
    String? lastAppliedSkipSegmentId,
    int? activeSegmentCount,
    bool? hasActiveMask,
    bool? hasActiveMute,
    bool? hasActiveSkip,
    bool? isRuntimeEnabled,
    bool clearLastAppliedSkip = false,
  }) {
    return PlayerRuntimeState(
      activeMaskSegments: activeMaskSegments ?? this.activeMaskSegments,
      isMutedByVeil: isMutedByVeil ?? this.isMutedByVeil,
      lastAppliedSkipSegmentId: clearLastAppliedSkip
          ? null
          : (lastAppliedSkipSegmentId ?? this.lastAppliedSkipSegmentId),
      activeSegmentCount: activeSegmentCount ?? this.activeSegmentCount,
      hasActiveMask: hasActiveMask ?? this.hasActiveMask,
      hasActiveMute: hasActiveMute ?? this.hasActiveMute,
      hasActiveSkip: hasActiveSkip ?? this.hasActiveSkip,
      isRuntimeEnabled: isRuntimeEnabled ?? this.isRuntimeEnabled,
    );
  }
}
