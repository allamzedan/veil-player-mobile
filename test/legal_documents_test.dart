import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veil_mobile/core/legal/legal_document.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Legal documents', () {
    test('privacy policy asset loads and mentions local-only handling', () async {
      final text = await rootBundle.loadString(
        LegalDocumentId.privacyPolicy.assetPath,
      );
      expect(text, contains('VEIL Player Mobile'));
      expect(text, contains('analytics or advertising SDKs'));
      expect(text, contains('allamzedan@live.com'));
    });

    test('terms of use asset loads and mentions beta notice', () async {
      final text = await rootBundle.loadString(
        LegalDocumentId.termsOfUse.assetPath,
      );
      expect(text, contains('Terms of Use'));
      expect(text, contains('as is'));
      expect(text, contains('allamzedan@live.com'));
    });
  });
}
