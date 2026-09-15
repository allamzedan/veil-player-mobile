import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:veil_mobile/core/veil/veil_runtime_evaluator.dart';
import 'package:veil_mobile/core/veil/veil_segment.dart';
import 'package:veil_mobile/core/veil/veil_segment_type.dart';
import 'package:veil_mobile/core/veil/veil_track.dart';
import 'package:veil_mobile/core/veil/veil_track_codec.dart';

const _base = <String, dynamic>{
  'version': '1.6.0',
  'app': 'VEIL',
  'video': {
    'name': 'synthetic.mp4',
    'duration': 30,
    'fileSize': 1024,
    'resolution': {'width': 320, 'height': 180},
    'fingerprint': {
      'method': 'metadata-v1',
      'value': 'synthetic.mp4|1024|30.000|320|180',
    },
  },
  'globalOffsetSeconds': 0,
  'trackMetadata': <String, dynamic>{},
  'items': <dynamic>[],
};

void main() {
  test('reader tolerates duplicate item IDs while writer rejects them', () {
    final document = _document([
      {'id': 'same', 'type': 'mute', 'start': 1, 'end': 2},
      {'id': 'same', 'type': 'skip', 'start': 3, 'end': 4},
    ]);
    final parsed = VeilTrackCodec.parseCanonical(jsonEncode(document));
    expect(parsed.status, VeilParseStatus.accept);
    expect(parsed.track!.segments, hasLength(2));
    expect(() => VeilTrackCodec.encode(parsed.track!), throwsFormatException);
  });

  test('isolated future item is inert and known item still executes', () {
    final document = _document([
      {
        'id': 'future',
        'type': 'future-lighting',
        'payload': {'url': 'file:///x'},
      },
      {'id': 'mute', 'type': 'mute', 'start': 1, 'end': 2},
    ]);
    final parsed = VeilTrackCodec.parseCanonical(jsonEncode(document));
    expect(parsed.status, VeilParseStatus.acceptPartial);
    final active = VeilRuntimeEvaluator.activeSegmentsAt(parsed.track, 1500);
    expect(VeilRuntimeEvaluator.hasActiveMute(active), isTrue);
    expect(active.map((item) => item.id), ['mute']);
    final output = jsonDecode(VeilTrackCodec.encode(parsed.track!)) as Map;
    expect((output['items'] as List).first['type'], 'future-lighting');
  });

  test('duplicate JSON members reject canonically', () {
    const source =
        '{"version":"1.6.0","app":"VEIL","app":"VEIL",'
        '"video":{},"globalOffsetSeconds":0,"items":[]}';
    expect(
      VeilTrackCodec.parseCanonical(source).status,
      VeilParseStatus.rejectDocument,
    );
  });

  test('metadata-v1 renders null and half-up millisecond rounding', () {
    final track = VeilTrack.empty().copyWith(
      videoName: ' exact name.mp4 ',
      videoDurationSeconds: 120.1235,
      videoFileSize: null,
      videoWidth: 1920.0,
      videoHeight: 1080.0,
    );
    final output = jsonDecode(VeilTrackCodec.encode(track)) as Map;
    final video = output['video'] as Map;
    expect(video['name'], ' exact name.mp4 ');
    expect(video['fileSize'], isNull);
    expect(
      (video['fingerprint'] as Map)['value'],
      ' exact name.mp4 |null|120.124|1920|1080',
    );
    expect(
      VeilTrackCodec.classifyMediaIdentity(
        track: VeilTrackCodec.decode(jsonEncode(output)),
        fileName: r'C:\media\ exact name.mp4 ',
        fileSize: null,
        durationSeconds: 120.1235,
        width: 1920,
        height: 1080,
      ),
      VeilMediaIdentityStatus.match,
    );
  });

  test('Desktop manual-unbound empty name remains canonical', () {
    final document = _document(const []);
    document['video'] = {
      'binding': 'unbound',
      'name': '',
      'duration': 3,
      'fileSize': null,
      'resolution': {'width': 0, 'height': 0},
      'fingerprint': {'method': 'manual-unbound', 'value': 'manual-unbound'},
    };
    final result = VeilTrackCodec.parseCanonical(jsonEncode(document));
    expect(result.status, VeilParseStatus.accept);
    final saved = jsonDecode(VeilTrackCodec.encode(result.track!)) as Map;
    final video = saved['video'] as Map;
    expect(video['name'], '');
    expect(video['binding'], 'unbound');
    expect(video['fingerprint'], {
      'method': 'manual-unbound',
      'value': 'manual-unbound',
    });
  });

  test('style-less Mask is valid and uses runtime defaults', () {
    final document = _document([
      {
        'id': 'mask',
        'type': 'mask',
        'start': 1,
        'end': 2,
        'rect': {
          'xPercent': 0,
          'yPercent': 0,
          'widthPercent': 10,
          'heightPercent': 10,
        },
      },
    ]);
    final parsed = VeilTrackCodec.parseCanonical(jsonEncode(document));
    expect(parsed.status, VeilParseStatus.accept);
    expect(
      VeilMaskStyle.opacityFromStyle(parsed.track!.segments.single.style),
      1,
    );
  });

  test('writer preserves nested additive fields on ordinary round trip', () {
    final document = _document([
      {
        'id': 'mask',
        'type': 'mask',
        'start': 1,
        'end': 2,
        'futureItemField': {'kept': true},
        'rect': {
          'xPercent': 0,
          'yPercent': 0,
          'widthPercent': 10,
          'heightPercent': 10,
          'futureRectField': 'kept',
        },
        'style': {
          'mode': 'solid',
          'color': '#000000',
          'futureStyleField': 'kept',
        },
        'source': {'kind': 'manual', 'futureSourceField': 'kept'},
      },
    ]);
    document['id'] = 'future-root-id';
    document['title'] = 'future root title';
    document['video'] = {
      ...Map<String, dynamic>.from(document['video']! as Map),
      'futureVideoField': 'kept',
      'resolution': {
        'width': 320,
        'height': 180,
        'futureResolutionField': 'kept',
      },
      'fingerprint': {
        'method': 'metadata-v1',
        'value': 'synthetic.mp4|1024|30.000|320|180',
        'futureFingerprintField': 'kept',
      },
    };
    document['trackMetadata'] = {'futureMetadataField': 'kept'};
    document['subtitleCover'] = {
      'mode': 'show',
      'futureCoverField': 'kept',
      'regionRect': {
        'xPercent': 10,
        'yPercent': 78,
        'widthPercent': 80,
        'heightPercent': 18,
        'futureCoverRectField': 'kept',
      },
    };

    final parsed = VeilTrackCodec.parseCanonical(jsonEncode(document));
    expect(parsed.status, VeilParseStatus.accept);
    final saved = jsonDecode(VeilTrackCodec.encode(parsed.track!)) as Map;
    expect(saved['id'], 'future-root-id');
    expect(saved['title'], 'future root title');
    final video = saved['video'] as Map;
    expect(video['futureVideoField'], 'kept');
    expect((video['resolution'] as Map)['futureResolutionField'], 'kept');
    expect((video['fingerprint'] as Map)['futureFingerprintField'], 'kept');
    expect((saved['trackMetadata'] as Map)['futureMetadataField'], 'kept');
    final mask = (saved['items'] as List).single as Map;
    expect(mask['futureItemField'], {'kept': true});
    expect((mask['rect'] as Map)['futureRectField'], 'kept');
    expect((mask['style'] as Map)['futureStyleField'], 'kept');
    expect((mask['source'] as Map)['futureSourceField'], 'kept');
    expect((saved['subtitleCover'] as Map)['futureCoverField'], 'kept');
    expect(
      ((saved['subtitleCover'] as Map)['regionRect']
          as Map)['futureCoverRectField'],
      'kept',
    );
  });

  test(
    'known Profile structures validate and legacy collections normalize',
    () {
      Map<String, dynamic> cloneBase() =>
          jsonDecode(jsonEncode(_document(const []))) as Map<String, dynamic>;

      final malformedMetadata = cloneBase();
      malformedMetadata['trackMetadata'] = {
        'tags': ['ok', 3],
      };
      expect(
        VeilTrackCodec.parseCanonical(jsonEncode(malformedMetadata)).status,
        VeilParseStatus.rejectDocument,
      );

      final malformedCover = cloneBase();
      malformedCover['subtitleCover'] = {'mode': 'future-mode'};
      expect(
        VeilTrackCodec.parseCanonical(jsonEncode(malformedCover)).status,
        VeilParseStatus.rejectDocument,
      );

      final normalized = cloneBase();
      normalized['items'] = [
        {'id': 'known', 'type': 'mute', 'start': 1, 'end': 2},
      ];
      normalized['groups'] = [
        {
          'id': 'group',
          'label': '  ',
          'itemIds': ['known', 'missing'],
          'colorToken': 'future-color',
        },
      ];
      normalized['anchors'] = [
        {'id': 'valid', 'time': 1, 'label': '  Point  ', 'kind': 'manual'},
        {'id': 'dropped', 'time': -1},
      ];
      final result = VeilTrackCodec.parseCanonical(jsonEncode(normalized));
      expect(result.status, VeilParseStatus.accept);
      final saved = jsonDecode(VeilTrackCodec.encode(result.track!)) as Map;
      expect(saved['groups'], [
        {
          'id': 'group',
          'label': 'Group',
          'itemIds': ['known'],
        },
      ]);
      expect(saved['anchors'], [
        {'id': 'valid', 'time': 1, 'label': 'Point', 'kind': 'manual'},
      ]);
    },
  );

  test('Skip target conversion handles offsets and known/unknown duration', () {
    VeilTrack track(double offset) => VeilTrack.empty().copyWith(
      globalOffsetSeconds: offset,
      segments: [
        const VeilSegment(
          id: 'skip',
          type: VeilSegmentType.skip,
          startMs: 10000,
          endMs: 20000,
        ),
      ],
    );
    final positive = track(3);
    final positiveCluster = VeilRuntimeEvaluator.activeSkipClusterAt(
      positive,
      7000,
    )!;
    expect(
      VeilRuntimeEvaluator.skipHostTargetMs(
        track: positive,
        cluster: positiveCluster,
      ),
      17000,
    );
    expect(
      VeilRuntimeEvaluator.skipHostTargetMs(
        track: positive,
        cluster: positiveCluster,
        hostDurationMs: 15000,
      ),
      15000,
    );
    final negative = track(-3);
    final negativeCluster = VeilRuntimeEvaluator.activeSkipClusterAt(
      negative,
      13000,
    )!;
    expect(
      VeilRuntimeEvaluator.skipHostTargetMs(
        track: negative,
        cluster: negativeCluster,
      ),
      23000,
    );
  });
}

Map<String, dynamic> _document(List<dynamic> items) => {
  ..._base,
  'video': Map<String, dynamic>.from(_base['video']! as Map),
  'trackMetadata': <String, dynamic>{},
  'items': items,
};
