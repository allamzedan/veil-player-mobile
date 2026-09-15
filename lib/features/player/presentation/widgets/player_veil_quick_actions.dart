import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:veil_mobile/app/router.dart';
import 'package:veil_mobile/core/tracks/track_summary.dart';
import 'package:veil_mobile/core/veil/veil_segment_type.dart';
import 'package:veil_mobile/features/tracks/presentation/track_details_sheet.dart';
import 'package:veil_mobile/shared/constants/app_strings.dart';
import 'package:veil_mobile/shared/utils/veil_time_input.dart';
import 'package:veil_mobile/shared/widgets/app_bottom_sheet.dart';
import 'package:veil_mobile/shared/widgets/app_snackbar.dart';
import 'package:video_player/video_player.dart';

/// Floating "+ VEIL" quick-action entry and bottom sheets.
class PlayerVeilQuickActions {
  static void showMenu({
    required BuildContext context,
    required VideoPlayerController? videoController,
    required bool canAddQuickActions,
    required bool canExportTrack,
    TrackSummary? trackSummary,
    required VoidCallback onLoadTrack,
    required void Function(VeilSegmentType type, int startMs, int endMs)
    onSaveQuickAction,
    required void Function(String title, String? note) onSaveBookmark,
    required VoidCallback onStartMaskPlacement,
    required VoidCallback onOpenSegments,
    VoidCallback? onOpenBookmarks,
    required VoidCallback onOpenManualBuilder,
    required Future<void> Function()? onExportTrack,
    required Future<void> Function()? onPreviewJson,
  }) {
    AppBottomSheet.show<void>(
      context: context,
      maxHeightFactor: 0.75,
      scrollable: false,
      builder: (sheetContext) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: [
          ListTile(
            leading: const Icon(Icons.view_list_outlined),
            title: Text(AppStrings.playerTrackSegments),
            onTap: () {
              Navigator.pop(sheetContext);
              onOpenSegments();
            },
          ),
          if (onOpenBookmarks != null)
            ListTile(
              leading: const Icon(Icons.bookmarks_outlined),
              title: Text(AppStrings.playerBookmarks),
              onTap: () {
                Navigator.pop(sheetContext);
                onOpenBookmarks();
              },
            ),
          ListTile(
            leading: const Icon(Icons.crop_square_outlined),
            title: Text(AppStrings.playerQuickAddMask),
            onTap: () {
              Navigator.pop(sheetContext);
              if (!canAddQuickActions) {
                showAppSnackBar(
                  context,
                  AppStrings.playerQuickActionRequiresVideo,
                  abovePlayerControls: true,
                );
                return;
              }
              onStartMaskPlacement();
            },
          ),
          ListTile(
            leading: const Icon(Icons.volume_off_outlined),
            title: Text(AppStrings.playerQuickAddMute),
            onTap: () {
              Navigator.pop(sheetContext);
              _openDurationSheet(
                context: context,
                actionType: VeilSegmentType.mute,
                videoController: videoController,
                canAddQuickActions: canAddQuickActions,
                onSave: (startMs, endMs) =>
                    onSaveQuickAction(VeilSegmentType.mute, startMs, endMs),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.skip_next_outlined),
            title: Text(AppStrings.playerQuickAddSkip),
            onTap: () {
              Navigator.pop(sheetContext);
              _openDurationSheet(
                context: context,
                actionType: VeilSegmentType.skip,
                videoController: videoController,
                canAddQuickActions: canAddQuickActions,
                onSave: (startMs, endMs) =>
                    onSaveQuickAction(VeilSegmentType.skip, startMs, endMs),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.bookmark_outline),
            title: Text(AppStrings.playerQuickAddBookmark),
            onTap: () {
              Navigator.pop(sheetContext);
              _openBookmarkSheet(
                context: context,
                videoController: videoController,
                canAddQuickActions: canAddQuickActions,
                onSave: onSaveBookmark,
              );
            },
          ),
          if (canExportTrack && onExportTrack != null)
            ListTile(
              leading: const Icon(Icons.upload_outlined),
              title: Text(AppStrings.playerExportTrack),
              subtitle: trackSummary == null
                  ? null
                  : _optionalExportSubtitle(trackSummary),
              onTap: () {
                Navigator.pop(sheetContext);
                onExportTrack();
              },
            ),
          if (canExportTrack && onPreviewJson != null)
            ListTile(
              leading: const Icon(Icons.code_outlined),
              title: Text(AppStrings.playerPreviewJson),
              onTap: () {
                Navigator.pop(sheetContext);
                onPreviewJson();
              },
            ),
          ListTile(
            leading: const Icon(Icons.build_outlined),
            title: Text(AppStrings.playerOpenManualBuilder),
            onTap: () {
              Navigator.pop(sheetContext);
              onOpenManualBuilder();
              context.go(AppRoutes.trackBuilder);
            },
          ),
          ListTile(
            leading: const Icon(Icons.layers_outlined),
            title: Text(AppStrings.playerLoadVeilTrack),
            onTap: () {
              Navigator.pop(sheetContext);
              onLoadTrack();
            },
          ),
        ],
      ),
    );
  }

  static Widget? _optionalExportSubtitle(TrackSummary summary) {
    final text = trackExportSummarySubtitle(summary);
    if (text == null) {
      return null;
    }
    return Text(text);
  }

  static void showDurationSheetForType({
    required BuildContext context,
    required VeilSegmentType actionType,
    required VideoPlayerController? videoController,
    required bool canAddQuickActions,
    required void Function(int startMs, int endMs) onSave,
    String? titleOverride,
  }) {
    _openDurationSheet(
      context: context,
      actionType: actionType,
      videoController: videoController,
      canAddQuickActions: canAddQuickActions,
      onSave: onSave,
      titleOverride: titleOverride,
    );
  }

  static void showMaskDurationSheet({
    required BuildContext context,
    required VideoPlayerController? videoController,
    required Map<String, dynamic> maskRect,
    required void Function(int startMs, int endMs, Map<String, dynamic> maskRect)
    onSave,
  }) {
    _openDurationSheet(
      context: context,
      actionType: VeilSegmentType.mask,
      videoController: videoController,
      canAddQuickActions: true,
      titleOverride: AppStrings.playerQuickAddMask,
      onSave: (startMs, endMs) => onSave(startMs, endMs, maskRect),
    );
  }

  static void showBookmarkSheet({
    required BuildContext context,
    required VideoPlayerController? videoController,
    required bool canAddQuickActions,
    required void Function(String title, String? note) onSave,
  }) {
    _openBookmarkSheet(
      context: context,
      videoController: videoController,
      canAddQuickActions: canAddQuickActions,
      onSave: onSave,
    );
  }

  static void _openBookmarkSheet({
    required BuildContext context,
    required VideoPlayerController? videoController,
    required bool canAddQuickActions,
    required void Function(String title, String? note) onSave,
  }) {
    if (!canAddQuickActions) {
      showAppSnackBar(
        context,
        AppStrings.playerQuickActionRequiresVideo,
        abovePlayerControls: true,
      );
      return;
    }

    final position = videoController?.value.position ?? Duration.zero;

    AppBottomSheet.show<void>(
      context: context,
      builder: (sheetContext) => _QuickBookmarkSheet(
        position: position,
        onSave: (title, note) {
          Navigator.pop(sheetContext);
          onSave(title, note);
        },
      ),
    );
  }

  static void _openDurationSheet({
    required BuildContext context,
    required VeilSegmentType actionType,
    required VideoPlayerController? videoController,
    required bool canAddQuickActions,
    required void Function(int startMs, int endMs) onSave,
    String? titleOverride,
  }) {
    if (!canAddQuickActions) {
      showAppSnackBar(
        context,
        AppStrings.playerQuickActionRequiresVideo,
        abovePlayerControls: true,
      );
      return;
    }

    final position = videoController?.value.position ?? Duration.zero;
    final actionLabel =
        titleOverride ?? AppStrings.segmentTypeLabel(actionType.name);

    AppBottomSheet.show<void>(
      context: context,
      builder: (sheetContext) => _QuickActionDurationSheet(
        actionLabel: actionLabel,
        position: position,
        onSave: (startMs, endMs) {
          Navigator.pop(sheetContext);
          onSave(startMs, endMs);
        },
      ),
    );
  }
}

class PlayerVeilFloatingButton extends StatelessWidget {
  const PlayerVeilFloatingButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.72),
      elevation: 2,
      shadowColor: Colors.black38,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add,
                size: 16,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              const SizedBox(width: 3),
              Text(
                AppStrings.playerVeilQuickAction,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionDurationSheet extends StatefulWidget {
  const _QuickActionDurationSheet({
    required this.actionLabel,
    required this.position,
    required this.onSave,
  });

  final String actionLabel;
  final Duration position;
  final void Function(int startMs, int endMs) onSave;

  @override
  State<_QuickActionDurationSheet> createState() =>
      _QuickActionDurationSheetState();
}

class _QuickActionDurationSheetState extends State<_QuickActionDurationSheet> {
  static const int _defaultDurationSeconds = 5;

  late int _startMs;
  late int _endMs;
  int? _selectedSeconds = _defaultDurationSeconds;
  bool _timingExpanded = false;
  final _customController = TextEditingController();
  late final TextEditingController _startController;
  late final TextEditingController _endController;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startMs = widget.position.inMilliseconds;
    _endMs = _startMs + (_defaultDurationSeconds * 1000);
    _startController = TextEditingController(
      text: VeilTimeInput.formatMs(_startMs),
    );
    _endController = TextEditingController(
      text: VeilTimeInput.formatMs(_endMs),
    );
  }

  @override
  void dispose() {
    _customController.dispose();
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  void _applyDurationSeconds(int seconds) {
    setState(() {
      _selectedSeconds = seconds;
      _endMs = _startMs + (seconds * 1000);
      _endController.text = VeilTimeInput.formatMs(_endMs);
      _errorMessage = null;
    });
  }

  void _save() {
    int startMs = _startMs;
    int endMs = _endMs;

    if (_timingExpanded) {
      final parsedStart = VeilTimeInput.tryParseMs(_startController.text);
      final parsedEnd = VeilTimeInput.tryParseMs(_endController.text);
      if (parsedStart == null || parsedEnd == null) {
        setState(
          () => _errorMessage = AppStrings.segmentEditorInvalidTimeFormat,
        );
        return;
      }
      startMs = parsedStart;
      endMs = parsedEnd;
    } else {
      final seconds =
          _selectedSeconds ?? int.tryParse(_customController.text.trim());
      if (seconds == null || seconds <= 0) {
        showAppSnackBar(
          context,
          AppStrings.playerQuickInvalidDuration,
          abovePlayerControls: true,
        );
        return;
      }
      endMs = startMs + (seconds * 1000);
    }

    if (!VeilTimeInput.isValidRange(startMs, endMs)) {
      setState(() => _errorMessage = AppStrings.segmentEditorInvalidTiming);
      return;
    }

    widget.onSave(startMs, endMs);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.actionLabel, style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          _TimingLine(
            label: AppStrings.startTimeLabel,
            value: VeilTimeInput.formatMs(_startMs),
          ),
          const SizedBox(height: 4),
          _TimingLine(
            label: AppStrings.endTimeLabel,
            value: VeilTimeInput.formatMs(_endMs),
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.playerQuickDuration,
            style: theme.textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _DurationChip(
                label: AppStrings.playerQuickDuration3s,
                selected: _selectedSeconds == 3,
                onTap: () => _applyDurationSeconds(3),
              ),
              _DurationChip(
                label: AppStrings.playerQuickDuration5s,
                selected: _selectedSeconds == 5,
                onTap: () => _applyDurationSeconds(5),
              ),
              _DurationChip(
                label: AppStrings.playerQuickDuration10s,
                selected: _selectedSeconds == 10,
                onTap: () => _applyDurationSeconds(10),
              ),
              _DurationChip(
                label: AppStrings.playerQuickDurationCustom,
                selected: _selectedSeconds == null,
                onTap: () => setState(() => _selectedSeconds = null),
              ),
            ],
          ),
          if (_selectedSeconds == null) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _customController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: AppStrings.playerQuickCustomSecondsHint,
                isDense: true,
              ),
              onChanged: (value) {
                final seconds = int.tryParse(value.trim());
                setState(() {
                  if (seconds != null && seconds > 0) {
                    _endMs = _startMs + (seconds * 1000);
                    _endController.text = VeilTimeInput.formatMs(_endMs);
                  }
                });
              },
            ),
          ],
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => setState(() => _timingExpanded = !_timingExpanded),
            icon: Icon(
              _timingExpanded ? Icons.expand_less : Icons.expand_more,
              size: 18,
            ),
            label: Text(AppStrings.adjustTiming),
          ),
          if (_timingExpanded) ...[
            const SizedBox(height: 4),
            TextField(
              controller: _startController,
              decoration: InputDecoration(
                labelText: AppStrings.startTimeLabel,
                hintText: AppStrings.segmentTimeHint,
                isDense: true,
              ),
              onChanged: (value) {
                final parsed = VeilTimeInput.tryParseMs(value);
                if (parsed != null) {
                  setState(() {
                    _startMs = parsed;
                    _errorMessage = null;
                  });
                }
              },
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _endController,
              decoration: InputDecoration(
                labelText: AppStrings.endTimeLabel,
                hintText: AppStrings.segmentTimeHint,
                isDense: true,
              ),
              onChanged: (value) {
                final parsed = VeilTimeInput.tryParseMs(value);
                if (parsed != null) {
                  setState(() {
                    _endMs = parsed;
                    _errorMessage = null;
                  });
                }
              },
            ),
          ],
          if (_errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppStrings.cancel),
              ),
              const SizedBox(width: 8),
              FilledButton(onPressed: _save, child: Text(AppStrings.save)),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimingLine extends StatelessWidget {
  const _TimingLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 88,
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(value, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _DurationChip extends StatelessWidget {
  const _DurationChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}

class _QuickBookmarkSheet extends StatefulWidget {
  const _QuickBookmarkSheet({
    required this.position,
    required this.onSave,
  });

  final Duration position;
  final void Function(String title, String? note) onSave;

  @override
  State<_QuickBookmarkSheet> createState() => _QuickBookmarkSheetState();
}

class _QuickBookmarkSheetState extends State<_QuickBookmarkSheet> {
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _errorMessage = AppStrings.bookmarkTitleRequired);
      return;
    }
    widget.onSave(title, _noteController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppStrings.playerQuickAddBookmark,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          _TimingLine(
            label: AppStrings.playerQuickActionAt,
            value: VeilTimeInput.formatMs(widget.position.inMilliseconds),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: AppStrings.bookmarkTitle,
              isDense: true,
            ),
            textInputAction: TextInputAction.next,
            autofocus: true,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteController,
            decoration: InputDecoration(
              labelText: AppStrings.bookmarkNote,
              isDense: true,
            ),
            minLines: 1,
            maxLines: 3,
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppStrings.cancel),
              ),
              const SizedBox(width: 8),
              FilledButton(onPressed: _save, child: Text(AppStrings.save)),
            ],
          ),
        ],
      ),
    );
  }
}
