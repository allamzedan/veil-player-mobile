import 'package:flutter_test/flutter_test.dart';
import 'package:veil_mobile/core/veil/bookmark_segments.dart';
import 'package:veil_mobile/core/veil/veil_segment.dart';
import 'package:veil_mobile/core/veil/veil_segment_type.dart';
import 'package:veil_mobile/core/veil/veil_track.dart';
import 'package:veil_mobile/core/veil/veil_track_codec.dart';

VeilTrack _trackWithBookmarks() {
  final now = DateTime.utc(2026, 5, 19);
  return VeilTrack(
    id: 'track-1',
    title: 'Bookmark Track',
    version: '1.0.0',
    createdAt: now,
    updatedAt: now,
    segments: [
      VeilSegment.bookmark(
        id: 'b2',
        positionMs: 30_000,
        title: 'Scene B',
      ),
      VeilSegment.bookmark(
        id: 'b1',
        positionMs: 10_000,
        title: 'Scene A',
        note: 'Review later',
      ),
      VeilSegment.quickAction(
        id: 'mute-1',
        type: VeilSegmentType.mute,
        startMs: 5000,
        endMs: 8000,
      ),
    ],
  );
}

void main() {
  group('BookmarkSegments', () {
    test('fromSegments sorts by start time', () {
      final bookmarks = BookmarkSegments.fromSegments(
        _trackWithBookmarks().segments,
      );

      expect(bookmarks, hasLength(2));
      expect(bookmarks.map((b) => b.id).toList(), ['b1', 'b2']);
    });

    test('timelineFraction maps position within duration', () {
      expect(
        BookmarkSegments.timelineFraction(positionMs: 5000, durationMs: 10_000),
        0.5,
      );
      expect(
        BookmarkSegments.timelineFraction(
          positionMs: 15_000,
          durationMs: 10_000,
        ),
        1.0,
      );
    });
  });

  group('VeilTrackCodec bookmark export', () {
    test('exports bookmark items with label and notes', () {
      final track = _trackWithBookmarks();
      final encoded = VeilTrackCodec.encode(track);
      final decoded = VeilTrackCodec.decode(encoded);

      final bookmarks = decoded.segments
          .where((s) => s.type == VeilSegmentType.bookmark)
          .toList();
      expect(bookmarks, hasLength(2));
      expect(bookmarks.any((b) => b.label == 'Scene A'), isTrue);
      expect(bookmarks.any((b) => b.notes == 'Review later'), isTrue);
    });

    test('bookmark point segments keep equal start and end', () {
      final segment = VeilSegment.bookmark(
        positionMs: 862_000,
        title: 'Vocabulary word',
        note: 'Important scene',
      );

      expect(segment.startMs, segment.endMs);
      expect(segment.hasValidTiming, isTrue);
    });
  });
}
