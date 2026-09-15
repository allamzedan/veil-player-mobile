import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veil_mobile/core/track_packs/track_pack.dart';
import 'package:veil_mobile/core/track_packs/track_pack_codec.dart';
import 'package:veil_mobile/core/storage/storage_providers.dart';
import 'package:veil_mobile/features/library/application/track_pack_controller.dart';
import 'package:veil_mobile/features/library/presentation/library_history_widgets.dart';
import 'package:veil_mobile/features/library/presentation/library_pack_card.dart';
import 'package:veil_mobile/features/library/presentation/library_section_visibility.dart';
import 'package:veil_mobile/features/track_packs/presentation/track_pack_details_sheet.dart';
import 'package:veil_mobile/features/track_packs/presentation/track_pack_preview_dialog.dart';
import 'package:veil_mobile/shared/constants/app_strings.dart';
import 'package:veil_mobile/shared/utils/veil_error_messages.dart';
import 'package:veil_mobile/shared/utils/veil_pack_file_picker.dart';
import 'package:veil_mobile/shared/utils/veil_track_file_export.dart';
import 'package:veil_mobile/shared/widgets/app_snackbar.dart';

class LibraryTrackPacksSection extends ConsumerStatefulWidget {
  const LibraryTrackPacksSection({super.key});

  static Future<void> importPack(BuildContext context, WidgetRef ref) =>
      _LibraryTrackPacksSectionState.importPack(context, ref);

  @override
  ConsumerState<LibraryTrackPacksSection> createState() =>
      _LibraryTrackPacksSectionState();
}

class _LibraryTrackPacksSectionState
    extends ConsumerState<LibraryTrackPacksSection> {
  bool _sectionExpanded = false;
  bool _samplesExpanded = false;

  @override
  Widget build(BuildContext context) {
    final packsAsync = ref.watch(trackPackControllerProvider);

    return packsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (error, _) => const SizedBox.shrink(),
      data: (packs) {
        final split = splitTrackPacks(packs);
        final imported = split.imported;
        final samples = split.samples;

        if (imported.isEmpty && samples.isEmpty) {
          return const SizedBox.shrink();
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          clipBehavior: Clip.antiAlias,
          child: ExpansionTile(
            initiallyExpanded: _sectionExpanded,
            onExpansionChanged: (expanded) =>
                setState(() => _sectionExpanded = expanded),
            title: Text(
              AppStrings.libraryTrackPacksSection,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            children: [
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  onPressed: () => importPack(context, ref),
                  child: Text(AppStrings.trackPackImport),
                ),
              ),
              if (imported.isEmpty && samples.isNotEmpty)
                LibraryCompactHint(message: AppStrings.trackPackNoPacks),
              for (final pack in imported)
                LibraryPackCard(
                  pack: pack,
                  onOpen: () => TrackPackDetailsSheet.show(
                    context: context,
                    pack: pack,
                  ),
                  onExport: () => _exportPack(context, ref, pack),
                  onDelete: () => _confirmDeletePack(context, ref, pack),
                ),
              if (samples.isNotEmpty)
                _SamplePacksExpansion(
                  expanded: _samplesExpanded,
                  onToggle: () =>
                      setState(() => _samplesExpanded = !_samplesExpanded),
                  packs: samples,
                  onOpen: (pack) => TrackPackDetailsSheet.show(
                    context: context,
                    pack: pack,
                  ),
                  onExport: (pack) => _exportPack(context, ref, pack),
                  onDelete: (pack) => _confirmDeletePack(context, ref, pack),
                ),
            ],
          ),
        );
      },
    );
  }

  static Future<void> importPack(BuildContext context, WidgetRef ref) async {
    try {
      final picked = await VeilPackFilePicker.pickPackFile();
      if (!context.mounted || picked == null) {
        return;
      }

      final pack = TrackPackCodec.tryDecode(picked.content);
      if (pack == null) {
        showAppSnackBar(
          context,
          AppStrings.trackPackImportFailed,
          isError: true,
        );
        return;
      }

      final confirmed = await TrackPackPreviewDialog.show(
        context: context,
        pack: pack,
      );
      if (!context.mounted || confirmed != true) {
        return;
      }

      final result = await ref
          .read(trackPackControllerProvider.notifier)
          .importPack(pack);
      if (!context.mounted) {
        return;
      }
      showAppSnackBar(
        context,
        result.message,
        isError: !result.success,
      );
    } on Object catch (error) {
      if (!context.mounted) {
        return;
      }
      showAppSnackBar(
        context,
        VeilErrorMessages.fromException(error),
        isError: true,
      );
    }
  }

  Future<void> _exportPack(
    BuildContext context,
    WidgetRef ref,
    TrackPack pack,
  ) async {
    final storage = ref.read(trackPackStorageServiceProvider);
    final json = storage.exportPackJson(pack);
    final result = await exportVeilTrackPackJsonFile(
      json: json,
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
  }

  Future<void> _confirmDeletePack(
    BuildContext context,
    WidgetRef ref,
    TrackPack pack,
  ) async {
    final summary = pack.title.trim().isEmpty
        ? TrackPack.defaultUntitledTitle
        : pack.title.trim();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppStrings.trackPackDeleteTitle),
        content: Text(AppStrings.trackPackDeleteMessage(summary)),
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

    final result = await ref
        .read(trackPackControllerProvider.notifier)
        .deletePack(pack.id);
    if (!context.mounted) {
      return;
    }
    showAppSnackBar(
      context,
      result.message,
      isError: !result.success,
    );
  }
}

class _SamplePacksExpansion extends StatelessWidget {
  const _SamplePacksExpansion({
    required this.expanded,
    required this.onToggle,
    required this.packs,
    required this.onOpen,
    required this.onExport,
    required this.onDelete,
  });

  final bool expanded;
  final VoidCallback onToggle;
  final List<TrackPack> packs;
  final void Function(TrackPack pack) onOpen;
  final void Function(TrackPack pack) onExport;
  final void Function(TrackPack pack) onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            child: Row(
              children: [
                Icon(
                  expanded ? Icons.expand_less : Icons.expand_more,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  AppStrings.samplePacks,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                Text(
                  '${packs.length}',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (expanded)
          for (final pack in packs)
            LibraryPackCard(
              pack: pack,
              onOpen: () => onOpen(pack),
              onExport: () => onExport(pack),
              onDelete: () => onDelete(pack),
            ),
      ],
    );
  }
}
