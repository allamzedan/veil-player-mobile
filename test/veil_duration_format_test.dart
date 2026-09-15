import 'package:flutter_test/flutter_test.dart';
import 'package:veil_mobile/shared/utils/veil_duration_format.dart';

void main() {
  group('VeilDurationFormat', () {
    test('formats sub-hour durations as mm:ss', () {
      expect(
        VeilDurationFormat.format(const Duration(minutes: 2, seconds: 5)),
        '02:05',
      );
    });

    test('formats hour-long durations as hh:mm:ss', () {
      expect(
        VeilDurationFormat.format(
          const Duration(hours: 1, minutes: 3, seconds: 9),
        ),
        '01:03:09',
      );
    });
  });
}
