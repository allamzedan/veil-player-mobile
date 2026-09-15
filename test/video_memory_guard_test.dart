import 'package:flutter_test/flutter_test.dart';
import 'package:veil_mobile/shared/constants/app_strings.dart';
import 'package:veil_mobile/shared/utils/video_file_limits.dart';

void main() {
  group('VideoFileLimits', () {
    test('allows videos at or below 500 MB', () {
      expect(VideoFileLimits.isWithinLimit(null), isTrue);
      expect(VideoFileLimits.isWithinLimit(0), isTrue);
      expect(VideoFileLimits.isWithinLimit(VideoFileLimits.maxVideoBytes), isTrue);
      expect(
        VideoFileLimits.isWithinLimit(VideoFileLimits.maxVideoBytes - 1),
        isTrue,
      );
    });

    test('rejects videos above 500 MB', () {
      expect(
        VideoFileLimits.isWithinLimit(VideoFileLimits.maxVideoBytes + 1),
        isFalse,
      );
      expect(VideoFileLimits.isWithinLimit(177 * 1024 * 1024), isTrue);
      expect(VideoFileLimits.isWithinLimit(501 * 1024 * 1024), isFalse);
    });
  });

  group('player video guardrail messaging', () {
    test('playerVideoTooLarge includes reported size', () {
      final message = AppStrings.playerVideoTooLarge(600 * 1024 * 1024);
      expect(message, contains('500 MB'));
      expect(message, contains('600.0 MB'));
    });
  });
}
