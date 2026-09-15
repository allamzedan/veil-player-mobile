import 'package:flutter/material.dart';
import 'package:veil_mobile/core/tracks/track_summary.dart';
import 'package:veil_mobile/core/veil/veil_track.dart';
import 'package:veil_mobile/shared/constants/app_strings.dart';
import 'package:veil_mobile/shared/utils/veil_duration_format.dart';
import 'package:veil_mobile/shared/widgets/app_bottom_sheet.dart';

/// Reusable read-only VEIL track inspection sheet.
abstract final class TrackDetailsSheet {
  static Future<void> show({
    required BuildContext context,
    required VeilTrack track,
    VoidCallback? onViewAllSegments,
  }) {
    final summary = TrackSummary.fromTrack(track);
    final previews = TrackActionPreview.fromTrack(track);

    return AppBottomSheet.show<void>(
      context: context,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 8),
        child: _TrackDetailsBody(
          summary: summary,
          previews: previews,
          onViewAllSegments: onViewAllSegments == null
              ? null
              : () {
                  Navigator.pop(sheetContext);
                  onViewAllSegments();
                },
        ),
      ),
    );
  }
}

class _TrackDetailsBody extends StatelessWidget {
  const _TrackDetailsBody({
    required this.summary,
    required this.previews,
    this.onViewAllSegments,
  });

  final TrackSummary summary;
  final List<TrackActionPreview> previews;
  final VoidCallback? onViewAllSegments;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final locale = MaterialLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(AppStrings.trackDetailsTitle, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(summary.title, style: theme.textTheme.titleLarge),
        const SizedBox(height: 20),
        Text(
          AppStrings.trackSummarySection,
          style: theme.textTheme.titleSmall?.copyWith(
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        TrackSummaryStatsCard(summary: summary),
        const SizedBox(height: 20),
        Text(
          AppStrings.trackAffectedTimeSection,
          style: theme.textTheme.titleSmall?.copyWith(
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        _DetailLine(
          label: AppStrings.segmentTypeMask,
          value: AppStrings.trackAffectedSeconds(summary.totalMaskedSeconds),
        ),
        const SizedBox(height: 8),
        _DetailLine(
          label: AppStrings.segmentTypeMute,
          value: AppStrings.trackAffectedSeconds(summary.totalMutedSeconds),
        ),
        const SizedBox(height: 8),
        _DetailLine(
          label: AppStrings.segmentTypeSkip,
          value: AppStrings.trackAffectedSeconds(summary.totalSkippedSeconds),
        ),
        const SizedBox(height: 20),
        Text(
          AppStrings.trackVideoSection,
          style: theme.textTheme.titleSmall?.copyWith(
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        _DetailLine(
          label: AppStrings.playerInfoVideo,
          value: summary.videoName ?? AppStrings.trackVideoUnknown,
        ),
        if (summary.videoDurationSeconds != null &&
            summary.videoDurationSeconds! > 0) ...[
          const SizedBox(height: 8),
          _DetailLine(
            label: AppStrings.trackVideoDuration,
            value: VeilDurationFormat.format(
              Duration(
                milliseconds: (summary.videoDurationSeconds! * 1000).round(),
              ),
            ),
          ),
        ],
        if (summary.fingerprintMethod != null) ...[
          const SizedBox(height: 8),
          _DetailLine(
            label: AppStrings.trackFingerprintMethod,
            value: summary.fingerprintMethod!,
          ),
        ],
        const SizedBox(height: 20),
        Text(
          AppStrings.trackMetadataSection,
          style: theme.textTheme.titleSmall?.copyWith(
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        _DetailLine(
          label: AppStrings.trackCreatedLabel,
          value: locale.formatShortDate(summary.createdAt.toLocal()),
        ),
        const SizedBox(height: 8),
        _DetailLine(
          label: AppStrings.trackUpdatedLabel,
          value: locale.formatShortDate(summary.updatedAt.toLocal()),
        ),
        if (previews.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            AppStrings.trackActionPreviewSection,
            style: theme.textTheme.titleSmall?.copyWith(
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          ...previews.map(
            (preview) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TrackActionPreviewRow(preview: preview),
            ),
          ),
        ],
        if (onViewAllSegments != null) ...[
          const SizedBox(height: 8),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton(
              onPressed: onViewAllSegments,
              child: Text(AppStrings.trackViewAllSegments),
            ),
          ),
        ],
      ],
    );
  }
}

class TrackSummaryStatsCard extends StatelessWidget {
  const TrackSummaryStatsCard({super.key, required this.summary});

  final TrackSummary summary;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _StatRow(
              label: AppStrings.segmentTypeMask,
              value: '${summary.maskCount}',
            ),
            const SizedBox(height: 8),
            _StatRow(
              label: AppStrings.segmentTypeMute,
              value: '${summary.muteCount}',
            ),
            const SizedBox(height: 8),
            _StatRow(
              label: AppStrings.segmentTypeSkip,
              value: '${summary.skipCount}',
            ),
            if (summary.bookmarkCount > 0) ...[
              const SizedBox(height: 8),
              _StatRow(
                label: AppStrings.segmentTypeBookmarks,
                value: '${summary.bookmarkCount}',
              ),
            ],
            const Divider(height: 24),
            _StatRow(
              label: AppStrings.trackTotalActions,
              value: '${summary.totalActions}',
              emphasized: true,
            ),
          ],
        ),
      ),
    );
  }
}

class TrackActionPreviewRow extends StatelessWidget {
  const TrackActionPreviewRow({super.key, required this.preview});

  final TrackActionPreview preview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final start = VeilDurationFormat.format(
      Duration(milliseconds: preview.startMs),
    );
    final end = VeilDurationFormat.format(
      Duration(milliseconds: preview.endMs),
    );

    return Row(
      children: [
        Expanded(
          child: Text(
            '$start → $end',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace',
              fontFamilyFallback: const ['Courier', 'monospace'],
            ),
          ),
        ),
        Text(
          AppStrings.segmentTypeLabel(preview.type.name),
          style: theme.textTheme.labelLarge,
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = emphasized
        ? theme.textTheme.titleSmall
        : theme.textTheme.bodyMedium;

    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        Text(value, style: style),
      ],
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
      ],
    );
  }
}

String? trackExportSummarySubtitle(TrackSummary summary) {
  if (summary.totalActions == 0) {
    return null;
  }
  return AppStrings.trackExportSummary(
    totalActions: summary.totalActions,
    maskCount: summary.maskCount,
    muteCount: summary.muteCount,
    skipCount: summary.skipCount,
  );
}
