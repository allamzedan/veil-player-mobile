import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:veil_mobile/core/storage/track_pack_storage_service.dart';
import 'package:veil_mobile/core/track_packs/track_pack.dart';
import 'package:veil_mobile/core/track_packs/track_pack_codec.dart';
import 'package:veil_mobile/core/track_packs/track_pack_summary.dart';
import 'package:veil_mobile/core/veil/veil_segment.dart';
import 'package:veil_mobile/core/veil/veil_segment_type.dart';
import 'package:veil_mobile/core/veil/veil_track.dart';
import 'package:veil_mobile/core/veil/veil_track_codec.dart';

VeilTrack _sampleTrack({
  String id = 'track-1',
  String title = 'Sample Track',
  List<VeilSegment> segments = const [],
}) {
  final now = DateTime.utc(2026, 5, 19, 12);
  return VeilTrack(
    id: id,
    title: title,
    version: '1.0.0',
    createdAt: now,
    updatedAt: now,
    segments: segments,
    videoName: 'sample.mp4',
    videoDurationSeconds: 120,
    video: const {
      'name': 'sample.mp4',
      'duration': 120,
      'fingerprint': {'method': 'metadata-v1'},
    },
  );
}

TrackPack _samplePack({List<TrackPackTrack> tracks = const []}) {
  return TrackPack.create(
    id: 'pack-1',
    title: 'Family Safe Collection',
    description: 'Curated tracks for family viewing.',
    author: 'VEIL Mobile',
    tags: const ['family', 'safe'],
    tracks: tracks,
  );
}

void main() {
  group('TrackPackCodec', () {
    test('encodes and decodes a pack with embedded track JSON', () {
      final track = _sampleTrack(
        segments: [
          VeilSegment(
            id: 'mask-1',
            type: VeilSegmentType.mask,
            startMs: 1000,
            endMs: 3000,
          ),
        ],
      );
      final pack = _samplePack(
        tracks: [TrackPackTrack.fromVeilTrack(track)],
      );

      final encoded = TrackPackCodec.encode(pack);
      expect(encoded, contains('"format": "veil.pack"'));

      final decoded = TrackPackCodec.decode(encoded);
      expect(decoded.id, pack.id);
      expect(decoded.title, pack.title);
      expect(decoded.description, pack.description);
      expect(decoded.author, pack.author);
      expect(decoded.tags, pack.tags);
      expect(decoded.tracks, hasLength(1));
      expect(decoded.tracks.first.trackTitle, track.title);

      final roundTripTrack = decoded.tracks.first.decodeTrack();
      expect(roundTripTrack, isNotNull);
      expect(decoded.tracks.first.trackTitle, track.title);
      expect(roundTripTrack!.segments, hasLength(1));
    });

    test('accepts trackJson stored as a JSON string', () {
      final trackJson = VeilTrackCodec.encode(_sampleTrack(title: 'String JSON'));
      final source = jsonEncode({
        'format': TrackPackCodec.formatId,
        'version': '1.0.0',
        'pack': {
          'id': 'pack-string',
          'title': 'String JSON Pack',
          'description': '',
          'author': 'Tester',
          'createdAt': '2026-05-19T12:00:00.000Z',
          'updatedAt': '2026-05-19T12:00:00.000Z',
          'tags': [],
          'tracks': [
            {
              'trackTitle': 'String JSON',
              'trackJson': trackJson,
            },
          ],
        },
      });

      final decoded = TrackPackCodec.decode(source);
      expect(decoded.tracks, hasLength(1));
      expect(decoded.tracks.first.trackTitle, 'String JSON');
      expect(decoded.tracks.first.decodeTrack(), isNotNull);
    });

    test('skips malformed pack tracks during import', () {
      final validTrack = TrackPackTrack.fromVeilTrack(_sampleTrack(id: 'valid'));
      final source = jsonEncode({
        'format': TrackPackCodec.formatId,
        'version': '1.0.0',
        'pack': {
          'id': 'pack-mixed',
          'title': 'Mixed Pack',
          'description': '',
          'author': 'Tester',
          'createdAt': '2026-05-19T12:00:00.000Z',
          'updatedAt': '2026-05-19T12:00:00.000Z',
          'tags': [],
          'tracks': [
            {'trackTitle': 'Broken'},
            _trackJsonMap(validTrack),
          ],
        },
      });

      final decoded = TrackPackCodec.decode(source);
      expect(decoded.tracks, hasLength(1));
      expect(decoded.tracks.first.trackTitle, validTrack.trackTitle);
    });

    test('tryDecode returns null for unsupported format', () {
      expect(
        TrackPackCodec.tryDecode('{"format":"other","pack":{}}'),
        isNull,
      );
    });
  });

  group('TrackPackSummary', () {
    test('fromPack exposes preview metadata', () {
      final pack = _samplePack(
        tracks: [
          TrackPackTrack.fromVeilTrack(
            _sampleTrack(
              segments: [
                VeilSegment(
                  id: 'mask-1',
                  type: VeilSegmentType.mask,
                  startMs: 0,
                  endMs: 1000,
                ),
                VeilSegment(
                  id: 'mute-1',
                  type: VeilSegmentType.mute,
                  startMs: 2000,
                  endMs: 3000,
                ),
                VeilSegment(
                  id: 'skip-1',
                  type: VeilSegmentType.skip,
                  startMs: 4000,
                  endMs: 5000,
                ),
              ],
            ),
          ),
        ],
      );

      final summary = TrackPackSummary.fromPack(pack);
      expect(summary.title, 'Family Safe Collection');
      expect(summary.author, 'VEIL Mobile');
      expect(summary.trackCount, 1);
      expect(summary.tags, ['family', 'safe']);

      final previews = trackPackTrackPreviews(pack);
      expect(previews, hasLength(1));
      expect(previews.first.decodeSucceeded, isTrue);
      expect(previews.first.summary?.maskCount, 1);
      expect(previews.first.summary?.muteCount, 1);
      expect(previews.first.summary?.skipCount, 1);
    });

    test('uses default untitled title when pack title is blank', () {
      final summary = TrackPackSummary.fromPack(
        TrackPack.create(title: '   '),
      );
      expect(summary.title, TrackPack.defaultUntitledTitle);
    });
  });

  group('TrackPackStorageService', () {
    test('imports and exports packs locally', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = TrackPackStorageService(prefs);
      final pack = _samplePack(
        tracks: [TrackPackTrack.fromVeilTrack(_sampleTrack())],
      );

      await storage.savePackLocally(pack);
      final loaded = await storage.loadSavedPacks();
      expect(loaded, hasLength(1));
      expect(loaded.first.title, pack.title);

      final exported = storage.exportPackJson(pack);
      final imported = storage.importPackFromJson(exported);
      expect(imported.id, pack.id);
      expect(imported.tracks, hasLength(1));

      await storage.deletePack(pack.id);
      expect(await storage.loadSavedPacks(), isEmpty);
    });
  });
}

Map<String, dynamic> _trackJsonMap(TrackPackTrack track) {
  return {
    'trackTitle': track.trackTitle,
    'trackJson': jsonDecode(track.trackJson),
  };
}
