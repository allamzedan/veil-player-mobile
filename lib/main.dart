import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:veil_mobile/app/open_intent_bootstrap.dart';
import 'package:veil_mobile/app/veil_mobile_app.dart';
import 'package:veil_mobile/core/localization/app_localizations.dart';
import 'package:veil_mobile/core/localization/app_localizations_holder.dart';
import 'package:veil_mobile/core/logging/app_logger.dart';
import 'package:veil_mobile/core/storage/storage_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  AppLocalizationsHolder.update(AppLocalizations.en);

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    if (kDebugMode) {
      debugPrint(details.toString());
    }
  };

  ErrorWidget.builder = (details) {
    if (kDebugMode) {
      AppLogger.error(
        'Widget build failed',
        details.exception,
        details.stack,
      );
    }
    return Material(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            AppLocalizationsHolder.current.widgetBuildErrorFallback,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      ),
    );
  };

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const OpenIntentBootstrap(child: VeilMobileApp()),
    ),
  );
}
