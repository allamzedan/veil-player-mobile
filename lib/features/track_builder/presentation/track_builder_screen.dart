import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veil_mobile/core/veil/veil_segment.dart';
import 'package:veil_mobile/core/veil/veil_segment_type.dart';
import 'package:veil_mobile/core/veil/veil_track.dart';
import 'package:veil_mobile/features/player/application/player_setup_controller.dart';
import 'package:veil_mobile/features/track_builder/application/track_builder_controller.dart';
import 'package:veil_mobile/features/track_builder/application/track_builder_state.dart';
import 'package:veil_mobile/features/track_builder/presentation/segment_card.dart';
import 'package:veil_mobile/features/track_builder/presentation/segment_editor_sheet.dart';
import 'package:veil_mobile/core/tracks/track_summary.dart';
import 'package:veil_mobile/features/tracks/presentation/track_details_sheet.dart';
import 'package:veil_mobile/features/tracks/presentation/track_preview_dialog.dart';
import 'package:veil_mobile/features/track_builder/presentation/track_builder_empty_segments.dart';
import 'package:veil_mobile/features/track_builder/presentation/track_builder_quick_add_row.dart';
import 'package:veil_mobile/features/track_builder/presentation/track_builder_segment_filter.dart';
import 'package:veil_mobile/features/track_builder/presentation/track_builder_segment_summary_header.dart';
import 'package:veil_mobile/features/track_builder/presentation/track_builder_segment_toolbar.dart';
import 'package:veil_mobile/features/track_builder/presentation/track_json_dialog.dart';
import 'package:veil_mobile/features/track_builder/presentation/track_metadata_panel.dart';
import 'package:veil_mobile/shared/constants/app_strings.dart';
import 'package:veil_mobile/shared/utils/veil_error_messages.dart';
import 'package:veil_mobile/shared/utils/veil_json_file_picker.dart';
import 'package:veil_mobile/shared/widgets/app_scaffold.dart';

class TrackBuilderScreen extends ConsumerStatefulWidget {
  const TrackBuilderScreen({super.key, this.trackId});

  final String? trackId;

  @override
  ConsumerState<TrackBuilderScreen> createState() => _TrackBuilderScreenState();
}

class _TrackBuilderScreenState extends ConsumerState<TrackBuilderScreen> {
  late final TextEditingController _titleController;
  final TextEditingController _importController = TextEditingController();
  final TextEditingController _segmentSearchController =
      TextEditingController();
  SegmentListFilter _segmentFilter = SegmentListFilter.all;
  String? _loadedRouteTrackId;

