import 'package:flutter_test/flutter_test.dart';
import 'package:veil_mobile/core/tracks/track_summary.dart';
import 'package:veil_mobile/core/veil/veil_runtime_evaluator.dart';
import 'package:veil_mobile/core/veil/veil_segment.dart';
import 'package:veil_mobile/core/veil/veil_segment_type.dart';
import 'package:veil_mobile/core/veil/veil_track.dart';
import 'package:veil_mobile/core/veil/veil_track_codec.dart';

VeilTrack _trackWithSegments(List<VeilSegment> segments) {
  return VeilTrack.empty().copyWith(segments: segments);
}

void main() {
  group('Track stress', () {
    test('empty track summary and runtime are stable', () {
      final track = VeilTrack.empty();
      final summary = TrackSummary.fromTrack(track);

      expect(summary.totalActions, 0);
      expect(VeilRuntimeEvaluator.activeSegmentsAt(track, 0), isEmpty);
      expect(VeilTrackCodec.encode(track), isNotEmpty);
    });

    test('single segment track evaluates correctly', () {
      final track = _trackWithSegments([
        VeilSegment.mobileDefault(
          type: VeilSegmentType.mute,
          startMs: 500,
          endMs: 1500,
        ),
      ]);

      expect(
        VeilRuntimeEvaluator.hasActiveMute(
          VeilRuntimeEvaluator.activeSegmentsAt(track, 1000),
        ),
        isTrue,
      );
    });

    test('100+ segments import and evaluate without error', () {
      final segments = List.generate(
        120,
        (index) => VeilSegment.mobileDefault(
          id: 'seg-$index',
          type: index.isEven ? VeilSegmentType.mask : VeilSegmentType.mute,
          startMs: index * 1000,
          endMs: (index * 1000) + 500,
        ),
      );
      final track = _trackWithSegments(segments);
      final json = VeilTrackCodec.encodeMobile(track);
      final restored = VeilTrackCodec.decode(json);

      expect(restored.segments, hasLength(120));

      final stopwatch = Stopwatch()..start();
      for (var ms = 0; ms < 120000; ms += 250) {
        VeilRuntimeEvaluator.activeSegmentsAt(restored, ms);
      }
      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(500));
    });

    test('overlapping masks return all active masks', () {
      final track = _trackWithSegments([
        VeilSegment.mobileDefault(
          id: 'mask-a',
          type: VeilSegmentType.mask,
          startMs: 1000,
          endMs: 4000,
        ),
        VeilSegment.mobileDefault(
          id: 'mask-b',
          type: VeilSegmentType.mask,
          startMs: 2000,
          endMs: 3000,
        ),
      ]);

      final active = VeilRuntimeEvaluator.activeSegmentsAt(track, 2500);
      final masks = VeilRuntimeEvaluator.activeMasks(active);

      expect(masks, hasLength(2));
    });

    test('overlapping mutes still report mute active', () {
      final track = _trackWithSegments([
        VeilSegment.mobileDefault(
          type: VeilSegmentType.mute,
          startMs: 1000,
          endMs: 3000,
        ),
        VeilSegment.mobileDefault(
          type: VeilSegmentType.mute,
          startMs: 2000,
          endMs: 4000,
        ),
      ]);

      final active = VeilRuntimeEvaluator.activeSegmentsAt(track, 2500);
      expect(VeilRuntimeEvaluator.hasActiveMute(active), isTrue);
      expect(active.where((s) => s.type == VeilSegmentType.mute), hasLength(2));
    });

    test('overlapping skips choose earliest start predictably', () {
      final track = _trackWithSegments([
        VeilSegment.mobileDefault(
          id: 'skip-late',
          type: VeilSegmentType.skip,
          startMs: 2000,
          endMs: 4000,
        ),
        VeilSegment.mobileDefault(
          id: 'skip-early',
          type: VeilSegmentType.skip,
          startMs: 1000,
          endMs: 5000,
        ),
      ]);

      final active = VeilRuntimeEvaluator.activeSegmentsAt(track, 2500);
      final skip = VeilRuntimeEvaluator.activeSkipSegment(active);

      expect(skip?.id, 'skip-early');
    });
  });
}
