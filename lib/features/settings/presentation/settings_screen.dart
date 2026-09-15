import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:veil_mobile/app/router.dart';
import 'package:veil_mobile/core/app/app_version.dart';
import 'package:veil_mobile/core/localization/app_locale.dart';
import 'package:veil_mobile/core/localization/localization_provider.dart';
import 'package:veil_mobile/features/player/application/player_playback_settings_provider.dart';
import 'package:veil_mobile/shared/constants/app_strings.dart';
import 'package:veil_mobile/shared/widgets/app_brand_mark.dart';
import 'package:veil_mobile/shared/widgets/app_scaffold.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final localePreference = ref.watch(localePreferenceProvider);

    return AppScaffold(
      title: AppStrings.settingsTitle,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            AppStrings.settingsLanguageSection,
            style: theme.textTheme.titleSmall?.copyWith(
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                _LanguageTile(
                  title: AppStrings.settingsLanguageSystem,
                  value: LocalePreference.system,
                  groupValue: localePreference,
                  onChanged: (value) => _setLanguage(ref, value),
                ),
                const Divider(height: 1),
                _LanguageTile(
                  title: AppStrings.settingsLanguageEnglish,
                  value: LocalePreference.en,
                  groupValue: localePreference,
                  onChanged: (value) => _setLanguage(ref, value),
                ),
                const Divider(height: 1),
                _LanguageTile(
                  title: AppStrings.settingsLanguageArabic,
                  value: LocalePreference.ar,
                  groupValue: localePreference,
                  onChanged: (value) => _setLanguage(ref, value),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Text(
            AppStrings.settingsPlaybackSection,
            style: theme.textTheme.titleSmall?.copyWith(
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            child: SwitchListTile(
              title: Text(AppStrings.settingsAutoplayNextVideo),
              subtitle: Text(AppStrings.settingsAutoplayNextVideoSubtitle),
              value: ref.watch(playerPlaybackSettingsProvider).autoplayNextVideo,
              onChanged: (value) => ref
                  .read(playerPlaybackSettingsProvider.notifier)
                  .setAutoplayNextVideo(value),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            AppStrings.settingsPlanSection,
            style: theme.textTheme.titleSmall?.copyWith(
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.settingsCurrentPlan,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppStrings.settingsCurrentPlanFree,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.settingsProFeatures,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppStrings.settingsProFeaturesValue,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.tonal(
                    onPressed: null,
                    child: Text(AppStrings.settingsUpgradeComingLater),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            AppStrings.settingsDiagnosticsSection,
            style: theme.textTheme.titleSmall?.copyWith(
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              leading: const Icon(Icons.bug_report_outlined),
              title: Text(AppStrings.settingsOpenDiagnostics),
              subtitle: Text(AppStrings.settingsOpenDiagnosticsSubtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutes.settingsDiagnostics),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            AppStrings.settingsRecoverySection,
            style: theme.textTheme.titleSmall?.copyWith(
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              leading: const Icon(Icons.restore_outlined),
              title: Text(AppStrings.settingsOpenRecovery),
              subtitle: Text(AppStrings.settingsOpenRecoverySubtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutes.settingsRecovery),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            AppStrings.settingsAboutSection,
            style: theme.textTheme.titleSmall?.copyWith(
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const AppBrandMark(),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          AppStrings.appName,
                          style: theme.textTheme.titleLarge,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppVersion.settingsDisplay,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.settingsAboutTagline,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.settingsAboutDesktopTracks,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppStrings.settingsAboutDeveloper,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppStrings.settingsAboutBuildNote,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            AppStrings.settingsLegalSection,
            style: theme.textTheme.titleSmall?.copyWith(
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: Text(AppStrings.settingsPrivacyPolicy),
                  subtitle: Text(AppStrings.settingsPrivacyPolicyValue),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(AppRoutes.settingsPrivacy),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: Text(AppStrings.settingsTermsOfUse),
                  subtitle: Text(AppStrings.settingsTermsOfUseValue),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(AppRoutes.settingsTerms),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _setLanguage(WidgetRef ref, LocalePreference? value) async {
    if (value == null) {
      return;
    }
    await ref.read(localePreferenceProvider.notifier).setPreference(value);
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  final String title;
  final LocalePreference value;
  final LocalePreference groupValue;
  final ValueChanged<LocalePreference?> onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return ListTile(
      title: Text(title),
      trailing: selected ? const Icon(Icons.check) : null,
      selected: selected,
      onTap: () => onChanged(value),
    );
  }
}
