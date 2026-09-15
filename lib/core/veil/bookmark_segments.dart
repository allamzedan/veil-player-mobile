import 'package:veil_mobile/core/veil/veil_segment.dart';
import 'package:veil_mobile/core/veil/veil_segment_type.dart';
import 'package:veil_mobile/core/veil/veil_track.dart';

/// Bookmark-only helpers for sorting and timeline markers.
abstract final class BookmarkSegments {
  static List<VeilSegment> fromTrack(VeilTrack? track) {
    if (track == null) {
      return const [];
    }
    return fromSegments(track.segments);
  }

  static List<VeilSegment> fromSegments(Iterable<VeilSegment> segments) {
    return [
      for (final segment in segments)
        if (segment.enabled &&
            segment.type == VeilSegmentType.bookmark &&
            segment.hasValidTiming)
          segment,
    ]..sort((a, b) => a.startMs.compareTo(b.startMs));
  }

  /// Normalized timeline position in `[0, 1]` for a bookmark at [positionMs].
  static double timelineFraction({
    required int positionMs,
    required int durationMs,
  }) {
    if (durationMs <= 0) {
      return 0;
    }
    return (positionMs.clamp(0, durationMs) / durationMs).toDouble();
  }
}
