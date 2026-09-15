import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veil_mobile/core/subtitles/subtitle_settings.dart';
import 'package:veil_mobile/features/player/application/subtitle_settings_provider.dart';
import 'package:veil_mobile/shared/constants/app_strings.dart';
import 'package:veil_mobile/shared/widgets/app_bottom_sheet.dart';

class SubtitleSettingsSheet extends ConsumerWidget {
  const SubtitleSettingsSheet({
    super.key,
    this.onPickSubtitle,
    this.hasSubtitleFile = false,
  });

  final VoidCallback? onPickSubtitle;
  final bool hasSubtitleFile;

  static Future<void> show({
    required BuildContext context,
    VoidCallback? onPickSubtitle,
    bool hasSubtitleFile = false,
  }) {
    return AppBottomSheet.show<void>(
      context: context,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
        child: SubtitleSettingsSheet(
          onPickSubtitle: onPickSubtitle,
          hasSubtitleFile: hasSubtitleFile,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(subtitleSettingsProvider);
    final notifier = ref.read(subtitleSettingsProvider.notifier);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppStrings.playerSubtitleSettingsTitle,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        Text(
          AppStrings.playerSubtitleFontSize,
          style: theme.textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        SegmentedButton<SubtitleFontSize>(
          segments: [
            ButtonSegment(
              value: SubtitleFontSize.small,
              label: Text(AppStrings.playerSubtitleFontSizeSmall),
            ),
            ButtonSegment(
              value: SubtitleFontSize.medium,
              label: Text(AppStrings.playerSubtitleFontSizeMedium),
            ),
            ButtonSegment(
              value: SubtitleFontSize.large,
              label: Text(AppStrings.playerSubtitleFontSizeLarge),
            ),
          ],
          selected: {settings.fontSize},
          onSelectionChanged: (selection) {
            notifier.updateSettings(
              settings.copyWith(fontSize: selection.first),
            );
          },
        ),
        const SizedBox(height: 16),
        Text(
          AppStrings.playerSubtitlePosition,
          style: theme.textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        SegmentedButton<SubtitlePosition>(
          segments: [
            ButtonSegment(
              value: SubtitlePosition.bottom,
              label: Text(AppStrings.playerSubtitlePositionBottom),
            ),
            ButtonSegment(
              value: SubtitlePosition.middle,
              label: Text(AppStrings.playerSubtitlePositionMiddle),
            ),
            ButtonSegment(
              value: SubtitlePosition.top,
              label: Text(AppStrings.playerSubtitlePositionTop),
            ),
          ],
          selected: {settings.position},
          onSelectionChanged: (selection) {
            notifier.updateSettings(
              settings.copyWith(position: selection.first),
            );
          },
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(AppStrings.playerSubtitleBackground),
          value: settings.backgroundEnabled,
          onChanged: (enabled) {
            notifier.updateSettings(
              settings.copyWith(backgroundEnabled: enabled),
            );
          },
        ),
        if (settings.backgroundEnabled) ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  AppStrings.playerSubtitleBackgroundOpacity,
                  style: theme.textTheme.labelLarge,
                ),
              ),
              Text(
                '${(settings.backgroundOpacity * 100).round()}%',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          Slider(
            value: settings.backgroundOpacity,
            min: 0,
            max: 1,
            divisions: 10,
            onChanged: (value) {
              notifier.updateSettings(
                settings.copyWith(backgroundOpacity: value),
              );
            },
          ),
        ],
        const SizedBox(height: 8),
        Text(
          AppStrings.playerSubtitleDelay,
          style: theme.textTheme.labelLarge,
        ),
        const SizedBox(height: 4),
        Text(
          settings.formatDelayLabel(),
          style: theme.textTheme.titleSmall?.copyWith(
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _DelayButton(
              label: AppStrings.playerSubtitleDelayMinus500,
              onPressed: () => notifier.adjustDelay(-500),
            ),
            _DelayButton(
              label: AppStrings.playerSubtitleDelayMinus100,
              onPressed: () => notifier.adjustDelay(-100),
            ),
            _DelayButton(
              label: AppStrings.playerSubtitleDelayReset,
              onPressed: notifier.resetDelay,
            ),
            _DelayButton(
              label: AppStrings.playerSubtitleDelayPlus100,
              onPressed: () => notifier.adjustDelay(100),
            ),
            _DelayButton(
              label: AppStrings.playerSubtitleDelayPlus500,
              onPressed: () => notifier.adjustDelay(500),
            ),
          ],
        ),
        if (onPickSubtitle != null) ...[
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              onPickSubtitle!();
            },
            icon: const Icon(Icons.subtitles_outlined, size: 18),
            label: Text(
              hasSubtitleFile
                  ? AppStrings.playerReplaceSubtitle
                  : AppStrings.playerPickSubtitle,
            ),
          ),
        ],
      ],
    );
  }
}

class _DelayButton extends StatelessWidget {
  const _DelayButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      child: Text(label),
    );
  }
}
