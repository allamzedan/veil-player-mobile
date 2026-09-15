import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:veil_mobile/core/veil/veil_runtime_evaluator.dart';
import 'package:veil_mobile/core/veil/veil_segment_type.dart';
import 'package:veil_mobile/core/veil/veil_track_codec.dart';

const fixtureRoot = 'test/fixtures/desktop_rc2';

void main() {
  test('Desktop RC2 A-O fixtures have their declared Mobile outcomes', () {
    final expected =
        jsonDecode(File('$fixtureRoot/expected.json').readAsStringSync())
            as Map<String, dynamic>;
    expect(expected['desktopHead'], 'e99f262ae9ea172b495a231794c38f1025910728');
    final outcomes = expected['expected'] as Map<String, dynamic>;
    for (final entry in outcomes.entries) {
      final result = VeilTrackCodec.parseCanonical(
        File('$fixtureRoot/${entry.key}').readAsStringSync(),
      );
      final expectedStatus = (entry.value as String).split(';').first;
      expect(result.status.wireName, expectedStatus, reason: entry.key);
    }
  });

  test('unknown future item is inert beside executing known Mute', () {
    final result = _parse('L-unknown-future-beside-known.veil');
    expect(result.status, VeilParseStatus.acceptPartial);
    final active = VeilRuntimeEvaluator.activeSegmentsAt(result.track, 1500);
    expect(VeilRuntimeEvaluator.hasActiveMute(active), isTrue);
    expect(active.map((segment) => segment.id), ['known-l']);
    expect(result.track!.segments, hasLength(1));
  });

  test('disabled known item types never participate in runtime', () {
    final track = _parse('H-disabled-items.veil').track!;
    for (final hostMs in [1000, 2000, 5000]) {
      expect(VeilRuntimeEvaluator.activeSegmentsAt(track, hostMs), isEmpty);
      expect(VeilRuntimeEvaluator.activeSkipClusterAt(track, hostMs), isNull);
    }
  });

  test('real Desktop-to-Mobile synthetic media timeline matches', () {
    final media = File('$fixtureRoot/synthetic-veil-6s.wav').readAsBytesSync();
    expect(media, hasLength(96044));
    expect(utf8.decode(media.sublist(0, 4)), 'RIFF');
    expect(utf8.decode(media.sublist(8, 12)), 'WAVE');
    final bytes = ByteData.sublistView(Uint8List.fromList(media));
    final sampleRate = bytes.getUint32(24, Endian.little);
    final byteRate = bytes.getUint32(28, Endian.little);
    final dataBytes = bytes.getUint32(40, Endian.little);
    expect(sampleRate, 8000);
    expect(dataBytes / byteRate, 6);

    final result = _parse('real-desktop-to-mobile.veil');
    expect(result.status, VeilParseStatus.accept);
    final track = result.track!;
    expect(
      VeilTrackCodec.classifyMediaIdentity(
        track: track,
        fileName: '$fixtureRoot/synthetic-veil-6s.wav',
        fileSize: media.length,
        durationSeconds: dataBytes / byteRate,
        width: 0,
        height: 0,
      ),
      VeilMediaIdentityStatus.match,
    );

    final maskAtHostHalfSecond = VeilRuntimeEvaluator.activeSegmentsAt(
      track,
      500,
    );
    expect(
      VeilRuntimeEvaluator.activeMasks(
        maskAtHostHalfSecond,
      ).map((segment) => segment.id),
      ['real-mask'],
    );
    final muteAtHostOneAndHalf = VeilRuntimeEvaluator.activeSegmentsAt(
      track,
      1500,
    );
    expect(VeilRuntimeEvaluator.hasActiveMute(muteAtHostOneAndHalf), isTrue);
    expect(
      track.segments
          .where((segment) => segment.type == VeilSegmentType.bookmark)
          .single
          .startMs,
      2500,
    );
    expect(
      VeilRuntimeEvaluator.activeSegmentsAt(
        track,
        2000,
      ).where((segment) => segment.type == VeilSegmentType.bookmark),
      isEmpty,
    );
    final skip = VeilRuntimeEvaluator.activeSkipClusterAt(track, 3000)!;
    expect(
      VeilRuntimeEvaluator.skipHostTargetMs(
        track: track,
        cluster: skip,
        hostDurationMs: 6000,
      ),
      4000,
    );
    expect(
      VeilRuntimeEvaluator.hasActiveMute(
        VeilRuntimeEvaluator.activeSegmentsAt(track, 5000),
      ),
      isFalse,
    );
  });
}

VeilParseResult _parse(String name) => VeilTrackCodec.parseCanonical(
  File('$fixtureRoot/$name').readAsStringSync(),
);
