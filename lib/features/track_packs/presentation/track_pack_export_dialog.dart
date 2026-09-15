import 'package:flutter/material.dart';
import 'package:veil_mobile/core/track_packs/track_pack.dart';
import 'package:veil_mobile/shared/constants/app_strings.dart';

/// Collects metadata before exporting a track pack.
class TrackPackExportFormData {
  const TrackPackExportFormData({
    required this.title,
    required this.description,
    required this.author,
    required this.tags,
  });

  final String title;
  final String description;
  final String author;
  final List<String> tags;
}

abstract final class TrackPackExportDialog {
  static Future<TrackPackExportFormData?> show({
    required BuildContext context,
    int selectedTrackCount = 0,
  }) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final authorController = TextEditingController(
      text: TrackPack.defaultAuthor,
    );
    final tagsController = TextEditingController();

    return showDialog<TrackPackExportFormData>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(AppStrings.trackPackExportDialogTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selectedTrackCount > 0)
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      '${AppStrings.trackPackTrackCountLabel}: $selectedTrackCount',
                      style: Theme.of(dialogContext).textTheme.bodyMedium,
                    ),
                  ),
                if (selectedTrackCount > 0) const SizedBox(height: 12),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: AppStrings.trackPackTitleLabel,
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: AppStrings.trackPackDescriptionLabel,
                  ),
                  maxLines: 3,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: authorController,
                  decoration: InputDecoration(
                    labelText: AppStrings.trackPackAuthorLabel,
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: tagsController,
                  decoration: InputDecoration(
                    labelText: AppStrings.trackPackTagsInputLabel,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(AppStrings.cancel),
            ),
            FilledButton(
              onPressed: () {
                final title = titleController.text.trim();
                if (title.isEmpty) {
                  return;
                }
                Navigator.of(dialogContext).pop(
                  TrackPackExportFormData(
                    title: title,
                    description: descriptionController.text.trim(),
                    author: authorController.text.trim(),
                    tags: _parseTags(tagsController.text),
                  ),
                );
              },
              child: Text(AppStrings.trackPackExport),
            ),
          ],
        );
      },
    );
  }

  static List<String> _parseTags(String raw) {
    if (raw.trim().isEmpty) {
      return const [];
    }
    return [
      for (final part in raw.split(','))
        if (part.trim().isNotEmpty) part.trim(),
    ];
  }
}
