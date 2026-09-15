import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veil_mobile/core/veil/veil_segment.dart';
import 'package:veil_mobile/core/veil/veil_segment_type.dart';
import 'package:veil_mobile/features/player/application/player_setup_controller.dart';
import 'package:veil_mobile/shared/constants/app_strings.dart';
import 'package:veil_mobile/shared/utils/veil_duration_format.dart';
import 'package:veil_mobile/shared/utils/veil_time_input.dart';
import 'package:veil_mobile/shared/widgets/app_bottom_sheet.dart';

/// Bottom sheet listing VEIL segments for the active track.
class PlayerTrackSegmentsSheet {
  static Future<void> show({
    required BuildContext context,
    required WidgetRef ref,
    required bool canAddActions,
    required VoidCallback onAddMask,
    required VoidCallback onAddMute,
    required VoidCallback onAddSkip,
    required VoidCallback onAddBookmark,
    required Future<void> Function(VeilSegment segment) onJumpTo,
    required void Function(VeilSegment segment) onEdit,
    required void Function(VeilSegment segment) onDuplicate,
    required Future<void> Function(VeilSegment segment) onDelete,
    required void Function(VeilSegment segment, bool enabled) onToggleEnabled,
  }) {
    return AppBottomSheet.show<void>(
      context: context,
      scrollable: false,
      builder: (sheetContext) => Consumer(
        builder: (context, sheetRef, _) {
          sheetRef.watch(playerSetupControllerProvider);
          final segments = sheetRef
              .read(playerSetupControllerProvider.notifier)
              .sortedSegments;

          return _SegmentsSheetBody(
            segments: segments,
            canAddActions: canAddActions,
            onAddMask: onAddMask,
            onAddMute: onAddMute,
            onAddSkip: onAddSkip,
            onAddBookmark: onAddBookmark,
            onJumpTo: onJumpTo,
            onEdit: onEdit,
            onDuplicate: onDuplicate,
            onDelete: onDelete,
            onToggleEnabled: onToggleEnabled,
          );
        },
      ),
    );
  }
}

class _SegmentsSheetBody extends StatelessWidget {
  const _SegmentsSheetBody({
    required this.segments,
    required this.canAddActions,
    required this.onAddMask,
    required this.onAddMute,
    required this.onAddSkip,
    required this.onAddBookmark,
    required this.onJumpTo,
    required this.onEdit,
    required this.onDuplicate,
    required this.onDelete,
    required this.onToggleEnabled,
  });

