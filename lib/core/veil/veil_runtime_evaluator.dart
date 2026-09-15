import 'package:veil_mobile/core/veil/veil_segment.dart';
import 'package:veil_mobile/core/veil/veil_segment_type.dart';
import 'package:veil_mobile/core/veil/veil_track.dart';

/// Playback-time evaluation of VEIL track segments.
abstract final class VeilRuntimeEvaluator {
  /// Segments active at [positionMs] (enabled, valid timing, not marker).
  static List<VeilSegment> activeSegmentsAt(VeilTrack? track, int positionMs) {
    if (track == null) {
      return const [];
    }

    final offsetMs = ((track.globalOffsetSeconds ?? 0) * 1000).round();
    final effectiveMs = positionMs + offsetMs;

    return track.segments.where((segment) {
      if (!segment.enabled || segment.isInformationalOnly) {
        return false;
      }
      if (!segment.hasValidTiming) {
        return false;
      }
      return effectiveMs >= segment.startMs && effectiveMs <= segment.endMs;
    }).toList();
  }

  static List<VeilSegment> activeMasks(List<VeilSegment> active) {
    return active
        .where((segment) => segment.type == VeilSegmentType.mask)
        .toList();
  }

  static bool hasActiveMute(List<VeilSegment> active) {
    return active.any((segment) => segment.type == VeilSegmentType.mute);
  }

  /// Runtime-only maximal clusters of enabled Skip intervals.
  static List<VeilSkipCluster> normalizedSkipClusters(VeilTrack? track) {
    final skips =
        (track?.segments ?? const <VeilSegment>[])
            .where(
              (segment) =>
                  segment.enabled &&
                  segment.hasValidTiming &&
                  segment.type == VeilSegmentType.skip,
            )
            .toList()
          ..sort((a, b) {
            final byStart = a.startMs.compareTo(b.startMs);
            return byStart != 0 ? byStart : a.endMs.compareTo(b.endMs);
          });
    final clusters = <VeilSkipCluster>[];
    for (final skip in skips) {
      if (clusters.isEmpty || skip.startMs > clusters.last.endMs) {
        clusters.add(
          VeilSkipCluster(
            startMs: skip.startMs,
            endMs: skip.endMs,
            itemIds: [skip.id],
          ),
        );
        continue;
      }
      final previous = clusters.removeLast();
      clusters.add(
        VeilSkipCluster(
          startMs: previous.startMs,
          endMs: skip.endMs > previous.endMs ? skip.endMs : previous.endMs,
          itemIds: [...previous.itemIds, skip.id],
        ),
      );
    }
    return clusters;
  }

  static VeilSkipCluster? activeSkipClusterAt(
    VeilTrack? track,
    int positionMs,
  ) {
    if (track == null) return null;
    final offsetMs = ((track.globalOffsetSeconds ?? 0) * 1000).round();
    final effectiveMs = positionMs + offsetMs;
    for (final cluster in normalizedSkipClusters(track)) {
      if (effectiveMs >= cluster.startMs && effectiveMs <= cluster.endMs) {
        return cluster;
      }
    }
    return null;
  }

  /// Converts a VEIL-timeline cluster end to the host playback coordinate.
  static int skipHostTargetMs({
    required VeilTrack track,
    required VeilSkipCluster cluster,
    int? hostDurationMs,
  }) {
    final offsetMs = ((track.globalOffsetSeconds ?? 0) * 1000).round();
    var veilTargetMs = cluster.endMs;
    if (hostDurationMs != null) {
      final effectiveMediaDurationMs = hostDurationMs + offsetMs;
      if (veilTargetMs > effectiveMediaDurationMs) {
        veilTargetMs = effectiveMediaDurationMs;
      }
    }
    final hostTargetMs = veilTargetMs - offsetMs;
    return hostTargetMs < 0 ? 0 : hostTargetMs;
  }

  /// Backward-compatible representative for display-only callers.
  static VeilSegment? activeSkipSegment(List<VeilSegment> active) {
    final skips =
        active.where((segment) => segment.type == VeilSegmentType.skip).toList()
          ..sort((a, b) => a.startMs.compareTo(b.startMs));
    return skips.isEmpty ? null : skips.first;
  }

  /// Whether [positionMs] is inside [segment] (skip re-arm uses this).
  static bool isInsideSegment(
    VeilSegment segment,
    int positionMs,
    VeilTrack? track,
  ) {
    if (!segment.enabled || !segment.hasValidTiming) {
      return false;
    }
    final offsetMs = ((track?.globalOffsetSeconds ?? 0) * 1000).round();
    final effectiveMs = positionMs + offsetMs;
    return effectiveMs >= segment.startMs && effectiveMs <= segment.endMs;
  }
}

/// A normalized Skip cluster. Source authoring items are never rewritten.
class VeilSkipCluster {
  const VeilSkipCluster({
    required this.startMs,
    required this.endMs,
    required this.itemIds,
  });

  final int startMs;
  final int endMs;
  final List<String> itemIds;

  String get runtimeKey => '$startMs:$endMs:${itemIds.join(',')}';
}

/// Percentage rectangle for mask overlays.
class VeilMaskRect {
  const VeilMaskRect({
    required this.xPercent,
    required this.yPercent,
    required this.widthPercent,
    required this.heightPercent,
  });

  final double xPercent;
  final double yPercent;
  final double widthPercent;
  final double heightPercent;

  factory VeilMaskRect.fromSegment(VeilSegment segment) {
    final rect = segment.rect ?? VeilSegment.defaultRect;
    return VeilMaskRect(
      xPercent: _readPercent(
        rect,
        'xPercent',
        VeilSegment.defaultRect['xPercent']!,
      ),
      yPercent: _readPercent(
        rect,
        'yPercent',
        VeilSegment.defaultRect['yPercent']!,
      ),
      widthPercent: _readPercent(
        rect,
        'widthPercent',
        VeilSegment.defaultRect['widthPercent']!,
      ),
      heightPercent: _readPercent(
        rect,
        'heightPercent',
        VeilSegment.defaultRect['heightPercent']!,
      ),
    );
  }

  static double _readPercent(
    Map<String, dynamic> rect,
    String key,
    num fallback,
  ) {
    final value = rect[key];
    if (value is num) {
      return value.toDouble();
    }
    return fallback.toDouble();
  }
}

/// Resolved solid mask fill from segment [style].
abstract final class VeilMaskStyle {
  static double opacityFromStyle(Map<String, dynamic>? style) {
    final resolved = style ?? VeilSegment.defaultStyle;
    final opacity = resolved['opacity'];
    if (opacity is num) {
      return opacity.toDouble().clamp(0.0, 1.0);
    }
    return 1.0;
  }

  /// Returns black for non-solid modes until more modes are supported.
  static int colorValueFromStyle(Map<String, dynamic>? style) {
    final resolved = style ?? VeilSegment.defaultStyle;
    final mode = resolved['mode'] as String? ?? 'solid';
    if (mode != 'solid') {
      return 0xFF000000;
    }
    final raw = resolved['color'];
    if (raw is String) {
      return _parseHexColor(raw) ?? 0xFF000000;
    }
    return 0xFF000000;
  }

  static int? _parseHexColor(String value) {
    var hex = value.trim();
    if (hex.startsWith('#')) {
      hex = hex.substring(1);
    }
    if (hex.length == 6) {
      final parsed = int.tryParse(hex, radix: 16);
      if (parsed != null) {
        return 0xFF000000 | parsed;
      }
    }
    return null;
  }
}
