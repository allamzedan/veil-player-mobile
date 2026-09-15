import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veil_mobile/core/track_packs/track_pack.dart';
import 'package:veil_mobile/core/track_packs/track_pack_codec.dart';
import 'package:veil_mobile/features/library/application/library_controller.dart';
import 'package:veil_mobile/features/library/application/track_pack_controller.dart';
import 'package:veil_mobile/features/library/presentation/library_history_widgets.dart';
import 'package:veil_mobile/features/library/presentation/library_track_card.dart';
import 'package:veil_mobile/features/track_packs/presentation/track_pack_export_dialog.dart';
import 'package:veil_mobile/shared/constants/app_strings.dart';
import 'package:veil_mobile/shared/utils/veil_track_file_export.dart';
import 'package:veil_mobile/shared/widgets/app_snackbar.dart';

class LibrarySavedTracksSection extends ConsumerStatefulWidget {
  const LibrarySavedTracksSection({
    super.key,
    required this.onEditTrack,
    required this.onDeleteTrack,
    required this.onCreateTrack,
  });

  final void Function(LibraryTrackItem item) onEditTrack;
  final Future<void> Function(LibraryTrackItem item) onDeleteTrack;
  final VoidCallback onCreateTrack;

  @override
  ConsumerState<LibrarySavedTracksSection> createState() =>
      _LibrarySavedTracksSectionState();
}

class _LibrarySavedTracksSectionState
    extends ConsumerState<LibrarySavedTracksSection> {
  bool _selectionMode = false;
  final Set<String> _selectedTrackIds = <String>{};

  @override
  Widget build(BuildContext context) {
    final libraryAsync = ref.watch(libraryControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: LibrarySectionHeader(
                title: AppStrings.librarySavedTracksSection,
                compact: true,
              ),
            ),
            TextButton.icon(
              onPressed: widget.onCreateTrack,
              icon: const Icon(Icons.add, size: 18),
              label: Text(AppStrings.libraryCreateTrack),
            ),
            if (_selectionMode)
              TextButton(
                onPressed: _cancelSelection,
                child: Text(AppStrings.trackPackCancelSelection),
              )
            else
              TextButton.icon(
                onPressed: () => setState(() => _selectionMode = true),
                icon: const Icon(Icons.checklist_outlined, size: 18),
                label: Text(AppStrings.trackPackSelectTracks),
              ),
          ],
        ),
        if (_selectionMode && _selectedTrackIds.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: FilledButton.tonal(
                onPressed: () => _exportSelectedTracks(context),
                child: Text(AppStrings.trackPackExportSelected),
              ),
            ),
          ),
        libraryAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => LibraryEmptyHint(
            message: AppStrings.libraryLoadError,
          ),
          data: (items) {
            if (items.isEmpty) {
              if (_selectionMode) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    _cancelSelection();
                  }
                });
              }
              return LibraryCompactHint(
                message: AppStrings.libraryEmptyMessage,
              );
            }

            return Column(
              children: [
                for (final item in items)
                  LibraryTrackCard(
                    item: item,
                    selectionMode: _selectionMode,
                    selected: _selectedTrackIds.contains(item.track.id),
                    onSelectionChanged: _selectionMode
                        ? (selected) => _toggleSelection(item.track.id, selected)
                        : null,
                    onEdit: _selectionMode
                        ? null
                        : () => widget.onEditTrack(item),
                    onDelete: _selectionMode
                        ? null
                        : () => widget.onDeleteTrack(item),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  void _toggleSelection(String trackId, bool selected) {
    setState(() {
      if (selected) {
        _selectedTrackIds.add(trackId);
      } else {
        _selectedTrackIds.remove(trackId);
      }
    });
  }

  void _cancelSelection() {
    setState(() {
      _selectionMode = false;
      _selectedTrackIds.clear();
    });
  }

  Future<void> _exportSelectedTracks(BuildContext context) async {
    final items = ref.read(libraryControllerProvider).value ?? [];
    final selectedTracks = [
      for (final item in items)
        if (_selectedTrackIds.contains(item.track.id)) item.track,
    ];
    if (selectedTracks.isEmpty) {
      return;
    }

    final form = await TrackPackExportDialog.show(
      context: context,
      selectedTrackCount: selectedTracks.length,
    );
    if (!context.mounted || form == null) {
      return;
    }

    final pack = ref.read(trackPackControllerProvider.notifier).buildPackFromTracks(
      title: form.title,
      tracks: selectedTracks,
      description: form.description,
      author: form.author.isEmpty ? TrackPack.defaultAuthor : form.author,
      tags: form.tags,
    );

    final result = await exportVeilTrackPackJsonFile(
      json: TrackPackCodec.encode(pack),
      fileName: veilTrackPackExportFileName(packTitle: pack.title),
    );

    if (!context.mounted) {
      return;
    }

    showAppSnackBar(
      context,
      result.success ? result.message : AppStrings.trackPackExportFailed,
      isError: !result.success,
    );

    if (result.success) {
      _cancelSelection();
    }
  }
}
