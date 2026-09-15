import 'package:flutter/material.dart';
import 'package:veil_mobile/core/veil/veil_track.dart';
import 'package:veil_mobile/shared/constants/app_strings.dart';
import 'package:veil_mobile/shared/utils/veil_date_format.dart';

/// Collapsible desktop-compatible metadata for the current track.
class TrackMetadataPanel extends StatelessWidget {
  const TrackMetadataPanel({super.key, required this.track});

  final VeilTrack track;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final rows = _buildRows(track);
    final hasMetadata = rows.isNotEmpty;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 20, 0),
      child: Material(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: ExpansionTile(
          initiallyExpanded: false,
          tilePadding: const EdgeInsetsDirectional.symmetric(
            horizontal: 12,
            vertical: 4,
          ),
          childrenPadding: const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 12),
          title: Text(
            AppStrings.trackMetadataTitle,
            style: theme.textTheme.titleSmall,
          ),
          subtitle: Text(
            hasMetadata
                ? AppStrings.trackMetadataCollapsedHint
                : AppStrings.trackMetadataNone,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          children: [
            if (hasMetadata)
              for (final row in rows) ...[
                Text(
                  row.label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(row.value, style: theme.textTheme.bodyMedium),
                if (row != rows.last) const SizedBox(height: 8),
              ]
            else
              Text(
                AppStrings.trackMetadataNoneExpanded,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }

  static List<_MetadataRow> _buildRows(VeilTrack track) {
    final rows = <_MetadataRow>[];

    if (track.videoName != null && track.videoName!.isNotEmpty) {
      rows.add(_MetadataRow(AppStrings.trackVideoName, track.videoName!));
    }
    if (track.app != null) {
      rows.add(_MetadataRow(AppStrings.trackSourceApp, track.app!));
    }
    if (track.appVersion != null) {
      rows.add(
        _MetadataRow(AppStrings.trackSourceAppVersion, track.appVersion!),
      );
    }
    if (track.videoDurationSeconds != null) {
      rows.add(
        _MetadataRow(
          AppStrings.trackVideoDuration,
          AppStrings.formatVideoDuration(track.videoDurationSeconds!),
        ),
      );
    }
    if (track.videoWidth != null && track.videoHeight != null) {
      rows.add(
        _MetadataRow(
          AppStrings.trackVideoResolution,
          '${track.videoWidth}×${track.videoHeight}',
        ),
      );
    }
    if (track.globalOffsetSeconds != null && track.globalOffsetSeconds != 0) {
      rows.add(
        _MetadataRow(
          AppStrings.trackGlobalOffset,
          '${track.globalOffsetSeconds}s',
        ),
      );
    }
    if (track.exportedAt != null) {
      rows.add(
        _MetadataRow(
          AppStrings.trackExportedAt,
          VeilDateFormat.formatDateTime(track.exportedAt!),
        ),
      );
    }
    if (track.subtitleCover != null) {
      rows.add(
        _MetadataRow(
          AppStrings.trackSubtitleCover,
          AppStrings.trackSubtitleCoverPresent,
        ),
      );
    }

    return rows;
  }
}

class _MetadataRow {
  const _MetadataRow(this.label, this.value);

  final String label;
  final String value;
}
