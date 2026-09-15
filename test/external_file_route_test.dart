import 'package:flutter_test/flutter_test.dart';
import 'package:veil_mobile/app/external_file_route.dart';

void main() {
  group('isExternalFileUri', () {
    test('detects content and file schemes', () {
      expect(
        isExternalFileUri(Uri.parse('content://media/external/video/media/1')),
        isTrue,
      );
      expect(
        isExternalFileUri(Uri.parse('file:///storage/emulated/0/video.mp4')),
        isTrue,
      );
      expect(isExternalFileUri(Uri.parse('/player')), isFalse);
      expect(isExternalFileUri(Uri.parse('/')), isFalse);
    });
  });

  group('isExternalFileRoute', () {
    test('detects external URI strings', () {
      expect(
        isExternalFileRoute(
          'content://com.android.providers.media.documents/document/video%3A123',
        ),
        isTrue,
      );
      expect(isExternalFileRoute('file:///sdcard/Download/demo.mp4'), isTrue);
      expect(isExternalFileRoute('/player'), isFalse);
      expect(isExternalFileRoute('/track-builder'), isFalse);
    });
  });
}
