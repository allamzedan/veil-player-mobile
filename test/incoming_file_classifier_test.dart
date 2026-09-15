import 'package:flutter_test/flutter_test.dart';
import 'package:veil_mobile/app/incoming_file_classifier.dart';

void main() {
  group('IncomingFileClassifier', () {
    test('classifies video files by mime type and extension', () {
      expect(
        IncomingFileClassifier.classify(
          filename: 'movie.bin',
          mimeType: 'video/mp4',
        ),
        IncomingFileKind.video,
      );
      expect(
        IncomingFileClassifier.classify(filename: 'clip.mp4'),
        IncomingFileKind.video,
      );
      expect(
        IncomingFileClassifier.classify(filename: 'clip.mkv'),
        IncomingFileKind.video,
      );
      expect(
        IncomingFileClassifier.classify(filename: 'clip.webm'),
        IncomingFileKind.video,
      );
    });

    test('classifies VEIL and JSON track files', () {
      expect(
        IncomingFileClassifier.classify(
          filename: 'demo.veil.json',
          mimeType: 'application/json',
        ),
        IncomingFileKind.track,
      );
      expect(
        IncomingFileClassifier.classify(
          filename: 'demo.veil',
          mimeType: 'application/json',
        ),
        IncomingFileKind.track,
      );
      expect(
        IncomingFileClassifier.classify(
          filename: 'track.json',
          mimeType: 'application/json',
        ),
        IncomingFileKind.track,
      );
      expect(
        IncomingFileClassifier.classify(
          filename: 'track.json',
          mimeType: 'text/plain',
        ),
        IncomingFileKind.unsupported,
      );
    });

    test('returns unsupported for unknown files', () {
      expect(
        IncomingFileClassifier.classify(filename: 'readme.txt'),
        IncomingFileKind.unsupported,
      );
      expect(
        IncomingFileClassifier.classify(
          filename: 'package.json',
          mimeType: 'text/plain',
        ),
        IncomingFileKind.unsupported,
      );
    });
  });
}
