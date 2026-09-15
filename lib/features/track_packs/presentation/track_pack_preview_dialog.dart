import 'package:flutter/material.dart';
import 'package:veil_mobile/core/track_packs/track_pack.dart';
import 'package:veil_mobile/core/track_packs/track_pack_summary.dart';
import 'package:veil_mobile/shared/constants/app_strings.dart';

/// Confirms a parsed track pack before importing it locally.
abstract final class TrackPackPreviewDialog {
  /// Returns `true` when the user chooses to import the pack.
  static Future<bool?> show({
    required BuildContext context,
    required TrackPack pack,
  }) {
    final summary = TrackPackSummary.fromPack(pack);

    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(AppStrings.trackPackPreviewTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  summary.title,
                  style: Theme.of(dialogContext).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                _InfoRow(
                  label: AppStrings.trackPackAuthorLabel,
                  value: summary.author,
                ),
                const SizedBox(height: 8),
                _InfoRow(
                  label: AppStrings.trackPackTrackCountLabel,
                  value: '${summary.trackCount}',
                ),
                if (summary.tags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _InfoRow(
                    label: AppStrings.trackPackTagsLabel,
                    value: summary.tags.join(', '),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(AppStrings.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(AppStrings.trackPackImportAction),
            ),
          ],
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 88,
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }
}
