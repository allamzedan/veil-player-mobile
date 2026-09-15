import 'package:flutter_test/flutter_test.dart';
import 'package:veil_mobile/core/veil/veil_track.dart';
import 'package:veil_mobile/core/veil/veil_track_codec.dart';

void main() {
  group('Video metadata resilience', () {
    test('exports tracks bound to vertical and landscape resolutions', () {
      final vertical = VeilTrack.empty().copyWith(
        videoName: 'vertical.mp4',
        videoWidth: 1080,
        videoHeight: 1920,
        videoDurationSeconds: 12.5,
      );
      final landscape = VeilTrack.empty().copyWith(
        videoName: 'landscape.mp4',
        videoWidth: 3840,
        videoHeight: 2160,
        videoDurationSeconds: 7200,
      );
      final tiny = VeilTrack.empty().copyWith(
        videoName: 'tiny.mp4',
        videoWidth: 64,
        videoHeight: 64,
        videoDurationSeconds: 0.5,
      );

      for (final track in [vertical, landscape, tiny]) {
        final json = VeilTrackCodec.encode(track);
        final restored = VeilTrackCodec.decode(json);
        expect(restored.videoWidth, track.videoWidth);
        expect(restored.videoHeight, track.videoHeight);
        expect(restored.videoDurationSeconds, track.videoDurationSeconds);
      }
    });

    test('exports tracks with zero-duration and missing audio metadata', () {
      final track = VeilTrack.empty().copyWith(
        videoName: 'silent.mp4',
        videoDurationSeconds: 0,
        videoFileSize: 0,
      );

      final restored = VeilTrackCodec.decode(VeilTrackCodec.encode(track));
      expect(restored.videoDurationSeconds, 0);
      expect(restored.videoFileSize, 0);
    });
  });
}
