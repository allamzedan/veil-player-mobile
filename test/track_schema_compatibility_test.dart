import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:veil_mobile/core/track_packs/track_pack_codec.dart';
import 'package:veil_mobile/core/veil/veil_segment.dart';
import 'package:veil_mobile/core/veil/veil_segment_type.dart';
import 'package:veil_mobile/core/veil/veil_track.dart';
import 'package:veil_mobile/core/veil/veil_track_codec.dart';

const _baseItemKeys = {'id', 'type', 'enabled', 'start', 'end'};
const _maskOnlyKeys = {'rect', 'style', 'source'};
const _runtimeForbiddenKeys = {'rect', 'style', 'source'};

Map<String, dynamic> _exportMap(VeilTrack track) {
  return jsonDecode(VeilTrackCodec.encode(track)) as Map<String, dynamic>;
}

Map<String, dynamic> _singleItem(VeilTrack track) {
  final items = _exportMap(track)['items'] as List;
  expect(items, hasLength(1));
  return items.single as Map<String, dynamic>;
}

String _readExample(String name) {
  return File('docs/examples/$name').readAsStringSync();
}

void main() {
  group('documented export shapes', () {
    test('mask item matches documented shape', () {
      final item = _singleItem(
        VeilTrack.empty(title: 'Mask').copyWith(
          segments: [
            VeilSegment.quickAction(
              id: 'mask-doc',
              type: VeilSegmentType.mask,
              startMs: 8000,
              endMs: 13000,
            ),
          ],
        ),
      );

      expect(item.keys.toSet(), _baseItemKeys.union(_maskOnlyKeys));
      expect(item['type'], 'mask');
      expect(item['source'], {'kind': 'manual'});
      expect(item['rect'], isA<Map<String, dynamic>>());
      expect(item['style'], isA<Map<String, dynamic>>());
      expect(item['end'], greaterThan(item['start'] as num));
    });

    test('mute item matches documented shape', () {
      final item = _singleItem(
        VeilTrack.empty(title: 'Mute').copyWith(
          segments: [
            VeilSegment.quickAction(
              id: 'mute-doc',
              type: VeilSegmentType.mute,
              startMs: 25_000,
              endMs: 28_000,
            ),
          ],
        ),
      );

      expect(item.keys.toSet(), _baseItemKeys);
      expect(item.keys.toSet().intersection(_runtimeForbiddenKeys), isEmpty);
      expect(item['type'], 'mute');
    });

    test('skip item matches documented shape', () {
      final item = _singleItem(
        VeilTrack.empty(title: 'Skip').copyWith(
          segments: [
            VeilSegment.quickAction(
              id: 'skip-doc',
              type: VeilSegmentType.skip,
              startMs: 70_000,
              endMs: 75_000,
            ),
          ],
        ),
      );

      expect(item.keys.toSet(), _baseItemKeys);
      expect(item.keys.toSet().intersection(_runtimeForbiddenKeys), isEmpty);
      expect(item['type'], 'skip');
    });

    test('bookmark item matches documented shape', () {
      final item = _singleItem(
        VeilTrack.empty(title: 'Bookmark').copyWith(
          segments: [
            VeilSegment.bookmark(
              id: 'bm-doc',
              positionMs: 862_000,
              title: 'Vocabulary word',
              note: 'Important scene',
            ),
          ],
        ),
      );

      expect(item.keys.toSet(), _baseItemKeys.union({'label', 'notes'}));
      expect(item.keys.toSet().intersection(_runtimeForbiddenKeys), isEmpty);
      expect(item['type'], 'bookmark');
      expect(item['start'], item['end']);
      expect(item['label'], 'Vocabulary word');
      expect(item['notes'], 'Important scene');
    });
  });

  group('example documents', () {
    test('sample_track.json decodes with runtime items', () {
      final track = VeilTrackCodec.decode(_readExample('sample_track.json'));

      expect(track.segments, hasLength(3));
      expect(track.segments.map((s) => s.type).toSet(), {
        VeilSegmentType.mask,
        VeilSegmentType.mute,
        VeilSegmentType.skip,
      });
    });

    test('sample_track_with_bookmark.json decodes bookmarks', () {
      final track = VeilTrackCodec.decode(
        _readExample('sample_track_with_bookmark.json'),
      );

      final bookmarks = track.segments
          .where((s) => s.type == VeilSegmentType.bookmark)
          .toList();
      expect(bookmarks, hasLength(2));
      expect(bookmarks.first.label, 'Vocabulary word');
      expect(bookmarks.first.startMs, bookmarks.first.endMs);
    });

    test('sample_pack.veilpack.json decodes both embedded tracks', () {
      final pack = TrackPackCodec.decode(
        _readExample('sample_pack.veilpack.json'),
      );

      expect(pack.tracks, hasLength(2));
      expect(pack.tracks.first.decodeTrack(), isNotNull);
      expect(
        pack.tracks[1].decodeTrack()?.segments.first.type,
        VeilSegmentType.bookmark,
      );
    });
  });

  group('forward compatibility', () {
    test('unsupported item type import does not crash', () {
      const json = '''
{
  "version": "1.4.0",
  "app": "VEIL",
  "appVersion": "VEIL Mobile 0.2.0",
  "exportedAt": "2026-05-19T12:00:00.000Z",
  "video": {
    "name": "sample.mp4",
    "duration": 120,
    "fileSize": 0,
    "resolution": { "width": 1280, "height": 720 },
    "fingerprint": { "method": "metadata-v1", "value": "sample.mp4|0|120.000|1280|720" }
  },
  "globalOffsetSeconds": 0,
  "trackMetadata": {
    "createdAt": "2026-05-19T10:00:00.000Z",
    "updatedAt": "2026-05-19T10:00:00.000Z"
  },
  "items": [
    {
      "id": "valid-mute",
      "type": "mute",
      "enabled": true,
      "start": 1,
      "end": 2
    },
    {
      "id": "future-type",
      "type": "annotation",
      "enabled": true,
      "start": 5,
      "end": 6,
      "label": "Unknown future item"
    },
    {
      "id": "valid-bookmark",
      "type": "bookmark",
      "enabled": true,
      "start": 10,
      "end": 10,
      "label": "Kept bookmark"
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

      final track = VeilTrackCodec.decode(json);
      expect(track.segments, hasLength(2));
      expect(track.segments.map((segment) => segment.id), [
        'valid-mute',
        'valid-bookmark',
      ]);
      expect(
        track.segments.any((segment) => segment.id == 'future-type'),
        isFalse,
      );
      final roundTrip =
          jsonDecode(VeilTrackCodec.encode(track)) as Map<String, dynamic>;
      expect(
        (roundTrip['items'] as List).any((item) => item['id'] == 'future-type'),
        isTrue,
      );
    });

    test('desktop root includes documented top-level keys', () {
      final exported = _exportMap(
        VeilTrack.empty(title: 'Keys').copyWith(
          segments: [
            VeilSegment.quickAction(
              type: VeilSegmentType.mute,
              startMs: 0,
              endMs: 1000,
            ),
          ],
        ),
      );

      expect(
        exported.keys.toSet(),
        containsAll({
          'version',
          'app',
          'appVersion',
          'exportedAt',
          'video',
          'globalOffsetSeconds',
          'trackMetadata',
          'items',
          'subtitleCover',
        }),
      );
    });
  });
}
