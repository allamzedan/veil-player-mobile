import 'package:flutter/foundation.dart';
import 'package:veil_mobile/core/app/app_identity.dart';
import 'package:veil_mobile/core/app/app_version.dart';
import 'package:veil_mobile/core/diagnostics/diagnostics_platform.dart';
import 'package:veil_mobile/core/diagnostics/runtime_health.dart';
import 'package:veil_mobile/core/localization/app_locale.dart';
import 'package:veil_mobile/core/monetization/entitlement.dart';
import 'package:veil_mobile/features/player/application/player_runtime_state.dart';
import 'package:veil_mobile/features/player/application/player_setup_state.dart';

/// Environment and runtime data collected for diagnostics display and export.
class DiagnosticsSnapshot {
  const DiagnosticsSnapshot({
    required this.appVersion,
    required this.platformName,
    required this.localeCode,
    required this.localePreference,
    required this.themeModeLabel,
    required this.planLabel,
    required this.buildMode,
    required this.packageId,
    required this.dartSdkVersion,
    required this.currentRoute,
    required this.health,
    required this.setup,
    required this.runtime,
    required this.completedQaItems,
    required this.generatedAt,
  });

  final String appVersion;
  final String platformName;
  final String localeCode;
  final LocalePreference localePreference;
  final String themeModeLabel;
  final String planLabel;
  final String buildMode;
  final String packageId;
  final String dartSdkVersion;
  final String currentRoute;
  final RuntimeHealthSnapshot health;
  final PlayerSetupState setup;
  final PlayerRuntimeState runtime;
  final Set<String> completedQaItems;
  final DateTime generatedAt;

  static String platformLabel(TargetPlatform platform) {
    return switch (platform) {
      TargetPlatform.android => 'Android',
      TargetPlatform.iOS => 'iOS',
      TargetPlatform.windows => 'Windows',
      TargetPlatform.macOS => 'macOS',
      TargetPlatform.linux => 'Linux',
      TargetPlatform.fuchsia => 'Fuchsia',
    };
  }

  static String buildModeLabel() {
    if (kDebugMode) {
      return 'debug';
    }
    if (kProfileMode) {
      return 'profile';
    }
    return 'release';
  }

  static String planLabelFor(Entitlement entitlement) {
    return entitlement.isPro ? 'Pro' : 'Free';
  }

  factory DiagnosticsSnapshot.collect({
    required LocalePreference localePreference,
    required String localeCode,
    required String themeModeLabel,
    required Entitlement entitlement,
    required String currentRoute,
    required PlayerSetupState setup,
    required PlayerRuntimeState runtime,
    required Set<String> completedQaItems,
  }) {
    return DiagnosticsSnapshot(
      appVersion: AppVersion.settingsDisplay,
      platformName: platformLabel(defaultTargetPlatform),
      localeCode: localeCode,
      localePreference: localePreference,
      themeModeLabel: themeModeLabel,
      planLabel: planLabelFor(entitlement),
      buildMode: buildModeLabel(),
      packageId: AppIdentity.packageId,
      dartSdkVersion: diagnosticsDartSdkVersion(),
      currentRoute: currentRoute,
      health: RuntimeHealthChecker.evaluate(setup: setup, runtime: runtime),
      setup: setup,
      runtime: runtime,
      completedQaItems: completedQaItems,
      generatedAt: DateTime.now().toUtc(),
    );
  }
}
