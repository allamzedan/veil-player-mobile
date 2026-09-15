import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:veil_mobile/app/router.dart';
import 'package:veil_mobile/features/library/application/video_folder_controller.dart';
import 'package:veil_mobile/features/library/presentation/library_history_widgets.dart';
import 'package:veil_mobile/features/player/application/player_setup_controller.dart';
import 'package:veil_mobile/shared/constants/app_strings.dart';
import 'package:veil_mobile/shared/utils/video_folder_scanner.dart';
import 'package:veil_mobile/shared/widgets/app_snackbar.dart';

class LibraryFoldersSection extends ConsumerStatefulWidget {
  const LibraryFoldersSection({super.key});

  @override
  ConsumerState<LibraryFoldersSection> createState() =>
      _LibraryFoldersSectionState();
}

class _LibraryFoldersSectionState extends ConsumerState<LibraryFoldersSection> {
  String? _expandedFolderPath;

  @override
  Widget build(BuildContext context) {
    final foldersAsync = ref.watch(videoFolderControllerProvider);

    return foldersAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (folders) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LibrarySectionHeader(
              title: AppStrings.libraryFoldersSection,
              compact: true,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: FilledButton.tonalIcon(
                onPressed: () => _chooseFolder(context),
                icon: const Icon(Icons.create_new_folder_outlined, size: 20),
                label: Text(AppStrings.libraryChooseFolder),
              ),
            ),
            if (folders.isEmpty)
              LibraryCompactHint(message: AppStrings.libraryBrowseVideos),
            for (final folder in folders)
              _FolderExpansion(
                folder: folder,
                expanded: _expandedFolderPath == folder.path,
                onExpansionChanged: (expanded) {
                  setState(() {
                    _expandedFolderPath = expanded ? folder.path : null;
                  });
                },
                onRemove: () => ref
                    .read(videoFolderControllerProvider.notifier)
                    .removeFolder(folder.path),
                onOpenVideo: (entry) => _openFolderVideo(context, entry),
              ),
          ],
        );
      },
    );
  }

  Future<void> _chooseFolder(BuildContext context) async {
    final path = await FilePicker.getDirectoryPath();
    if (path == null || path.isEmpty || !context.mounted) {
      return;
    }

    final parts = path.split(RegExp(r'[/\\]'));
    final name = parts.isNotEmpty ? parts.last : path;
    await ref
        .read(videoFolderControllerProvider.notifier)
        .addFolder(path: path, displayName: name);
  }

  Future<void> _openFolderVideo(
    BuildContext context,
    FolderVideoEntry entry,
  ) async {
    final error = await ref
        .read(playerSetupControllerProvider.notifier)
        .openVideoFromPath(path: entry.path, filename: entry.filename);
    if (!context.mounted) {
      return;
    }
    if (error != null) {
      showAppSnackBar(context, error, isError: true);
      return;
    }
    context.go(AppRoutes.player);
  }
}

class _FolderExpansion extends ConsumerWidget {
  const _FolderExpansion({
    required this.folder,
    required this.expanded,
    required this.onExpansionChanged,
    required this.onRemove,
    required this.onOpenVideo,
  });

  final SavedVideoFolder folder;
  final bool expanded;
  final ValueChanged<bool> onExpansionChanged;
  final VoidCallback onRemove;
  final ValueChanged<FolderVideoEntry> onOpenVideo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scan = ref
        .read(videoFolderControllerProvider.notifier)
        .scanFolder(folder.path);

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: expanded,
        onExpansionChanged: onExpansionChanged,
        leading: const Icon(Icons.folder_outlined, size: 20),
        title: Text(
          folder.displayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'remove') {
              onRemove();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'remove',
              child: Text(AppStrings.libraryRemoveFolder),
            ),
          ],
        ),
        children: [
          if (scan.restricted)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                scan.message ?? AppStrings.libraryFolderScanRestricted,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else if (scan.videos.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                AppStrings.libraryFolderEmpty,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else
            for (final video in scan.videos)
              ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                leading: const Icon(Icons.movie_outlined, size: 18),
                title: Text(
                  video.filename,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () => onOpenVideo(video),
              ),
        ],
      ),
    );
  }
}
