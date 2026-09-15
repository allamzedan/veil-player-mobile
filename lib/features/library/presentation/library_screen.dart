import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:veil_mobile/app/router.dart';
import 'package:veil_mobile/core/storage/media_history_models.dart';
import 'package:veil_mobile/features/library/application/library_controller.dart';
import 'package:veil_mobile/features/library/application/media_history_controller.dart';
import 'package:veil_mobile/core/tracks/track_summary.dart';
import 'package:veil_mobile/features/tracks/presentation/track_details_sheet.dart';
import 'package:veil_mobile/features/library/application/track_pack_controller.dart';
import 'package:veil_mobile/features/library/application/video_folder_controller.dart';
import 'package:veil_mobile/features/library/presentation/library_folders_section.dart';
import 'package:veil_mobile/features/library/presentation/library_history_widgets.dart';
import 'package:veil_mobile/features/library/presentation/library_primary_actions.dart';
import 'package:veil_mobile/features/library/presentation/library_saved_tracks_section.dart';
import 'package:veil_mobile/features/library/presentation/library_section_visibility.dart';
import 'package:veil_mobile/features/library/presentation/library_track_packs_section.dart';
import 'package:veil_mobile/features/player/application/player_setup_controller.dart';
import 'package:veil_mobile/features/track_builder/application/track_builder_controller.dart';
import 'package:veil_mobile/shared/constants/app_strings.dart';
import 'package:veil_mobile/shared/widgets/app_snackbar.dart';
import 'package:veil_mobile/shared/widgets/app_scaffold.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(mediaHistoryControllerProvider);

    return AppScaffold(
      title: AppStrings.libraryTitle,
      actions: [
        IconButton(
          onPressed: () async {
            await Future.wait([
              ref.read(mediaHistoryControllerProvider.notifier).refresh(),
              ref.read(libraryControllerProvider.notifier).refresh(),
              ref.read(trackPackControllerProvider.notifier).refresh(),
              ref.read(videoFolderControllerProvider.notifier).refresh(),
            ]);
          },
          icon: const Icon(Icons.refresh),
          tooltip: AppStrings.libraryRefresh,
        ),
      ],
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final ctrl = ref.read(playerSetupControllerProvider.notifier);
          await ctrl.pickVideo();
          if (context.mounted &&
              ref.read(playerSetupControllerProvider).hasVideoSelection) {
            context.go(AppRoutes.player);
          }
        },
        tooltip: AppStrings.libraryOpenVideoAction,
        child: const Icon(Icons.play_arrow_outlined),
      ),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _HistoryError(
          onRetry: () =>
              ref.read(mediaHistoryControllerProvider.notifier).refresh(),
        ),
        data: (history) {
          return RefreshIndicator(
            onRefresh: () async {
              await Future.wait([
                ref.read(mediaHistoryControllerProvider.notifier).refresh(),
                ref.read(libraryControllerProvider.notifier).refresh(),
                ref.read(trackPackControllerProvider.notifier).refresh(),
              ]);
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
              children: [
                const LibraryPrimaryActions(),
                const LibraryFoldersSection(),
                if (libraryShowsLastSession(history)) ...[
                  LibrarySectionHeader(
                    title: AppStrings.libraryLastSessionSection,
                    compact: true,
                  ),
                  LibraryLastSessionCard(
                    session: history.lastSession!,
                    onResume: () => _resumeLastSession(context, ref),
                  ),
                ],
                if (libraryShowsRecentVideos(history)) ...[
                  LibrarySectionHeader(
                    title: AppStrings.libraryRecentVideosSection,
                    compact: true,
                  ),
                  ...history.recentVideos.map(
                    (entry) => LibraryRecentVideoTile(
                      entry: entry,
                      compact: true,
                      onOpen: () => _openRecentVideo(context, ref, entry),
                      onRemove: () => _removeRecentVideo(context, ref, entry),
                    ),
                  ),
                ],
                if (libraryShowsRecentTracks(history)) ...[
                  LibrarySectionHeader(
                    title: AppStrings.libraryRecentTracksSection,
                    compact: true,
                  ),
                  ...history.recentTracks.map(
                    (entry) => LibraryRecentTrackTile(
                      entry: entry,
                      compact: true,
                      onOpen: () => _openRecentTrack(context, ref, entry),
                      onPreview: () => _previewRecentTrack(context, ref, entry),
                      onRemove: () => _removeRecentTrack(context, ref, entry),
                    ),
                  ),
                ],
                const LibraryTrackPacksSection(),
                LibrarySavedTracksSection(
                  onEditTrack: (item) => context.go(
                    AppRoutes.trackBuilderEdit(item.track.id),
                  ),
                  onDeleteTrack: (item) => _confirmDelete(context, ref, item),
                  onCreateTrack: () => _createNewTrack(context, ref),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _resumeLastSession(BuildContext context, WidgetRef ref) async {
    context.go(AppRoutes.player);
    final result = await ref
        .read(playerSetupControllerProvider.notifier)
        .resumeLastSession();
    await ref.read(mediaHistoryControllerProvider.notifier).refresh();
    if (!context.mounted) {
      return;
    }
    if (!result.success && result.message != null) {
      showAppSnackBar(
        context,
        result.message!,
        isError: true,
        abovePlayerControls: true,
      );
      return;
    }
    if (result.warning != null) {
      showAppSnackBar(context, result.warning!, abovePlayerControls: true);
    }
  }

  Future<void> _openRecentVideo(
    BuildContext context,
    WidgetRef ref,
    RecentVideoEntry entry,
  ) async {
    final path = entry.path;
    if (path == null || path.isEmpty) {
      _showSnack(context, AppStrings.mediaHistorySourceUnavailable);
      return;
    }

    final error = await ref
        .read(playerSetupControllerProvider.notifier)
        .openVideoFromPath(
          path: path,
          filename: entry.filename,
          initialPosition: Duration(milliseconds: entry.lastPlaybackPositionMs),
        );
    await ref.read(mediaHistoryControllerProvider.notifier).refresh();
    if (!context.mounted) {
      return;
    }
    if (error != null) {
      _showSnack(context, error);
      return;
    }
    context.go(AppRoutes.player);
  }

  Future<void> _previewRecentTrack(
    BuildContext context,
    WidgetRef ref,
    RecentTrackEntry entry,
  ) async {
    final path = entry.path;
    if (path == null || path.isEmpty) {
      _showSnack(context, AppStrings.mediaHistorySourceUnavailable);
      return;
    }

    final track = await loadTrackFromPathForPreview(path);
    if (!context.mounted) {
      return;
    }
    if (track == null) {
      _showSnack(context, AppStrings.playerTrackLoadError);
      return;
    }

    await TrackDetailsSheet.show(
      context: context,
      track: track,
      onViewAllSegments: () => _openRecentTrack(context, ref, entry),
    );
  }

  Future<void> _openRecentTrack(
    BuildContext context,
    WidgetRef ref,
    RecentTrackEntry entry,
  ) async {
    final path = entry.path;
    if (path == null || path.isEmpty) {
      _showSnack(context, AppStrings.mediaHistorySourceUnavailable);
      return;
    }

    final player = ref.read(playerSetupControllerProvider.notifier);
    final error = await player.loadTrackFromPath(
      path: path,
      filename: entry.filename,
    );
    await ref.read(mediaHistoryControllerProvider.notifier).refresh();
    if (!context.mounted) {
      return;
    }
    if (error != null) {
      _showSnack(context, error);
      return;
    }
    context.go(AppRoutes.player);
  }

  Future<void> _removeRecentVideo(
    BuildContext context,
    WidgetRef ref,
    RecentVideoEntry entry,
  ) async {
    final removed = await ref
        .read(mediaHistoryControllerProvider.notifier)
        .removeRecentVideo(entry.dedupeKey);
    if (!context.mounted) {
      return;
    }
    _showSnack(context, mediaHistorySnackMessage(success: removed));
  }

  Future<void> _removeRecentTrack(
    BuildContext context,
    WidgetRef ref,
    RecentTrackEntry entry,
  ) async {
    final removed = await ref
        .read(mediaHistoryControllerProvider.notifier)
        .removeRecentTrack(entry.dedupeKey);
    if (!context.mounted) {
      return;
    }
    _showSnack(context, mediaHistorySnackMessage(success: removed));
  }

  void _showSnack(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    showAppSnackBar(context, message, isError: isError);
  }

  void _createNewTrack(BuildContext context, WidgetRef ref) {
    ref.read(trackBuilderControllerProvider.notifier).resetTrack();
    context.go(AppRoutes.trackBuilder);
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    LibraryTrackItem item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppStrings.deleteTrackTitle),
        content: Text(AppStrings.deleteTrackMessage(item.track.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(AppStrings.delete),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    final trackId = item.track.id;
    final result = await ref
        .read(libraryControllerProvider.notifier)
        .deleteTrack(trackId);

    if (result.success) {
      final builderState = ref.read(trackBuilderControllerProvider);
      if (builderState.track.id == trackId) {
        ref.read(trackBuilderControllerProvider.notifier).resetTrack();
      }
    }

    if (!context.mounted) {
      return;
    }

    showAppSnackBar(context, result.message, isError: !result.success);
  }
}

class _HistoryError extends StatelessWidget {
  const _HistoryError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppStrings.libraryLoadError,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: onRetry,
              child: Text(AppStrings.libraryRefresh),
            ),
          ],
        ),
      ),
    );
  }
}