  final List<VeilSegment> segments;
  final bool canAddActions;
  final VoidCallback onAddMask;
  final VoidCallback onAddMute;
  final VoidCallback onAddSkip;
  final VoidCallback onAddBookmark;
  final Future<void> Function(VeilSegment segment) onJumpTo;
  final void Function(VeilSegment segment) onEdit;
  final void Function(VeilSegment segment) onDuplicate;
  final Future<void> Function(VeilSegment segment) onDelete;
  final void Function(VeilSegment segment, bool enabled) onToggleEnabled;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom + 16;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.85;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Text(
                AppStrings.playerTrackSegmentsTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Expanded(
              child: segments.isEmpty
                  ? _EmptySegmentsBody(
                      canAddActions: canAddActions,
                      onAddMask: () {
                        Navigator.pop(context);
                        onAddMask();
                      },
                      onAddMute: () {
                        Navigator.pop(context);
                        onAddMute();
                      },
                      onAddSkip: () {
                        Navigator.pop(context);
                        onAddSkip();
                      },
                      onAddBookmark: () {
                        Navigator.pop(context);
                        onAddBookmark();
                      },
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                      itemCount: segments.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final segment = segments[index];
                        return _SegmentRow(
                          segment: segment,
                          onJumpTo: () async {
                            Navigator.pop(context);
                            await onJumpTo(segment);
                          },
                          onEdit: () {
                            Navigator.pop(context);
                            onEdit(segment);
                          },
                          onDuplicate: () {
                            onDuplicate(segment);
                          },
                          onDelete: () async {
                            await onDelete(segment);
                          },
                          onToggleEnabled: (enabled) {
                            onToggleEnabled(segment, enabled);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptySegmentsBody extends StatelessWidget {
  const _EmptySegmentsBody({
    required this.canAddActions,
    required this.onAddMask,
    required this.onAddMute,
    required this.onAddSkip,
    required this.onAddBookmark,
  });

  final bool canAddActions;
  final VoidCallback onAddMask;
  final VoidCallback onAddMute;
  final VoidCallback onAddSkip;
  final VoidCallback onAddBookmark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        children: [
          Icon(
            Icons.layers_outlined,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 12),
          Text(
            AppStrings.playerNoSegmentsYet,
            style: theme.textTheme.titleSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.tonalIcon(
                onPressed: canAddActions ? onAddMask : null,
                icon: const Icon(Icons.crop_square_outlined, size: 18),
                label: Text(AppStrings.playerQuickAddMask),
              ),
              FilledButton.tonalIcon(
                onPressed: canAddActions ? onAddMute : null,
                icon: const Icon(Icons.volume_off_outlined, size: 18),
                label: Text(AppStrings.playerQuickAddMute),
              ),
              FilledButton.tonalIcon(
                onPressed: canAddActions ? onAddSkip : null,
                icon: const Icon(Icons.skip_next_outlined, size: 18),
                label: Text(AppStrings.playerQuickAddSkip),
              ),
              FilledButton.tonalIcon(
                onPressed: canAddActions ? onAddBookmark : null,
                icon: const Icon(Icons.bookmark_outline, size: 18),
                label: Text(AppStrings.playerQuickAddBookmark),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SegmentRow extends StatelessWidget {
  const _SegmentRow({
    required this.segment,
    required this.onJumpTo,
    required this.onEdit,
    required this.onDuplicate,
    required this.onDelete,
    required this.onToggleEnabled,
  });

  final VeilSegment segment;
  final VoidCallback onJumpTo;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
  final Future<void> Function() onDelete;
  final ValueChanged<bool> onToggleEnabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBookmark = segment.type == VeilSegmentType.bookmark;

    return ListTile(
      leading: Icon(
        _iconForType(segment.type),
        color: segment.enabled
            ? (isBookmark
                  ? const Color(0xFF26A69A)
                  : theme.colorScheme.primary)
            : theme.colorScheme.onSurfaceVariant,
      ),
      title: isBookmark
          ? _BookmarkTitle(segment: segment, theme: theme)
          : Text(
              '${AppStrings.segmentTypeLabel(segment.type.name)} • '
              '${VeilDurationFormat.format(Duration(milliseconds: segment.startMs))} '
              '→ ${VeilDurationFormat.format(Duration(milliseconds: segment.endMs))}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: segment.enabled ? null : theme.colorScheme.onSurfaceVariant,
              ),
            ),
      subtitle: isBookmark
          ? null
          : Text(
              segment.enabled
                  ? AppStrings.segmentEnabled
                  : AppStrings.segmentDisabled,
              style: theme.textTheme.labelSmall,
            ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Switch(value: segment.enabled, onChanged: onToggleEnabled),
          PopupMenuButton<_SegmentAction>(
            onSelected: (action) async {
              switch (action) {
                case _SegmentAction.jump:
                  onJumpTo();
                case _SegmentAction.edit:
                  onEdit();
                case _SegmentAction.duplicate:
                  onDuplicate();
                case _SegmentAction.delete:
                  await onDelete();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: _SegmentAction.jump,
                child: Text(AppStrings.playerSegmentJumpTo),
              ),
              PopupMenuItem(
                value: _SegmentAction.edit,
                child: Text(AppStrings.segmentEdit),
              ),
              PopupMenuItem(
                value: _SegmentAction.duplicate,
                child: Text(AppStrings.playerSegmentDuplicate),
              ),
              PopupMenuItem(
                value: _SegmentAction.delete,
                child: Text(AppStrings.segmentDelete),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static IconData _iconForType(VeilSegmentType type) {
    return switch (type) {
      VeilSegmentType.mask => Icons.crop_square_outlined,
      VeilSegmentType.mute => Icons.volume_off_outlined,
      VeilSegmentType.skip => Icons.skip_next_outlined,
      VeilSegmentType.marker => Icons.place_outlined,
      VeilSegmentType.bookmark => Icons.bookmark_outline,
    };
  }
}

class _BookmarkTitle extends StatelessWidget {
  const _BookmarkTitle({required this.segment, required this.theme});

  final VeilSegment segment;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final time = VeilTimeInput.formatMs(segment.pointMs);
    final lines = <Widget>[
      Text(
        AppStrings.segmentTypeBookmark,
        style: theme.textTheme.titleSmall?.copyWith(
          color: segment.enabled ? const Color(0xFF26A69A) : null,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        time,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontFeatures: const [FontFeature.tabularFigures()],
          color: segment.enabled ? null : theme.colorScheme.onSurfaceVariant,
        ),
      ),
    ];

    if (segment.label?.isNotEmpty == true) {
      lines.addAll([
        const SizedBox(height: 4),
        Text(
          segment.label!,
          style: theme.textTheme.bodyMedium,
        ),
      ]);
    }
    if (segment.notes?.isNotEmpty == true) {
      lines.addAll([
        const SizedBox(height: 2),
        Text(
          segment.notes!,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ]);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines,
    );
  }
}

enum _SegmentAction { jump, edit, duplicate, delete }
