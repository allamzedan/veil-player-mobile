import 'package:veil_mobile/core/localization/app_localizations.dart';

/// Global holder so non-widget code can read localized strings via [AppStrings].
abstract final class AppLocalizationsHolder {
  static AppLocalizations _current = AppLocalizations.en;

  static AppLocalizations get current => _current;

  static void update(AppLocalizations localizations) {
    _current = localizations;
  }
}
