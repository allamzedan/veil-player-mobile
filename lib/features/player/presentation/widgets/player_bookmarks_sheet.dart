import 'package:flutter/material.dart';
import 'package:veil_mobile/core/veil/bookmark_segments.dart';
import 'package:veil_mobile/core/veil/veil_segment.dart';
import 'package:veil_mobile/core/veil/veil_track.dart';
import 'package:veil_mobile/shared/constants/app_strings.dart';
import 'package:veil_mobile/shared/utils/veil_duration_format.dart';
import 'package:veil_mobile/shared/widgets/app_bottom_sheet.dart';

/// Lists bookmarks for the active track with jump, edit, and delete actions.
class PlayerBookmarksSheet {
  static Future<void> show({
    required BuildContext context,
    required VeilTrack? track,
    required Future<void> Function(Duration position) onSeek,
    required void Function(VeilSegment segment) onEdit,
    required void Function(VeilSegment segment) onDelete,
  }) {
    final bookmarks = BookmarkSegments.fromTrack(track);

    return AppBottomSheet.show<void>(
      context: context,
      maxHeightFactor: 0.7,
      builder: (sheetContext) {
        if (bookmarks.isEmpty) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Text(
              AppStrings.playerBookmarksEmpty,
              style: Theme.of(sheetContext).textTheme.bodyMedium,
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
          itemCount: bookmarks.length + 1,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                child: Text(
                  AppStrings.playerBookmarks,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              );
            }

            final bookmark = bookmarks[index - 1];
            final time = VeilDurationFormat.format(
              Duration(milliseconds: bookmark.pointMs),
            );
            final title = bookmark.label?.trim().isNotEmpty == true
                ? bookmark.label!.trim()
                : AppStrings.bookmarkTitle;
            final note = bookmark.notes?.trim();

            return ListTile(
              leading: Icon(
                Icons.bookmark,
                color: Theme.of(context).colorScheme.tertiary,
                size: 20,
              ),
              title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(
                note == null || note.isEmpty ? time : '$time · $note',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                onSeek(Duration(milliseconds: bookmark.pointMs));
              },
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  Navigator.pop(sheetContext);
                  switch (value) {
                    case 'edit':
                      onEdit(bookmark);
                    case 'delete':
                      onDelete(bookmark);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Text(AppStrings.segmentEdit),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(AppStrings.delete),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
