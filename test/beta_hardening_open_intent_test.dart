import 'package:flutter_test/flutter_test.dart';
import 'package:veil_mobile/app/incoming_file_classifier.dart';

void main() {
  group('Open with file classification', () {
    test('classifies common video containers', () {
      for (final name in ['clip.mp4', 'movie.mkv', 'stream.webm', 'old.avi']) {
        expect(
          IncomingFileClassifier.classify(filename: name),
          IncomingFileKind.video,
          reason: name,
        );
      }
    });

    test('classifies video by mime type regardless of extension', () {
      expect(
        IncomingFileClassifier.classify(
          filename: 'download.bin',
          mimeType: 'video/webm',
        ),
        IncomingFileKind.video,
      );
    });

    test('classifies VEIL JSON and plain JSON tracks', () {
      expect(
        IncomingFileClassifier.classify(
          filename: 'track.veil.json',
          mimeType: 'application/json',
        ),
        IncomingFileKind.track,
      );
      expect(
        IncomingFileClassifier.classify(
          filename: 'my-track.json',
          mimeType: 'application/json',
        ),
        IncomingFileKind.track,
      );
    });

    test('rejects non-json extensions with non-json mime', () {
      expect(
        IncomingFileClassifier.classify(
          filename: 'notes.txt',
          mimeType: 'text/plain',
        ),
        IncomingFileKind.unsupported,
      );
    });
  });
}
