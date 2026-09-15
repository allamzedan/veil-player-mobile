import 'package:flutter/material.dart';
import 'package:veil_mobile/core/tracks/track_summary.dart';
import 'package:veil_mobile/core/veil/veil_track.dart';
import 'package:veil_mobile/shared/constants/app_strings.dart';

/// Action count summary above the segment list.
class TrackBuilderSegmentSummaryHeader extends StatelessWidget {
  const TrackBuilderSegmentSummaryHeader({super.key, required this.track});

  final VeilTrack track;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final summary = TrackSummary.fromTrack(track);

    if (summary.totalActions == 0 && summary.bookmarkCount == 0) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (summary.totalActions > 0) ...[
          Text(
            AppStrings.trackBuilderActionsTotal(summary.totalActions),
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text(
            [
              if (summary.maskCount > 0)
                AppStrings.trackBuilderMaskCount(summary.maskCount),
              if (summary.muteCount > 0)
                AppStrings.trackBuilderMuteCount(summary.muteCount),
              if (summary.skipCount > 0)
                AppStrings.trackBuilderSkipCount(summary.skipCount),
            ].join(' · '),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        if (summary.bookmarkCount > 0) ...[
          if (summary.totalActions > 0) const SizedBox(height: 8),
          Text(
            AppStrings.trackBuilderBookmarkCount(summary.bookmarkCount),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
