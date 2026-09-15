import 'package:flutter/material.dart';
import 'package:veil_mobile/core/storage/media_history_models.dart';
import 'package:veil_mobile/shared/constants/app_strings.dart';
import 'package:veil_mobile/shared/utils/veil_duration_format.dart';

class LibrarySectionHeader extends StatelessWidget {
  const LibrarySectionHeader({
    super.key,
    required this.title,
    this.compact = false,
  });

  final String title;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(4, compact ? 12 : 16, 4, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class LibraryCompactHint extends StatelessWidget {
  const LibraryCompactHint({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 6),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class LibraryEmptyHint extends StatelessWidget {
  const LibraryEmptyHint({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class LibraryLastSessionCard extends StatelessWidget {
  const LibraryLastSessionCard({
    super.key,
    required this.session,
    required this.onResume,
  });

  final LastSessionSnapshot session;
  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    final videoName = session.videoFilename ?? AppStrings.playerNoVideoSelected;
    final position = VeilDurationFormat.format(
      Duration(milliseconds: session.playbackPositionMs),
    );
    final speed = session.playbackSpeed == session.playbackSpeed.roundToDouble()
        ? '${session.playbackSpeed.toInt()}x'
        : '${session.playbackSpeed}x';

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: const Icon(Icons.history),
        title: Text(videoName, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          AppStrings.libraryLastSessionMeta(position, speed),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: FilledButton.tonal(
          onPressed: onResume,
          child: Text(AppStrings.libraryResumeSession),
        ),
      ),
    );
  }
}

class LibraryRecentVideoTile extends StatelessWidget {
  const LibraryRecentVideoTile({
    super.key,
    required this.entry,
    required this.onOpen,
    required this.onRemove,
    this.compact = false,
  });

  final RecentVideoEntry entry;
  final VoidCallback onOpen;
  final VoidCallback onRemove;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return ListTile(
        dense: true,
        visualDensity: VisualDensity.compact,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        leading: const Icon(Icons.movie_outlined, size: 20),
        title: Text(
          entry.filename,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.close, size: 18),
          onPressed: onRemove,
          tooltip: AppStrings.libraryRemoveFromHistory,
        ),
        onTap: onOpen,
      );
    }

    final duration = VeilDurationFormat.format(
      Duration(milliseconds: entry.durationMs),
    );
    final position = VeilDurationFormat.format(
      Duration(milliseconds: entry.lastPlaybackPositionMs),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        leading: const Icon(Icons.movie_outlined),
        title: Text(
          entry.filename,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          AppStrings.libraryRecentVideoMeta(duration, position),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'open':
                onOpen();
              case 'remove':
                onRemove();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'open',
              child: Text(AppStrings.libraryOpenVideo),
            ),
            PopupMenuItem(
              value: 'remove',
              child: Text(AppStrings.libraryRemoveFromHistory),
            ),
          ],
        ),
        onTap: onOpen,
      ),
    );
  }
}

class LibraryRecentTrackTile extends StatelessWidget {
  const LibraryRecentTrackTile({
    super.key,
    required this.entry,
    required this.onOpen,
    required this.onPreview,
    required this.onRemove,
    this.compact = false,
  });

  final RecentTrackEntry entry;
  final VoidCallback onOpen;
  final VoidCallback onPreview;
  final VoidCallback onRemove;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return ListTile(
        dense: true,
        visualDensity: VisualDensity.compact,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        leading: const Icon(Icons.layers_outlined, size: 20),
        title: Text(
          entry.filename,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.close, size: 18),
          onPressed: onRemove,
          tooltip: AppStrings.libraryRemoveFromHistory,
        ),
        onTap: onOpen,
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        leading: const Icon(Icons.layers_outlined),
        title: Text(
          entry.filename,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(AppStrings.libraryRecentTrackMeta(entry.segmentCount)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: onPreview,
              icon: const Icon(Icons.preview_outlined),
              tooltip: AppStrings.trackPreviewTrack,
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'open':
                    onOpen();
                  case 'remove':
                    onRemove();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'open',
                  child: Text(AppStrings.libraryOpenTrack),
                ),
                PopupMenuItem(
                  value: 'remove',
                  child: Text(AppStrings.libraryRemoveFromHistory),
                ),
              ],
            ),
          ],
        ),
        onTap: onOpen,
      ),
    );
  }
}