  @override
  void initState() {
    super.initState();
    final track = ref.read(trackBuilderControllerProvider).track;
    _titleController = TextEditingController(text: track.title);
    _titleController.addListener(_onTitleChanged);
    _segmentSearchController.addListener(_onSegmentSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeLoadRouteTrack();
    });
  }

  @override
  void didUpdateWidget(TrackBuilderScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trackId != widget.trackId) {
      _loadedRouteTrackId = null;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _maybeLoadRouteTrack(),
      );
    }
  }

  Future<void> _maybeLoadRouteTrack() async {
    final trackId = widget.trackId;
    if (trackId == null || trackId == _loadedRouteTrackId) {
      return;
    }

    _loadedRouteTrackId = trackId;
    final result = await ref
        .read(trackBuilderControllerProvider.notifier)
        .loadTrackById(trackId);

    if (!mounted) {
      return;
    }

    if (result.success) {
      _titleController.text = ref
          .read(trackBuilderControllerProvider)
          .track
          .title;
    } else {
      _showSnackBar(result);
    }
  }

  @override
  void dispose() {
    _titleController.removeListener(_onTitleChanged);
    _titleController.dispose();
    _importController.dispose();
    _segmentSearchController.removeListener(_onSegmentSearchChanged);
    _segmentSearchController.dispose();
    super.dispose();
  }

  void _onSegmentSearchChanged() {
    setState(() {});
  }

  void _onTitleChanged() {
    ref
        .read(trackBuilderControllerProvider.notifier)
        .updateTitle(_titleController.text);
  }

  void _showSnackBar(TrackBuilderOperationResult result) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        backgroundColor: result.success
            ? null
            : Theme.of(context).colorScheme.error,
      ),
    );
  }

  Future<void> _saveTrack() async {
    final result = await ref
        .read(trackBuilderControllerProvider.notifier)
        .saveCurrentTrack();
    _showSnackBar(result);
  }

  Future<void> _exportJson() async {
    final notifier = ref.read(trackBuilderControllerProvider.notifier);
    final check = notifier.validateForExport();
    if (!check.success) {
      _showSnackBar(check);
      return;
    }

    final json = notifier.exportCurrentTrackJson();
    await showTrackJsonDialog(
      context: context,
      title: AppStrings.exportJsonTitle,
      json: json,
    );
  }

  void _showJsonPreview() {
    final notifier = ref.read(trackBuilderControllerProvider.notifier);
    final check = notifier.validateForExport();
    if (!check.success) {
      _showSnackBar(check);
      return;
    }

    final json = notifier.exportJsonPreview();
    showTrackJsonDialog(
      context: context,
      title: AppStrings.jsonPreviewTitle,
      json: json,
    );
  }

  Future<void> _previewAndApplyImportedJson(String source) async {
    final track = tryDecodeTrackJson(source);
    if (track == null) {
      _showSnackBar(
        TrackBuilderOperationResult(
          success: false,
          message: AppStrings.importValidationFailed,
        ),
      );
      return;
    }

    final load = await TrackPreviewDialog.show(context: context, track: track);
    if (!mounted || load != true) {
      return;
    }

    await _applyImportedJson(source);
  }

  Future<void> _applyImportedJson(String source) async {
    final result = await ref
        .read(trackBuilderControllerProvider.notifier)
        .importFromJson(source);
    _showSnackBar(result);
    if (result.success && mounted) {
      _titleController.text = ref
          .read(trackBuilderControllerProvider)
          .track
          .title;
    }
  }

  Future<void> _importFromFile() async {
    try {
      final content = await VeilJsonFilePicker.pickJsonContent();
      if (content == null || !mounted) {
        return;
      }
      await _previewAndApplyImportedJson(content);
    } on Object catch (error) {
      if (!mounted) {
        return;
      }
      _showSnackBar(
        TrackBuilderOperationResult(
          success: false,
          message: VeilErrorMessages.fromException(error),
        ),
      );
    }
  }

  Future<void> _showPasteImportDialog() async {
    _importController.clear();
    final imported = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppStrings.importJsonTitle),
        content: SizedBox(
          width: double.maxFinite,
          child: TextField(
            controller: _importController,
            decoration: InputDecoration(hintText: AppStrings.importJsonHint),
            maxLines: 12,
            keyboardType: TextInputType.multiline,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(AppStrings.importJsonAction),
          ),
        ],
      ),
    );

    if (imported != true || !mounted) {
      return;
    }

    await _previewAndApplyImportedJson(_importController.text);
  }

  Future<void> _confirmNewTrack() async {
    final controller = ref.read(trackBuilderControllerProvider.notifier);
    if (controller.shouldConfirmDiscard) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppStrings.newTrackConfirmTitle),
          content: Text(AppStrings.newTrackConfirmMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(AppStrings.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(AppStrings.continueAction),
            ),
          ],
        ),
      );
      if (confirmed != true) {
        return;
      }
    }

    controller.resetTrack();
    _titleController.text = ref
        .read(trackBuilderControllerProvider)
        .track
        .title;
  }

  void _openAddSegment([VeilSegmentType? initialType]) {
    SegmentEditorSheet.show(
      context: context,
      initialType: initialType,
      onSave: (draft) {
        ref
            .read(trackBuilderControllerProvider.notifier)
            .addSegment(
              type: draft.type,
              startMs: draft.startMs,
              endMs: draft.endMs,
              label: draft.label,
              notes: draft.notes,
            );
      },
    );
  }

  void _seekToSegment(VeilSegment segment) {
    final setup = ref.read(playerSetupControllerProvider);
    if (!setup.isVideoReady) {
      return;
    }
    ref
        .read(playerSetupControllerProvider.notifier)
        .seekTo(Duration(milliseconds: segment.startMs));
  }

  bool _canReorderSegments(String searchQuery) {
    return _segmentFilter == SegmentListFilter.all && searchQuery.isEmpty;
  }

  void _openEditSegment(VeilSegment segment) {
    SegmentEditorSheet.show(
      context: context,
      segment: segment,
      onSave: (updated) {
        ref
            .read(trackBuilderControllerProvider.notifier)
            .updateSegment(updated);
      },
    );
  }

  void _deleteSegment(VeilSegment segment) {
    ref.read(trackBuilderControllerProvider.notifier).deleteSegment(segment.id);
  }

  Widget _buildSegmentList({
    required VeilTrack track,
    required List<VeilSegment> visibleSegments,
    required bool canReorder,
    required ColorScheme colorScheme,
  }) {
    if (visibleSegments.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          AppStrings.trackBuilderNoMatchingActions,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    if (!canReorder) {
      return Column(
        children: [
          for (final segment in visibleSegments)
            SegmentCard(
              key: ValueKey(segment.id),
              segment: segment,
              onEdit: () => _openEditSegment(segment),
              onDelete: () => _deleteSegment(segment),
              onTap: () => _seekToSegment(segment),
            ),
        ],
      );
    }

    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: track.segments.length,
      onReorderItem: (oldIndex, newIndex) {
        ref
            .read(trackBuilderControllerProvider.notifier)
            .reorderSegments(oldIndex, newIndex);
      },
      itemBuilder: (context, index) {
        final segment = track.segments[index];
        return SegmentCard(
          key: ValueKey(segment.id),
          segment: segment,
          onEdit: () => _openEditSegment(segment),
          onDelete: () => _deleteSegment(segment),
          onTap: () => _seekToSegment(segment),
          reorderHandle: ReorderableDragStartListener(
            index: index,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(start: 4),
              child: Icon(
                Icons.drag_handle,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final builderState = ref.watch(trackBuilderControllerProvider);
    final track = builderState.track;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final searchQuery = _segmentSearchController.text;
    final visibleSegments = filterBuilderSegments(
      segments: track.segments,
      filter: _segmentFilter,
      searchQuery: searchQuery,
      typeLabel: (type) => AppStrings.segmentTypeLabel(type.name),
    );
    final canReorder = _canReorderSegments(searchQuery.trim());

    ref.listen(trackBuilderControllerProvider, (previous, next) {
      if (previous?.track.title != next.track.title &&
          _titleController.text != next.track.title) {
        _titleController.text = next.track.title;
      }
    });

    return AppScaffold(
      title: AppStrings.trackBuilderTitle,
      actions: [
        IconButton(
          onPressed: _saveTrack,
          icon: const Icon(Icons.save_outlined),
          tooltip: AppStrings.saveTrack,
        ),
        PopupMenuButton<String>(
          tooltip: AppStrings.moreActions,
          onSelected: (value) {
            switch (value) {
              case 'new':
                _confirmNewTrack();
              case 'import_file':
                _importFromFile();
              case 'import_paste':
                _showPasteImportDialog();
              case 'export':
                _exportJson();
              case 'preview':
                _showJsonPreview();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(value: 'new', child: Text(AppStrings.newTrack)),
            PopupMenuItem(
              value: 'import_file',
              child: Text(AppStrings.importJsonFromFile),
            ),
            PopupMenuItem(
              value: 'import_paste',
              child: Text(AppStrings.importJsonPaste),
            ),
            PopupMenuItem(value: 'export', child: _ExportMenuItem(track: track)),
            PopupMenuItem(
              value: 'preview',
              child: Text(AppStrings.jsonPreview),
            ),
          ],
        ),
      ],
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 0),
                child: TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: AppStrings.trackTitleLabel,
                    hintText: AppStrings.trackTitleHint,
                  ),
                  textInputAction: TextInputAction.done,
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 20, 0),
                child: _TrackStatusPanel(state: builderState),
              ),
              TrackMetadataPanel(track: track),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 0),
                child: TrackBuilderQuickAddRow(onAdd: _openAddSegment),
              ),
              if (track.segments.isEmpty)
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
                  child: TrackBuilderEmptySegments(onAdd: _openAddSegment),
                )
              else ...[
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 0),
                  child: TrackBuilderSegmentToolbar(
                    searchController: _segmentSearchController,
                    filter: _segmentFilter,
                    onFilterChanged: (filter) {
                      setState(() => _segmentFilter = filter);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 20, 8),
                  child: TrackBuilderSegmentSummaryHeader(track: track),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
                  child: _buildSegmentList(
                    track: track,
                    visibleSegments: visibleSegments,
                    canReorder: canReorder,
                    colorScheme: colorScheme,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TrackStatusPanel extends StatelessWidget {
  const _TrackStatusPanel({required this.state});

  final TrackBuilderState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final uiStatus = state.uiStatus;
    final errors = state.validationErrors;

    final appearance = switch (uiStatus) {
      TrackBuilderUiStatus.draft => _StatusAppearance(
        background: colorScheme.surfaceContainerHighest,
        foreground: colorScheme.onSurfaceVariant,
        icon: Icons.edit_note_outlined,
        title: state.statusMessage ?? AppStrings.trackStatusDraft,
      ),
      TrackBuilderUiStatus.editing => _StatusAppearance(
        background: colorScheme.surfaceContainerHigh,
        foreground: colorScheme.onSurface,
        icon: Icons.edit_outlined,
        title: state.statusMessage ?? AppStrings.trackStatusUnsaved,
      ),
      TrackBuilderUiStatus.readyToSave => _StatusAppearance(
        background: colorScheme.primaryContainer,
        foreground: colorScheme.onPrimaryContainer,
        icon: Icons.check_circle_outline,
        title: state.statusMessage ?? AppStrings.trackStatusReadyToSave,
      ),
      TrackBuilderUiStatus.requiresAttention => _StatusAppearance(
        background: colorScheme.errorContainer,
        foreground: colorScheme.onErrorContainer,
        icon: Icons.error_outline,
        title: AppStrings.validationRequiresAttention,
      ),
    };

    return Material(
      color: appearance.background,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(appearance.icon, color: appearance.foreground, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    appearance.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: appearance.foreground,
                    ),
                  ),
                ),
              ],
            ),
            if (uiStatus == TrackBuilderUiStatus.requiresAttention) ...[
              const SizedBox(height: 8),
              Text(
                AppStrings.validationFixHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: appearance.foreground,
                ),
              ),
              const SizedBox(height: 8),
              for (final error in errors)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '• $error',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: appearance.foreground,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusAppearance {
  const _StatusAppearance({
    required this.background,
    required this.foreground,
    required this.icon,
    required this.title,
  });

  final Color background;
  final Color foreground;
  final IconData icon;
  final String title;
}

class _ExportMenuItem extends StatelessWidget {
  const _ExportMenuItem({required this.track});

  final VeilTrack track;

  @override
  Widget build(BuildContext context) {
    final summary = TrackSummary.fromTrack(track);
    final subtitle = trackExportSummarySubtitle(summary);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.exportJson),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
