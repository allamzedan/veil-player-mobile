import 'package:flutter_test/flutter_test.dart';
import 'package:veil_mobile/core/veil/veil_runtime_evaluator.dart';
import 'package:veil_mobile/core/veil/veil_segment.dart';
import 'package:veil_mobile/core/veil/veil_segment_type.dart';
import 'package:veil_mobile/core/veil/veil_track.dart';

void main() {
  group('VeilRuntimeEvaluator', () {
    test('detects active mask segment by position', () {
      final track = VeilTrack.empty().copyWith(
        segments: [
          VeilSegment.mobileDefault(
            type: VeilSegmentType.mask,
            startMs: 90000,
            endMs: 112000,
          ),
        ],
      );

      expect(VeilRuntimeEvaluator.activeSegmentsAt(track, 91000), hasLength(1));
      expect(VeilRuntimeEvaluator.activeSegmentsAt(track, 112001), isEmpty);
    });

    test('ignores disabled, marker, and bookmark segments', () {
      final track = VeilTrack.empty().copyWith(
        segments: [
          VeilSegment.mobileDefault(
            type: VeilSegmentType.marker,
            startMs: 0,
            endMs: 0,
          ),
          VeilSegment.bookmark(positionMs: 500, title: 'Note'),
          VeilSegment.mobileDefault(
            type: VeilSegmentType.mute,
            startMs: 1000,
            endMs: 2000,
            enabled: false,
          ),
        ],
      );

      expect(VeilRuntimeEvaluator.activeSegmentsAt(track, 1500), isEmpty);
    });

    test('uses default rect when segment rect is missing', () {
      const segment = VeilSegment(
        id: 'mask-1',
        type: VeilSegmentType.mask,
        startMs: 0,
        endMs: 1000,
      );

      final rect = VeilMaskRect.fromSegment(segment);
      expect(rect.xPercent, 10);
      expect(rect.yPercent, 78);
      expect(rect.widthPercent, 80);
      expect(rect.heightPercent, 18);
    });

    test('overlapping masks return all active masks', () {
      final track = VeilTrack.empty().copyWith(
        segments: [
          VeilSegment.mobileDefault(
            id: 'a',
            type: VeilSegmentType.mask,
            startMs: 1000,
            endMs: 4000,
          ),
          VeilSegment.mobileDefault(
            id: 'b',
            type: VeilSegmentType.mask,
            startMs: 1500,
            endMs: 2500,
          ),
        ],
      );

      final active = VeilRuntimeEvaluator.activeSegmentsAt(track, 2000);
      expect(VeilRuntimeEvaluator.activeMasks(active), hasLength(2));
    });

    test('overlapping skips prefer earliest segment', () {
      final track = VeilTrack.empty().copyWith(
        segments: [
          VeilSegment.mobileDefault(
            id: 'late',
            type: VeilSegmentType.skip,
            startMs: 3000,
            endMs: 5000,
          ),
          VeilSegment.mobileDefault(
            id: 'early',
            type: VeilSegmentType.skip,
            startMs: 1000,
            endMs: 6000,
          ),
        ],
      );

      final skip = VeilRuntimeEvaluator.activeSkipSegment(
        VeilRuntimeEvaluator.activeSegmentsAt(track, 3500),
      );
      expect(skip?.id, 'early');
    });
  });
}
