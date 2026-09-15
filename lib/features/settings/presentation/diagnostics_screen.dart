import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:veil_mobile/core/diagnostics/diagnostics_export.dart';
import 'package:veil_mobile/core/diagnostics/diagnostics_report_builder.dart';
import 'package:veil_mobile/core/diagnostics/diagnostics_snapshot.dart';
import 'package:veil_mobile/core/diagnostics/qa_checklist.dart';
import 'package:veil_mobile/core/diagnostics/qa_checklist_provider.dart';
import 'package:veil_mobile/core/localization/localization_provider.dart';
import 'package:veil_mobile/core/logging/app_logger.dart';
import 'package:veil_mobile/core/monetization/entitlement_provider.dart';
import 'package:veil_mobile/features/player/application/player_runtime_controller.dart';
import 'package:veil_mobile/features/player/application/player_setup_controller.dart';
import 'package:veil_mobile/shared/constants/app_strings.dart';
import 'package:veil_mobile/shared/widgets/app_scaffold.dart';

class DiagnosticsScreen extends ConsumerStatefulWidget {
  const DiagnosticsScreen({super.key});

  @override
  ConsumerState<DiagnosticsScreen> createState() => _DiagnosticsScreenState();
}

class _DiagnosticsScreenState extends ConsumerState<DiagnosticsScreen> {
  bool _exporting = false;

  DiagnosticsSnapshot _snapshot() {
    final locale = ref.read(resolvedLocaleProvider);
    return DiagnosticsSnapshot.collect(
      localePreference: ref.read(localePreferenceProvider),
      localeCode: locale.languageCode,
      themeModeLabel: AppStrings.diagnosticsThemeDark,
      entitlement: ref.read(entitlementProvider),
      currentRoute: GoRouterState.of(context).uri.path,
      setup: ref.read(playerSetupControllerProvider),
      runtime: ref.read(playerRuntimeControllerProvider),
      completedQaItems: ref.read(qaChecklistProvider),
    );
  }

  String _buildModeLabel() {
    if (kDebugMode) {
      return AppStrings.diagnosticsBuildDebug;
    }
    if (kProfileMode) {
      return AppStrings.diagnosticsBuildProfile;
    }
    return AppStrings.diagnosticsBuildRelease;
  }

  String _statusLabel(bool value) =>
      value ? AppStrings.diagnosticsStatusYes : AppStrings.diagnosticsStatusNo;

  Future<void> _exportDiagnostics() async {
    if (_exporting) {
      return;
    }
    setState(() => _exporting = true);
    try {
      final report = DiagnosticsReportBuilder.build(_snapshot());
      AppLogger.info('Exporting diagnostics report');
      final result = await exportDiagnosticsReport(report: report);
      if (!mounted) {
        return;
      }
      if (!result.success) {
        AppLogger.warning('Diagnostics export failed', result.message);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.success
                ? result.message
                : AppStrings.diagnosticsExportFailed,
          ),
          backgroundColor: result.success
              ? null
              : Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _exporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final snapshot = _snapshot();
    final health = snapshot.health;
    final completed = ref.watch(qaChecklistProvider);
    final strings = ref.watch(appLocalizationsProvider);

    return AppScaffold(
      title: AppStrings.diagnosticsTitle,
      showBackButton: true,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          FilledButton.icon(
            onPressed: _exporting ? null : _exportDiagnostics,
            icon: _exporting
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.onPrimary,
                    ),
                  )
                : const Icon(Icons.upload_file_outlined),
            label: Text(AppStrings.diagnosticsExportButton),
          ),
          const SizedBox(height: 28),
          _SectionTitle(title: AppStrings.diagnosticsAppInfoSection),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                _InfoTile(
                  label: AppStrings.diagnosticsLabelAppVersion,
                  value: snapshot.appVersion,
                ),
                const Divider(height: 1),
                _InfoTile(
                  label: AppStrings.diagnosticsLabelPlatform,
                  value: snapshot.platformName,
                ),
                const Divider(height: 1),
                _InfoTile(
                  label: AppStrings.diagnosticsLabelLocale,
                  value:
                      '${snapshot.localeCode} (${snapshot.localePreference.name})',
                ),
                const Divider(height: 1),
                _InfoTile(
                  label: AppStrings.diagnosticsLabelThemeMode,
                  value: snapshot.themeModeLabel,
                ),
                const Divider(height: 1),
                _InfoTile(
                  label: AppStrings.diagnosticsLabelPlan,
                  value: ref.read(entitlementProvider).isPro
                      ? 'Pro'
                      : AppStrings.settingsCurrentPlanFree,
                ),
                const Divider(height: 1),
                _InfoTile(
                  label: AppStrings.diagnosticsLabelBuildMode,
                  value: _buildModeLabel(),
                ),
                const Divider(height: 1),
                _InfoTile(
                  label: AppStrings.diagnosticsLabelPackageId,
                  value: snapshot.packageId,
                ),
                const Divider(height: 1),
                _InfoTile(
                  label: AppStrings.diagnosticsLabelDartSdk,
                  value: snapshot.dartSdkVersion,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          _SectionTitle(title: AppStrings.diagnosticsHealthSection),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                _HealthTile(
                  label: AppStrings.diagnosticsHealthVideoLoaded,
                  ok: health.videoLoaded,
                  statusLabel: _statusLabel(health.videoLoaded),
                ),
                const Divider(height: 1),
                _HealthTile(
                  label: AppStrings.diagnosticsHealthTrackLoaded,
                  ok: health.trackLoaded,
                  statusLabel: _statusLabel(health.trackLoaded),
                ),
                const Divider(height: 1),
                _HealthTile(
                  label: AppStrings.diagnosticsHealthSubtitleLoaded,
                  ok: health.subtitleLoaded,
                  statusLabel: _statusLabel(health.subtitleLoaded),
                ),
                const Divider(height: 1),
                _HealthTile(
                  label: AppStrings.diagnosticsHealthRuntimeActive,
                  ok: health.runtimeActive,
                  statusLabel: _statusLabel(health.runtimeActive),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          _SectionTitle(title: AppStrings.diagnosticsQaChecklistSection),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < qaChecklistItems.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  CheckboxListTile(
                    value: completed.contains(qaChecklistItems[i].storageKey),
                    onChanged: (checked) {
                      ref
                          .read(qaChecklistProvider.notifier)
                          .setCompleted(qaChecklistItems[i], checked ?? false);
                    },
                    title: Text(qaChecklistItems[i].label(strings)),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      title: Text(label),
      subtitle: Text(
        value,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontFamily: 'monospace',
          fontFamilyFallback: const ['Courier', 'monospace'],
        ),
      ),
    );
  }
}

class _HealthTile extends StatelessWidget {
  const _HealthTile({
    required this.label,
    required this.ok,
    required this.statusLabel,
  });

  final String label;
  final bool ok;
  final String statusLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(
        ok ? Icons.check_circle_outline : Icons.radio_button_unchecked,
        color: ok ? colorScheme.primary : colorScheme.onSurfaceVariant,
      ),
      title: Text(label),
      trailing: Text(
        statusLabel,
        style: TextStyle(
          color: ok ? colorScheme.primary : colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
