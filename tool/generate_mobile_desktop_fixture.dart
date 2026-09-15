import 'dart:io';

import 'package:veil_mobile/core/veil/veil_segment.dart';
import 'package:veil_mobile/core/veil/veil_segment_type.dart';
import 'package:veil_mobile/core/veil/veil_track.dart';
import 'package:veil_mobile/core/veil/veil_track_codec.dart';

void main() {
  final track = VeilTrack.empty().copyWith(
    title: 'Mobile to Desktop interoperability',
    videoName: 'mobile-synthetic.mp4',
    videoDurationSeconds: 12.345,
    videoFileSize: 123456,
    videoWidth: 640,
    videoHeight: 360,
    globalOffsetSeconds: -0.25,
    segments: const [
      VeilSegment(
        id: 'mobile-mask',
        type: VeilSegmentType.mask,
        startMs: 1000,
        endMs: 2000,
        rect: {
          'xPercent': 10,
          'yPercent': 10,
          'widthPercent': 25,
          'heightPercent': 25,
        },
      ),
      VeilSegment(
        id: 'mobile-mute',
        type: VeilSegmentType.mute,
        startMs: 2500,
        endMs: 3500,
      ),
      VeilSegment(
        id: 'mobile-skip',
        type: VeilSegmentType.skip,
        startMs: 4000,
        endMs: 5000,
      ),
      VeilSegment(
        id: 'mobile-bookmark',
        type: VeilSegmentType.bookmark,
        startMs: 6000,
        endMs: 6000,
        label: 'Desktop reference',
      ),
    ],
  );
  final output = File('test/fixtures/mobile_writer/mobile-to-desktop.veil');
  output.parent.createSync(recursive: true);
  output.writeAsStringSync('${VeilTrackCodec.encode(track)}\n');
}
