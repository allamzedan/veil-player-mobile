import 'package:flutter_test/flutter_test.dart';
import 'package:veil_mobile/core/tracks/track_summary.dart';
import 'package:veil_mobile/core/veil/veil_segment.dart';
import 'package:veil_mobile/core/veil/veil_segment_type.dart';
import 'package:veil_mobile/core/veil/veil_track.dart';

VeilTrack _sampleTrack({
  List<VeilSegment> segments = const [],
  String title = 'Preview Track',
}) {
  final now = DateTime.utc(2026, 5, 19, 12);
  return VeilTrack(
    id: 'track-1',
    title: title,
    version: '1.0.0',
    createdAt: now,
    updatedAt: now.add(const Duration(hours: 2)),
    segments: segments,
    videoName: 'sample.mp4',
    videoDurationSeconds: 120,
    video: {
      'name': 'sample.mp4',
      'duration': 120,
      'fingerprint': {'method': 'metadata-v1'},
    },
  );
}

void main() {
  group('TrackSummary', () {
    test('fromTrack counts enabled mask, mute, and skip segments', () {
      final track = _sampleTrack(
        segments: [
          VeilSegment(
            id: '1',
            type: VeilSegmentType.mask,
            startMs: 1000,
            endMs: 4000,
          ),
          VeilSegment(
            id: '2',
            type: VeilSegmentType.mute,
            startMs: 5000,
            endMs: 8000,
          ),
          VeilSegment(
            id: '3',
            type: VeilSegmentType.skip,
            startMs: 9000,
            endMs: 12000,
          ),
          VeilSegment(
            id: '4',
            type: VeilSegmentType.marker,
            startMs: 13000,
            endMs: 13000,
          ),
          VeilSegment(
            id: '5',
            type: VeilSegmentType.mask,
            startMs: 14000,
            endMs: 15000,
            enabled: false,
          ),
        ],
      );

      final summary = TrackSummary.fromTrack(track);

      expect(summary.maskCount, 1);
      expect(summary.muteCount, 1);
      expect(summary.skipCount, 1);
      expect(summary.totalActions, 3);
      expect(summary.segmentCount, 5);
    });

    test('fromTrack counts bookmarks separately from actions', () {
      final track = _sampleTrack(
        segments: [
          VeilSegment.bookmark(
            positionMs: 14_000,
            title: 'Important scene',
          ),
          VeilSegment.bookmark(
            positionMs: 862_000,
            title: 'Vocabulary word',
          ),
        ],
      );

      final summary = TrackSummary.fromTrack(track);

      expect(summary.bookmarkCount, 2);
      expect(summary.totalActions, 0);
    });

    test('fromTrack sums affected seconds per action type', () {
      final track = _sampleTrack(
        segments: [
          VeilSegment(
            id: '1',
            type: VeilSegmentType.mask,
            startMs: 8000,
            endMs: 13000,
          ),
          VeilSegment(
            id: '2',
            type: VeilSegmentType.mute,
            startMs: 25000,
            endMs: 28000,
          ),
          VeilSegment(
            id: '3',
            type: VeilSegmentType.skip,
            startMs: 45000,
            endMs: 52000,
          ),
        ],
      );

      final summary = TrackSummary.fromTrack(track);

      expect(summary.totalMaskedSeconds, closeTo(5, 0.001));
      expect(summary.totalMutedSeconds, closeTo(3, 0.001));
      expect(summary.totalSkippedSeconds, closeTo(7, 0.001));
    });

    test('fromTrack resolves metadata fields', () {
      final track = _sampleTrack();

      final summary = TrackSummary.fromTrack(track);

      expect(summary.title, 'Preview Track');
      expect(summary.videoName, 'sample.mp4');
      expect(summary.videoDurationSeconds, 120);
      expect(summary.fingerprintMethod, 'metadata-v1');
      expect(summary.createdAt, track.createdAt);
      expect(summary.updatedAt, track.updatedAt);
    });

    test('fromTrack uses default title when track title is blank', () {
      final summary = TrackSummary.fromTrack(_sampleTrack(title: '   '));

      expect(summary.title, VeilTrack.defaultUntitledTitle);
    });
  });

  group('TrackActionPreview', () {
    test('fromTrack sorts actions by start time', () {
      final track = _sampleTrack(
        segments: [
          VeilSegment(
            id: 'late',
            type: VeilSegmentType.skip,
            startMs: 45000,
            endMs: 52000,
          ),
          VeilSegment(
            id: 'first',
            type: VeilSegmentType.mask,
            startMs: 8000,
            endMs: 13000,
          ),
          VeilSegment(
            id: 'middle',
            type: VeilSegmentType.mute,
            startMs: 25000,
            endMs: 28000,
          ),
        ],
      );

      final previews = TrackActionPreview.fromTrack(track);

      expect(previews, hasLength(3));
      expect(previews[0].startMs, 8000);
      expect(previews[0].type, VeilSegmentType.mask);
      expect(previews[1].startMs, 25000);
      expect(previews[1].type, VeilSegmentType.mute);
      expect(previews[2].startMs, 45000);
      expect(previews[2].type, VeilSegmentType.skip);
    });

    test('fromTrack limits preview items and excludes markers', () {
      final segments = <VeilSegment>[
        for (var i = 0; i < 12; i++)
          VeilSegment(
            id: '$i',
            type: VeilSegmentType.mask,
            startMs: i * 1000,
            endMs: (i * 1000) + 500,
          ),
        VeilSegment(
          id: 'marker',
          type: VeilSegmentType.marker,
          startMs: 999000,
          endMs: 999000,
        ),
      ];

      final previews = TrackActionPreview.fromTrack(_sampleTrack(segments: segments));

      expect(previews, hasLength(TrackActionPreview.defaultLimit));
      expect(previews.first.startMs, 0);
      expect(previews.last.startMs, 9000);
      expect(previews.any((item) => item.type == VeilSegmentType.marker), isFalse);
    });
  });
}
