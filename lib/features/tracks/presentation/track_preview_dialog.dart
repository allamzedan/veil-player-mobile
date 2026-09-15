import 'package:flutter/material.dart';
import 'package:veil_mobile/core/tracks/track_summary.dart';
import 'package:veil_mobile/core/veil/veil_track.dart';
import 'package:veil_mobile/features/tracks/presentation/track_details_sheet.dart';
import 'package:veil_mobile/shared/constants/app_strings.dart';

/// Confirms a parsed VEIL track before loading it into the app.
abstract final class TrackPreviewDialog {
  /// Returns `true` when the user chooses to load the track.
  static Future<bool?> show({
    required BuildContext context,
    required VeilTrack track,
  }) {
    final summary = TrackSummary.fromTrack(track);

    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(AppStrings.trackPreviewDialogTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  summary.title,
                  style: Theme.of(dialogContext).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                TrackSummaryStatsCard(summary: summary),
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
              child: Text(AppStrings.trackPreviewLoad),
            ),
          ],
        );
      },
    );
  }
}
