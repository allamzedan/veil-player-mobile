import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veil_mobile/app/cold_start_splash_gate.dart';
import 'package:veil_mobile/app/recovery_bootstrap.dart';
import 'package:veil_mobile/app/router.dart';
import 'package:veil_mobile/app/theme.dart';
import 'package:veil_mobile/core/localization/localization_provider.dart';
import 'package:veil_mobile/shared/constants/app_strings.dart';

class VeilMobileApp extends ConsumerWidget {
  const VeilMobileApp({super.key});

  static const supportedLocales = [Locale('en'), Locale('ar')];

  static const localizationsDelegates = [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(appLocalizationsSyncProvider);
    final locale = ref.watch(resolvedLocaleProvider);
    final textDirection = ref.watch(appTextDirectionProvider);

    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: veilDarkTheme,
      routerConfig: appRouter,
      locale: locale,
      supportedLocales: supportedLocales,
      localizationsDelegates: localizationsDelegates,
      builder: (context, child) {
        return Directionality(
          textDirection: textDirection,
          child: ColdStartSplashGate(
            child: RecoveryBootstrap(
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        );
      },
    );
  }
}
