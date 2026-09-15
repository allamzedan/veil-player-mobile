import 'package:flutter_test/flutter_test.dart';
import 'package:veil_mobile/core/app/app_version.dart';

void main() {
  test('AppVersion matches pubspec format', () {
    expect(AppVersion.pubspecLine, '0.2.3+1');
    expect(AppVersion.versionName, '0.2.3');
    expect(AppVersion.buildNumber, '1');
    expect(AppVersion.settingsDisplay, '0.2.3+1');
  });
}
