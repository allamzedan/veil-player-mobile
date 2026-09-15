import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veil_mobile/core/localization/app_locale.dart';
import 'package:veil_mobile/core/localization/app_localizations.dart';
import 'package:veil_mobile/core/localization/app_localizations_holder.dart';
import 'package:veil_mobile/core/storage/storage_providers.dart';

/// Persisted user language preference.
final localePreferenceProvider =
    NotifierProvider<LocalePreferenceController, LocalePreference>(
      LocalePreferenceController.new,
    );

class LocalePreferenceController extends Notifier<LocalePreference> {
  @override
  LocalePreference build() {
    final stored = ref
        .read(sharedPreferencesProvider)
        .getString(LocalePreference.storageKey);
    return LocalePreference.fromStorage(stored);
  }

  Future<void> setPreference(LocalePreference preference) async {
    state = preference;
    await ref
        .read(sharedPreferencesProvider)
        .setString(LocalePreference.storageKey, preference.name);
  }
}

/// Locale passed to [MaterialApp] after resolving system preference.
final resolvedLocaleProvider = Provider<Locale>((ref) {
  final preference = ref.watch(localePreferenceProvider);
  return switch (preference) {
    LocalePreference.en => const Locale(AppLanguageCode.en),
    LocalePreference.ar => const Locale(AppLanguageCode.ar),
    LocalePreference.system => _systemLocale(),
  };
});

Locale _systemLocale() {
  final system = WidgetsBinding.instance.platformDispatcher.locale;
  if (system.languageCode == AppLanguageCode.ar) {
    return const Locale(AppLanguageCode.ar);
  }
  return const Locale(AppLanguageCode.en);
}

/// Text direction for the active locale (RTL for Arabic).
final appTextDirectionProvider = Provider<TextDirection>((ref) {
  final locale = ref.watch(resolvedLocaleProvider);
  return locale.languageCode == AppLanguageCode.ar
      ? TextDirection.rtl
      : TextDirection.ltr;
});

/// Active localized strings for the resolved locale.
final appLocalizationsProvider = Provider<AppLocalizations>((ref) {
  final locale = ref.watch(resolvedLocaleProvider);
  return AppLocalizations.forLanguageCode(locale.languageCode);
});

/// Keeps [AppLocalizationsHolder] in sync for code paths without [BuildContext].
final appLocalizationsSyncProvider = Provider<void>((ref) {
  final localizations = ref.watch(appLocalizationsProvider);
  AppLocalizationsHolder.update(localizations);
});
