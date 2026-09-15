import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:veil_mobile/core/localization/app_locale.dart';
import 'package:veil_mobile/core/localization/localization_provider.dart';
import 'package:veil_mobile/core/storage/storage_providers.dart';

void main() {
  group('LocalePreference', () {
    test('fromStorage maps persisted values', () {
      expect(LocalePreference.fromStorage(null), LocalePreference.system);
      expect(LocalePreference.fromStorage('en'), LocalePreference.en);
      expect(LocalePreference.fromStorage('ar'), LocalePreference.ar);
      expect(LocalePreference.fromStorage('unknown'), LocalePreference.system);
    });
  });

  group('appTextDirectionProvider', () {
    Future<ProviderContainer> createContainer(String pref) async {
      SharedPreferences.setMockInitialValues({
        LocalePreference.storageKey: pref,
      });
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      return container;
    }

    test('Arabic preference resolves to RTL', () async {
      final container = await createContainer('ar');
      addTearDown(container.dispose);

      expect(container.read(appTextDirectionProvider), TextDirection.rtl);
      expect(
        container.read(resolvedLocaleProvider).languageCode,
        AppLanguageCode.ar,
      );
    });

    test('English preference resolves to LTR', () async {
      final container = await createContainer('en');
      addTearDown(container.dispose);

      expect(container.read(appTextDirectionProvider), TextDirection.ltr);
      expect(
        container.read(resolvedLocaleProvider).languageCode,
        AppLanguageCode.en,
      );
    });
  });
}
