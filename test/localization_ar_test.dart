import 'package:flutter_test/flutter_test.dart';
import 'package:veil_mobile/core/localization/app_localizations.dart';
import 'package:veil_mobile/core/localization/app_locale.dart';

void main() {
  group('AppLocalizationsAr', () {
    const en = AppLocalizations.en;
    const ar = AppLocalizations.ar;

    test('Arabic instance uses ar language code and RTL', () {
      expect(ar.languageCode, AppLanguageCode.ar);
      expect(ar.isRtl, isTrue);
      expect(en.isRtl, isFalse);
    });

    test('factory returns Arabic implementation for ar code', () {
      expect(
        AppLocalizations.forLanguageCode(AppLanguageCode.ar),
        same(ar),
      );
      expect(
        AppLocalizations.forLanguageCode(AppLanguageCode.en),
        same(en),
      );
    });

    test('primary UI strings differ from English', () {
      expect(ar.homeTitle, isNot(equals(en.homeTitle)));
      expect(ar.playerTitle, isNot(equals(en.playerTitle)));
      expect(ar.libraryTitle, isNot(equals(en.libraryTitle)));
      expect(ar.trackBuilderTitle, isNot(equals(en.trackBuilderTitle)));
      expect(ar.settingsTitle, isNot(equals(en.settingsTitle)));
      expect(ar.navHome, isNot(equals(en.navHome)));
      expect(ar.save, 'حفظ');
      expect(ar.cancel, 'إلغاء');
      expect(ar.delete, 'حذف');
    });

    test('player strings keep VEIL untranslated', () {
      expect(ar.playerLoadTrack, contains('VEIL'));
      expect(ar.playerVeilActive, startsWith('VEIL'));
      expect(ar.playerQuickAddMask, 'إضافة قناع');
      expect(ar.playerOpenVideo, 'فتح فيديو');
      expect(ar.playerNoVideoSelected, isNot(equals(en.playerNoVideoSelected)));
    });

    test('error and snackbar strings are translated', () {
      expect(ar.playerTrackLoadError, isNot(equals(en.playerTrackLoadError)));
      expect(ar.importInvalidJson, isNot(equals(en.importInvalidJson)));
      expect(ar.playerExportTrackSuccess, isNot(equals(en.playerExportTrackSuccess)));
      expect(ar.playerQuickActionAdded, isNot(equals(en.playerQuickActionAdded)));
      expect(ar.trackNotFound, isNot(equals(en.trackNotFound)));
      expect(ar.playerSubtitleLoadError, isNot(equals(en.playerSubtitleLoadError)));
      expect(
        ar.openIntentUnsupportedFile('clip.mp4'),
        isNot(equals(en.openIntentUnsupportedFile('clip.mp4'))),
      );
    });

    test('settings language and plan sections are translated', () {
      expect(ar.settingsLanguageSection, 'اللغة');
      expect(ar.settingsLanguageArabic, 'العربية');
      expect(ar.settingsPlanSection, 'الخطة');
      expect(ar.settingsAboutSection, isNot(equals(en.settingsAboutSection)));
    });
  });
}
