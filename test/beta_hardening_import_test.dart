import 'package:flutter_test/flutter_test.dart';
import 'package:veil_mobile/core/veil/veil_track_codec.dart';
import 'package:veil_mobile/shared/utils/veil_error_messages.dart';

void main() {
  group('Import resilience', () {
    test('rejects invalid JSON with friendly message', () {
      expect(
        () => VeilTrackCodec.decode('not json at all'),
        throwsA(isA<FormatException>()),
      );
      expect(
        VeilErrorMessages.fromException(const FormatException('Invalid JSON.')),
        'Invalid JSON.',
      );
      expect(VeilTrackCodec.tryDecode('{bad'), isNull);
    });

    test('rejects non-object JSON roots', () {
      expect(VeilTrackCodec.tryDecode('[]'), isNull);
      expect(VeilTrackCodec.tryDecode('"track"'), isNull);
    });

    test('rejects unsupported format', () {
      expect(
        VeilTrackCodec.tryDecode('{"format":"unknown","version":"99"}'),
        isNull,
      );
    });

    test('rejects desktop tracks with future schema version', () {
      const json = '''
{
  "version": "99.0.0",
  "app": "VEIL",
  "appVersion": "Desktop",
  "exportedAt": "2026-01-01T00:00:00.000Z",
  "video": {"name":"sample.mp4","duration":120,"fileSize":1,"resolution":{"width":1280,"height":720},"fingerprint":{"method":"metadata-v1","value":"sample.mp4|1|120.000|1280|720"}},
  "globalOffsetSeconds": 0,
  "items": [],
  "trackMetadata": {
    "createdAt": "2026-01-01T00:00:00.000Z",
    "updatedAt": "2026-01-01T00:00:00.000Z"
  }
}
''';
      expect(VeilTrackCodec.tryDecode(json), isNull);
    });

    test('preserves unknown top-level fields in rawExtra', () {
      const json = '''
{
  "version": "1.4.0",
  "app": "VEIL",
  "appVersion": "Desktop",
  "exportedAt": "2026-01-01T00:00:00.000Z",
  "video": {"name":"sample.mp4","duration":120,"fileSize":1,"resolution":{"width":1280,"height":720},"fingerprint":{"method":"metadata-v1","value":"sample.mp4|1|120.000|1280|720"}},
  "globalOffsetSeconds": 0,
  "items": [],
  "trackMetadata": {
    "createdAt": "2026-01-01T00:00:00.000Z",
    "updatedAt": "2026-01-01T00:00:00.000Z"
  },
  "futureFeature": {"enabled": true}
}
''';
      final track = VeilTrackCodec.decode(json);
      expect(track.rawExtra?['futureFeature'], {'enabled': true});
    });

    test('skips malformed desktop items and keeps valid segments', () {
      const json = '''
{
  "version": "1.4.0",
  "app": "VEIL",
  "appVersion": "Desktop",
  "exportedAt": "2026-01-01T00:00:00.000Z",
  "video": {"name":"sample.mp4","duration":120,"fileSize":1,"resolution":{"width":1280,"height":720},"fingerprint":{"method":"metadata-v1","value":"sample.mp4|1|120.000|1280|720"}},
  "globalOffsetSeconds": 0,
  "items": [
    {"id": "bad", "type": "unknown", "start": 0, "end": 1},
    {"id": "good", "type": "mask", "start": 1, "end": 2, "enabled": true}
  ],
  "trackMetadata": {
    "createdAt": "2026-01-01T00:00:00.000Z",
    "updatedAt": "2026-01-01T00:00:00.000Z"
  }
}
''';
      expect(() => VeilTrackCodec.decode(json), throwsFormatException);
    });

    test('mobile import tolerates missing metadata and bad segments', () {
      const json = '''
{
  "format": "veil.track",
  "segments": [
    {"type": "mask", "startMs": 0, "endMs": 1000},
    {"type": "not-a-type", "startMs": 0, "endMs": 1000},
    "not-an-object"
  ]
}
''';
      final track = VeilTrackCodec.decode(json);
      expect(track.segments, hasLength(1));
      expect(track.id, isNotEmpty);
    });

    test('mobile import tolerates missing createdAt and updatedAt', () {
      const json = '''
{
  "format": "veil.track",
  "title": "Partial",
  "segments": []
}
''';
      final track = VeilTrackCodec.decode(json);
      expect(track.title, 'Partial');
      expect(track.createdAt, isNotNull);
      expect(track.updatedAt, isNotNull);
    });
  });
}
