import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:veil_mobile/core/veil/veil_segment.dart';
import 'package:veil_mobile/core/veil/veil_segment_type.dart';
import 'package:veil_mobile/core/veil/veil_track.dart';
import 'package:veil_mobile/core/veil/veil_track_codec.dart';
import 'package:veil_mobile/core/veil/veil_track_validator.dart';

void main() {
  const desktopSampleJson = '''
{
  "version": "1.6.0",
  "app": "VEIL",
  "appVersion": "0.6.0",
  "exportedAt": "2026-05-20T01:57:55.537Z",
  "video": {
    "name": "Everyday Conversations with Strangers _ Easy English 224.mp4",
    "duration": 633.689342,
    "fileSize": 71749918,
    "resolution": {
      "width": 854,
      "height": 480
    },
    "fingerprint": {
      "method": "metadata-v1",
      "value": "Everyday Conversations with Strangers _ Easy English 224.mp4|71749918|633.689|854|480"
    }
  },
  "globalOffsetSeconds": 0,
  "trackMetadata": {
    "createdAt": "2026-05-20T01:57:55.537Z",
    "updatedAt": "2026-05-20T01:57:55.537Z"
  },
  "items": [
    {
      "id": "98dbdb57-79f4-4621-b9f2-a62f74b93e7c",
      "type": "mask",
      "enabled": true,
      "start": 91.7,
      "end": 112,
      "rect": {
        "xPercent": 21.19395167139224,
        "yPercent": 79.36262572789836,
        "widthPercent": 63.20592658346175,
        "heightPercent": 11.364743250397034
      },
      "style": {
        "mode": "solid",
        "color": "#000000",
        "opacity": 1
      },
      "source": {
        "kind": "manual"
      }
    }
  ],
  "subtitleCover": {
    "mode": "smartCover",
    "regionRect": {
      "xPercent": 10,
      "yPercent": 78,
      "widthPercent": 80,
      "heightPercent": 18
    }
  }
}
''';

  group('VeilTrackCodec', () {
    test('imports desktop VEIL track sample', () {
      final track = VeilTrackCodec.decode(desktopSampleJson);

      expect(track.title, contains('Everyday Conversations'));
      expect(track.videoName, contains('Everyday Conversations'));
      expect(track.videoDurationSeconds, closeTo(633.689342, 0.001));
      expect(track.videoFileSize, 71749918);
      expect(track.videoWidth, 854);
      expect(track.videoHeight, 480);
      expect(track.segments, hasLength(1));
      expect(track.segments.first.type, VeilSegmentType.mask);
      expect(track.segments.first.startMs, 91700);
      expect(track.segments.first.endMs, 112000);
      expect(track.segments.first.enabled, isTrue);
      expect(track.segments.first.rect?['xPercent'], closeTo(21.19, 0.01));
      expect(track.segments.first.source?['kind'], 'manual');
      expect(track.subtitleCover?['mode'], 'smartCover');
      expect(track.video?['fingerprint'], isNotNull);
      expect(VeilTrackValidator.validate(track), isEmpty);
    });

    test('exports desktop-compatible format', () {
      final track = VeilTrackCodec.decode(desktopSampleJson);
      final exported = VeilTrackCodec.encode(track);
      final reimported = VeilTrackCodec.decode(exported);

      expect(exported, contains('"items"'));
      expect(exported, isNot(contains('"segments"')));
      expect(exported, contains('"start":'));
      expect(reimported.segments.first.id, track.segments.first.id);
      expect(
        reimported.segments.first.rect?['xPercent'],
        track.segments.first.rect?['xPercent'],
      );
    });

    test('round-trips legacy mobile format', () {
      final track = VeilTrack(
        id: 'track-1',
        title: 'Demo',
        version: VeilTrack.mobileFormatVersion,
        createdAt: DateTime.utc(2026, 1, 1),
        updatedAt: DateTime.utc(2026, 1, 2),
        segments: [
          VeilSegment.mobileDefault(
            id: 'seg-1',
            type: VeilSegmentType.mask,
            startMs: 0,
            endMs: 1000,
            label: 'Intro',
          ),
        ],
      );

      final decoded = VeilTrackCodec.decode(VeilTrackCodec.encodeMobile(track));
      expect(decoded.id, track.id);
      expect(decoded.title, track.title);
      expect(decoded.segments.length, 1);
      expect(decoded.segments.first.label, 'Intro');
    });

    test('mobile-created track exports with desktop defaults', () {
      final track = VeilTrack.empty(title: 'Mobile Track').copyWith(
        segments: [
          VeilSegment.mobileDefault(id: 'seg-1', startMs: 0, endMs: 2000),
        ],
      );

      final exported = VeilTrackCodec.encode(track);
      final decoded = VeilTrackCodec.decode(exported);

      expect(decoded.segments.first.rect?['xPercent'], 10);
      expect(decoded.segments.first.style?['mode'], 'solid');
      expect(decoded.segments.first.source?['kind'], 'manual');
      expect(decoded.segments.first.enabled, isTrue);
      expect(exported, contains('"duration"'));
      expect(decoded.videoDurationSeconds, 0);
      expect(decoded.video?['duration'], 0);
    });

    test('export always includes required desktop video metadata', () {
      final track = VeilTrack.empty(title: 'Export Test').copyWith(
        videoName: 'clip.mp4',
        videoDurationSeconds: 120.5,
        videoFileSize: 4096,
        videoWidth: 1280,
        videoHeight: 720,
        segments: [
          VeilSegment.mobileDefault(id: 'seg-1', startMs: 0, endMs: 1000),
        ],
      );

      final exported = VeilTrackCodec.encode(track);
      final map = VeilTrackCodec.decode(exported);

      expect(exported, contains('"version": "1.6.0"'));
      expect(exported, contains('"app": "VEIL"'));
      expect(exported, contains('"items"'));
      expect(exported, contains('"trackMetadata"'));
      expect(map.video?['duration'], 120.5);
      expect(map.video?['name'], 'clip.mp4');
      expect(map.video?['fileSize'], 4096);
      expect(map.video?['resolution'], isNotNull);
      expect(map.video?['fingerprint'], isNotNull);
      expect(map.video?['fingerprint']?['method'], 'metadata-v1');
      expect(
        map.video?['fingerprint']?['value'],
        'clip.mp4|4096|120.500|1280|720',
      );
    });

    test('export uses manual-unbound when video metadata is incomplete', () {
      final track = VeilTrack.empty(title: 'Sparse Export').copyWith(
        segments: [
          VeilSegment.mobileDefault(id: 'seg-1', startMs: 0, endMs: 1000),
        ],
      );

      final exported = VeilTrackCodec.encode(track);
      final map = VeilTrackCodec.decode(exported);

      expect(map.video?['fingerprint']?['method'], 'manual-unbound');
      expect(exported, isNot(contains('mobile-metadata-v1')));
    });

    test('rejects unsupported format', () {
      expect(
        () => VeilTrackCodec.decode('{"format":"other"}'),
        throwsFormatException,
      );
    });

    group('desktop export item sanitization', () {
      Map<String, dynamic> exportMap(VeilTrack track) {
        return jsonDecode(VeilTrackCodec.encode(track)) as Map<String, dynamic>;
      }

      test('mask item has rect/style/source.kind manual only', () {
        final track = VeilTrack.empty(title: 'Mask Export').copyWith(
          segments: [
            VeilSegment.quickAction(
              id: 'mask-1',
              type: VeilSegmentType.mask,
              startMs: 5000,
              endMs: 8000,
              maskRect: const {
                'xPercent': 12.5,
                'yPercent': 70,
                'widthPercent': 50,
                'heightPercent': 15,
              },
            ),
          ],
        );

        final exported = exportMap(track);
        final item = (exported['items'] as List).single as Map<String, dynamic>;

        expect(
          item.keys,
          containsAll(['id', 'type', 'enabled', 'start', 'end']),
        );
        expect(item.keys, containsAll(['rect', 'style', 'source']));
        expect(item.keys, isNot(contains('label')));
        expect(item.keys, isNot(contains('notes')));
        expect(item['type'], 'mask');
        expect(item['start'], 5);
        expect(item['end'], 8);
        expect(item['source'], {'kind': 'manual'});
        expect(item['rect'], isA<Map<String, dynamic>>());
        expect(item['style'], isA<Map<String, dynamic>>());
        expect(item['style']?['opacity'], isA<num>());
        expect(exported['subtitleCover'], isNotNull);
        expect(exported['trackMetadata']?.keys, ['createdAt', 'updatedAt']);
        expect(
          exported['trackMetadata'],
          isNot(containsPair('title', anything)),
        );
        expect(exported['trackMetadata'], isNot(containsPair('id', anything)));
        expect(exported['globalOffsetSeconds'], 0);
        expect(VeilTrackCodec.encode(track), isNot(contains('manual-mobile')));
      });

      test('mute item omits rect/style/source', () {
        final track = VeilTrack.empty(title: 'Mute Export').copyWith(
          segments: [
            VeilSegment.quickAction(
              id: 'mute-1',
              type: VeilSegmentType.mute,
              startMs: 10000,
              endMs: 15000,
            ),
          ],
        );

        final item =
            (exportMap(track)['items'] as List).single as Map<String, dynamic>;

        expect(item['type'], 'mute');
        expect(
          item.keys,
          containsAll(['id', 'type', 'enabled', 'start', 'end']),
        );
        expect(item.keys, isNot(contains('rect')));
        expect(item.keys, isNot(contains('style')));
        expect(item.keys, isNot(contains('source')));
        expect(item.keys, isNot(contains('label')));
        expect(item.keys, isNot(contains('notes')));
      });

      test('skip item omits rect/style/source', () {
        final track = VeilTrack.empty(title: 'Skip Export').copyWith(
          segments: [
            VeilSegment.quickAction(
              id: 'skip-1',
              type: VeilSegmentType.skip,
              startMs: 20000,
              endMs: 25000,
            ),
          ],
        );

        final item =
            (exportMap(track)['items'] as List).single as Map<String, dynamic>;

        expect(item['type'], 'skip');
        expect(
          item.keys,
          containsAll(['id', 'type', 'enabled', 'start', 'end']),
        );
        expect(item.keys, isNot(contains('rect')));
        expect(item.keys, isNot(contains('style')));
        expect(item.keys, isNot(contains('source')));
      });

      test('bookmark items export with label and notes', () {
        final track = VeilTrack.empty(title: 'Bookmark Export').copyWith(
          segments: [
            VeilSegment.bookmark(
              id: 'bm-1',
              positionMs: 862_000,
              title: 'Vocabulary word',
              note: 'Important scene',
            ),
          ],
        );

        final items = exportMap(track)['items'] as List;
        expect(items, hasLength(1));
        final item = items.first as Map<String, dynamic>;
        expect(item['type'], 'bookmark');
        expect(item['start'], item['end']);
        expect(item['label'], 'Vocabulary word');
        expect(item['notes'], 'Important scene');
      });

      test('marker items are omitted from desktop export', () {
        final track = VeilTrack.empty(title: 'Mixed Export').copyWith(
          segments: [
            VeilSegment.mobileDefault(
              id: 'mask-1',
              type: VeilSegmentType.mask,
              startMs: 0,
              endMs: 1000,
            ),
            VeilSegment.mobileDefault(
              id: 'marker-1',
              type: VeilSegmentType.marker,
              startMs: 2000,
              endMs: 2000,
            ),
            VeilSegment.quickAction(
              id: 'mute-1',
              type: VeilSegmentType.mute,
              startMs: 3000,
              endMs: 4000,
            ),
          ],
        );

        final items = exportMap(track)['items'] as List;
        expect(items, hasLength(2));
        expect(items.map((item) => (item as Map)['type']), ['mask', 'mute']);
      });

      test('trackMetadata contains only createdAt and updatedAt', () {
        final track = VeilTrack.empty(title: 'Metadata Export').copyWith(
          segments: [
            VeilSegment.mobileDefault(id: 'seg-1', startMs: 0, endMs: 1000),
          ],
        );

        final metadata =
            exportMap(track)['trackMetadata'] as Map<String, dynamic>;

        expect(metadata.keys, ['createdAt', 'updatedAt']);
      });
    });
  });

  group('VeilTrackValidator', () {
    test('flags empty title and duplicate ids', () {
      final track = VeilTrack(
        id: 'track-1',
        title: '  ',
        version: VeilTrack.desktopFormatVersion,
        createdAt: DateTime.utc(2026, 1, 1),
        updatedAt: DateTime.utc(2026, 1, 1),
        segments: [
          VeilSegment.mobileDefault(id: 'dup', startMs: 0, endMs: 500),
          VeilSegment.mobileDefault(
            id: 'dup',
            type: VeilSegmentType.marker,
            startMs: 1000,
            endMs: 1000,
          ),
        ],
      );

      final errors = VeilTrackValidator.validate(track);
      expect(errors.any((e) => e.contains('title')), isTrue);
      expect(errors.any((e) => e.contains('Duplicate')), isTrue);
    });
  });
}
