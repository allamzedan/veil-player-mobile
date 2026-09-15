import 'package:flutter/material.dart';
import 'package:veil_mobile/core/track_packs/track_pack.dart';
import 'package:veil_mobile/core/track_packs/track_pack_summary.dart';
import 'package:veil_mobile/shared/constants/app_strings.dart';
import 'package:veil_mobile/shared/widgets/app_bottom_sheet.dart';

/// Read-only inspection sheet for a local track pack.
abstract final class TrackPackDetailsSheet {
  static Future<void> show({
    required BuildContext context,
    required TrackPack pack,
  }) {
    final summary = TrackPackSummary.fromPack(pack);
    final previews = trackPackTrackPreviews(pack);

    return AppBottomSheet.show<void>(
      context: context,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppStrings.trackPackDetailsTitle,
              style: Theme.of(sheetContext).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              summary.title,
              style: Theme.of(sheetContext).textTheme.titleLarge,
            ),
            if (summary.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                summary.description,
                style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(sheetContext).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 16),
            _InfoLine(
              label: AppStrings.trackPackAuthorLabel,
              value: summary.author,
            ),
            const SizedBox(height: 8),
            _InfoLine(
              label: AppStrings.trackPackTrackCountLabel,
              value: '${summary.trackCount}',
            ),
            if (summary.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              _InfoLine(
                label: AppStrings.trackPackTagsLabel,
                value: summary.tags.join(', '),
              ),
            ],
            const SizedBox(height: 20),
            Text(
              AppStrings.trackPackTrackListTitle,
              style: Theme.of(sheetContext).textTheme.titleSmall?.copyWith(
                color: Theme.of(sheetContext).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            if (previews.isEmpty)
              Text(
                AppStrings.trackPackNoTracks,
                style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(sheetContext).colorScheme.onSurfaceVariant,
                ),
              )
            else
              ...previews.map(
                (preview) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _PackTrackPreviewRow(preview: preview),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PackTrackPreviewRow extends StatelessWidget {
  const _PackTrackPreviewRow({required this.preview});

  final TrackPackTrackPreview preview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final summary = preview.summary;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              preview.trackTitle,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 6),
            if (!preview.decodeSucceeded || summary == null)
              Text(
                AppStrings.trackPackTrackDecodeFailed,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              )
            else
              Text(
                AppStrings.trackPackTrackStats(
                  maskCount: summary.maskCount,
                  muteCount: summary.muteCount,
                  skipCount: summary.skipCount,
                ),
                style: theme.textTheme.bodySmall,
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
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
