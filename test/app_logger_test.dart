import 'package:flutter_test/flutter_test.dart';
import 'package:veil_mobile/core/logging/app_logger.dart';

void main() {
  test('AppLogger methods do not throw', () {
    expect(() => AppLogger.info('info message'), returnsNormally);
    expect(() => AppLogger.warning('warning message'), returnsNormally);
    expect(
      () => AppLogger.error('error message', StateError('detail')),
      returnsNormally,
    );
  });
}
