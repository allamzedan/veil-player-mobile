import 'package:flutter/material.dart';
import 'package:veil_mobile/core/veil/veil_segment.dart';
import 'package:veil_mobile/core/veil/veil_segment_type.dart';
import 'package:veil_mobile/features/player/presentation/mask_placement_screen.dart';
import 'package:veil_mobile/shared/constants/app_strings.dart';
import 'package:veil_mobile/shared/utils/veil_duration_format.dart';
import 'package:veil_mobile/shared/widgets/app_bottom_sheet.dart';
import 'package:video_player/video_player.dart';

/// Player-focused segment editor (timing + mask placement).
class PlayerSegmentEditorSheet {
  static Future<void> show({
    required BuildContext context,
    required VeilSegment segment,
    required VideoPlayerController? videoController,
    required ValueChanged<VeilSegment> onSave,
  }) {
    if (segment.type == VeilSegmentType.mask) {
      return _showMaskEditor(
        context: context,
        segment: segment,
        videoController: videoController,
        onSave: onSave,
      );
    }

    return _showTimingEditor(
      context: context,
      segment: segment,
      title: AppStrings.segmentEditorTitleEdit,
      onSave: onSave,
    );
  }

  static Future<void> _showTimingEditor({
    required BuildContext context,
    required VeilSegment segment,
    required String title,
    required ValueChanged<VeilSegment> onSave,
  }) {
    return AppBottomSheet.show<void>(
      context: context,
      builder: (sheetContext) => _TimingEditorBody(
        segment: segment,
        title: title,
        onSave: (updated) {
          Navigator.pop(sheetContext);
          onSave(updated);
        },
      ),
    );
  }

  static Future<void> _showMaskEditor({
    required BuildContext context,
    required VeilSegment segment,
    required VideoPlayerController? videoController,
    required ValueChanged<VeilSegment> onSave,
  }) {
    return AppBottomSheet.show<void>(
      context: context,
      builder: (sheetContext) => _MaskEditorBody(
        segment: segment,
        videoController: videoController,
        onSave: (updated) {
          Navigator.pop(sheetContext);
          onSave(updated);
        },
      ),
    );
  }
}

class _TimingEditorBody extends StatefulWidget {
  const _TimingEditorBody({
    required this.segment,
    required this.title,
    required this.onSave,
  });

  final VeilSegment segment;
  final String title;
  final ValueChanged<VeilSegment> onSave;

  @override
  State<_TimingEditorBody> createState() => _TimingEditorBodyState();
}

class _TimingEditorBodyState extends State<_TimingEditorBody> {
  late final TextEditingController _startController;
  late final TextEditingController _endController;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startController = TextEditingController(
      text: '${widget.segment.startMs ~/ 1000}',
    );
    _endController = TextEditingController(
      text: '${widget.segment.endMs ~/ 1000}',
    );
  }

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  void _save() {
    final startSec = int.tryParse(_startController.text.trim());
    final endSec = int.tryParse(_endController.text.trim());
    if (startSec == null || endSec == null || startSec < 0 || endSec < 0) {
      setState(() => _errorMessage = AppStrings.segmentEditorInvalidMs);
      return;
    }

    final updated = widget.segment.copyWith(
      startMs: startSec * 1000,
      endMs: endSec * 1000,
    );
    if (!updated.hasValidTiming) {
      setState(() => _errorMessage = AppStrings.segmentEditorInvalidTiming);
      return;
    }

    widget.onSave(updated);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            AppStrings.segmentTypeLabel(widget.segment.type.name),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _startController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: AppStrings.playerSegmentStartTime,
              isDense: true,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _endController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: AppStrings.playerSegmentEndTime,
              isDense: true,
            ),
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
          const SizedBox(height: 20),
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

class _MaskEditorBody extends StatefulWidget {
  const _MaskEditorBody({
    required this.segment,
    required this.videoController,
    required this.onSave,
  });

  final VeilSegment segment;
  final VideoPlayerController? videoController;
  final ValueChanged<VeilSegment> onSave;

  @override
  State<_MaskEditorBody> createState() => _MaskEditorBodyState();
}

class _MaskEditorBodyState extends State<_MaskEditorBody> {
  late final TextEditingController _startController;
  late final TextEditingController _endController;
  late Map<String, dynamic> _rect;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startController = TextEditingController(
      text: '${widget.segment.startMs ~/ 1000}',
    );
    _endController = TextEditingController(
      text: '${widget.segment.endMs ~/ 1000}',
    );
    _rect = Map<String, dynamic>.from(
      widget.segment.rect ?? VeilSegment.defaultRect,
    );
  }

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  Future<void> _editPosition() async {
    final controller = widget.videoController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    final rect = await MaskPlacementScreen.open(
      context,
      controller,
      initialRect: _rect,
    );
    if (!mounted || rect == null) {
      return;
    }

    setState(() => _rect = rect);
  }

  void _save() {
    final startSec = int.tryParse(_startController.text.trim());
    final endSec = int.tryParse(_endController.text.trim());
    if (startSec == null || endSec == null || startSec < 0 || endSec < 0) {
      setState(() => _errorMessage = AppStrings.segmentEditorInvalidMs);
      return;
    }

    final updated = widget.segment.copyWith(
      startMs: startSec * 1000,
      endMs: endSec * 1000,
      rect: Map<String, dynamic>.from(_rect),
      style: Map<String, dynamic>.from(
        widget.segment.style ?? VeilSegment.defaultStyle,
      ),
      source: Map<String, dynamic>.from(
        widget.segment.source ?? VeilSegment.defaultSource,
      ),
    );
    if (!updated.hasValidTiming) {
      setState(() => _errorMessage = AppStrings.segmentEditorInvalidTiming);
      return;
    }

    widget.onSave(updated);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canEditPosition =
        widget.videoController != null &&
        widget.videoController!.value.isInitialized;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppStrings.playerMaskEditorTitle,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _startController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: AppStrings.playerSegmentStartTime,
              isDense: true,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _endController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: AppStrings.playerSegmentEndTime,
              isDense: true,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: canEditPosition ? _editPosition : null,
            icon: const Icon(Icons.crop_square_outlined),
            label: Text(AppStrings.playerMaskEditPosition),
          ),
          const SizedBox(height: 8),
          Text(
            '${VeilDurationFormat.format(Duration(milliseconds: widget.segment.startMs))} '
            '→ ${VeilDurationFormat.format(Duration(milliseconds: widget.segment.endMs))}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
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
          const SizedBox(height: 20),
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
