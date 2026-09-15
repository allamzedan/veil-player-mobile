/// Supported app locale preference values (persisted).
enum LocalePreference {
  system,
  en,
  ar;

  static const storageKey = 'locale_preference';

  static LocalePreference fromStorage(String? value) {
    return switch (value) {
      'en' => LocalePreference.en,
      'ar' => LocalePreference.ar,
      _ => LocalePreference.system,
    };
  }
}

/// Resolved language codes used by [AppLocalizations].
abstract final class AppLanguageCode {
  static const en = 'en';
  static const ar = 'ar';
}
