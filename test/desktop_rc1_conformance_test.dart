import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:veil_mobile/core/veil/veil_runtime_evaluator.dart';
import 'package:veil_mobile/core/veil/veil_segment.dart';
import 'package:veil_mobile/core/veil/veil_segment_type.dart';
import 'package:veil_mobile/core/veil/veil_track.dart';
import 'package:veil_mobile/core/veil/veil_track_codec.dart';

void main() {
  test('consumes every supplied Desktop RC1 fixture', () {
    const expected = {
      'rc1-empty-local.veil': '',
      'rc1-mask.veil': 'mask',
      'rc1-mute.veil': 'mute',
      'rc1-overlapping-mutes.veil': 'mute,mute',
      'rc1-skip.veil': 'skip',
      'rc1-bookmark.veil': 'bookmark',
      'rc1-bookmark-unicode.veil': 'bookmark',
      'rc1-disabled-items.veil': 'mask,mute,skip',
      'rc1-global-offset.veil': 'mute',
      'rc1-overlapping-skips.veil': 'skip,skip',
      'rc1-adjacent-skips.veil': 'skip,skip',
    };
    for (final entry in expected.entries) {
      final track = VeilTrackCodec.decode(
        File('test/fixtures/desktop_rc1/${entry.key}').readAsStringSync(),
      );
      expect(track.version, '1.6.0', reason: entry.key);
      expect(track.segments.map((s) => s.type.toJson()).join(','), entry.value);
      expect(track.subtitleCover?['mode'], 'show');
    }
  });

  test('RC1 accepts exact versions and rejects future/malformed versions', () {
    for (final version in VeilTrack.supportedDesktopFormatVersions) {
      expect(VeilTrackCodec.tryDecode(_document(version)), isNotNull);
    }
    for (final version in ['1.6.1', '1.7.0', '2.0.0', null, 1.6]) {
      final map = jsonDecode(_document('1.6.0')) as Map<String, dynamic>;
      map['version'] = version;
      expect(VeilTrackCodec.tryDecode(jsonEncode(map)), isNull);
    }
  });

  test('RC1 inclusive boundaries and global offset', () {
    final track = VeilTrack.empty().copyWith(
      globalOffsetSeconds: 10,
      segments: [
        VeilSegment.mobileDefault(
          type: VeilSegmentType.mute,
          startMs: 20_000,
          endMs: 30_000,
        ),
      ],
    );
    for (final position in [
      9.999999,
      10.0,
      10.000001,
      19.999999,
      20.0,
      20.000001,
    ]) {
      final ms = (position * 1000).round();
      expect(
        VeilRuntimeEvaluator.hasActiveMute(
          VeilRuntimeEvaluator.activeSegmentsAt(track, ms),
        ),
        ms >= 10_000 && ms <= 20_000,
      );
    }
    expect(
      VeilRuntimeEvaluator.hasActiveMute(
        VeilRuntimeEvaluator.activeSegmentsAt(track, 20_001),
      ),
      isFalse,
    );
  });
}

String _document(String version) => jsonEncode({
  'version': version,
  'app': 'VEIL',
  'appVersion': 'Desktop',
  'exportedAt': '2026-01-01T00:00:00.000Z',
  'video': {
    'name': 'sample.mp4',
    'duration': 120,
    'fileSize': 1,
    'resolution': {'width': 1280, 'height': 720},
    'fingerprint': {
      'method': 'metadata-v1',
      'value': 'sample.mp4|1|120.000|1280|720',
    },
  },
  'globalOffsetSeconds': 0,
  'trackMetadata': {},
  'items': [],
});
