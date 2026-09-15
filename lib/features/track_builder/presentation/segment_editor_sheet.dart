import 'package:flutter/material.dart';
import 'package:veil_mobile/core/veil/veil_segment.dart';
import 'package:veil_mobile/core/veil/veil_segment_type.dart';
import 'package:veil_mobile/shared/constants/app_strings.dart';
import 'package:veil_mobile/shared/utils/veil_time_input.dart';
import 'package:veil_mobile/shared/widgets/app_bottom_sheet.dart';

/// Bottom sheet for creating or editing a segment.
class SegmentEditorSheet extends StatefulWidget {
  const SegmentEditorSheet({
    super.key,
    this.segment,
    this.initialType,
    required this.onSave,
  });

  final VeilSegment? segment;
  final VeilSegmentType? initialType;
  final ValueChanged<VeilSegment> onSave;

  static Future<void> show({
    required BuildContext context,
    VeilSegment? segment,
    VeilSegmentType? initialType,
    required ValueChanged<VeilSegment> onSave,
  }) {
    return AppBottomSheet.show<void>(
      context: context,
      builder: (sheetContext) => SegmentEditorSheet(
        segment: segment,
        initialType: initialType,
        onSave: onSave,
      ),
    );
  }

  @override
  State<SegmentEditorSheet> createState() => _SegmentEditorSheetState();
}

class _SegmentEditorSheetState extends State<SegmentEditorSheet> {
  late VeilSegmentType _type;
  late final TextEditingController _startController;
  late final TextEditingController _endController;
  late final TextEditingController _labelController;
  late final TextEditingController _notesController;
  String? _errorMessage;

  bool get _isEditing => widget.segment != null;

  @override
  void initState() {
    super.initState();
    final segment = widget.segment;
    _type = segment?.type ?? widget.initialType ?? VeilSegmentType.mask;
    _startController = TextEditingController(
      text: VeilTimeInput.formatMs(segment?.startMs ?? VeilTimeInput.defaultStartMs),
    );
    _endController = TextEditingController(
      text: VeilTimeInput.formatMs(segment?.endMs ?? VeilTimeInput.defaultEndMs),
    );
    _labelController = TextEditingController(text: segment?.label ?? '');
    _notesController = TextEditingController(text: segment?.notes ?? '');
  }

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    _labelController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    final startMs = VeilTimeInput.tryParseMs(_startController.text);
    final endMs = VeilTimeInput.tryParseMs(_endController.text);

    if (startMs == null || endMs == null) {
      setState(
        () => _errorMessage = AppStrings.segmentEditorInvalidTimeFormat,
      );
      return;
    }

    if (!VeilTimeInput.isValidTimingForType(_type, startMs, endMs)) {
      setState(() => _errorMessage = AppStrings.segmentEditorInvalidTiming);
      return;
    }

    final resolvedEnd =
        _type == VeilSegmentType.bookmark ? startMs : endMs;

    final draft =
        (widget.segment ??
                VeilSegment.mobileDefault(
                  type: _type,
                  startMs: startMs,
                  endMs: resolvedEnd,
                ))
            .copyWith(
              type: _type,
              startMs: startMs,
              endMs: resolvedEnd,
              label: _labelController.text.trim(),
              notes: _notesController.text.trim(),
              clearLabel: _labelController.text.trim().isEmpty,
              clearNotes: _notesController.text.trim().isEmpty,
            );

    if (!draft.hasValidTiming) {
      setState(() => _errorMessage = AppStrings.segmentEditorInvalidTiming);
      return;
    }

    widget.onSave(draft);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBookmark = _type == VeilSegmentType.bookmark;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _isEditing
                  ? AppStrings.segmentEditorTitleEdit
                  : AppStrings.segmentEditorTitleAdd,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<VeilSegmentType>(
              initialValue: _type,
              decoration: InputDecoration(
                labelText: AppStrings.segmentTypeField,
              ),
              items: [
                for (final type in VeilSegmentType.values)
                  DropdownMenuItem(
                    value: type,
                    child: Text(AppStrings.segmentTypeLabel(type.name)),
                  ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _type = value;
                    if (value == VeilSegmentType.bookmark) {
                      final startMs =
                          VeilTimeInput.tryParseMs(_startController.text) ?? 0;
                      _endController.text = VeilTimeInput.formatMs(startMs);
                    }
                  });
                }
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _startController,
              decoration: InputDecoration(
                labelText: isBookmark
                    ? AppStrings.bookmarkTime
                    : AppStrings.segmentStartMs,
                hintText: AppStrings.segmentTimeHint,
              ),
              keyboardType: TextInputType.datetime,
              onChanged: isBookmark
                  ? (value) {
                      final parsed = VeilTimeInput.tryParseMs(value);
                      if (parsed != null) {
                        _endController.text = VeilTimeInput.formatMs(parsed);
                      }
                    }
                  : null,
            ),
            if (!isBookmark) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _endController,
                decoration: InputDecoration(
                  labelText: AppStrings.segmentEndMs,
                  hintText: AppStrings.segmentTimeHint,
                ),
                keyboardType: TextInputType.datetime,
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _labelController,
              decoration: InputDecoration(
                labelText:
                    isBookmark ? AppStrings.bookmarkTitle : AppStrings.segmentLabelField,
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText:
                    isBookmark ? AppStrings.bookmarkNote : AppStrings.segmentNotesField,
              ),
              minLines: 2,
              maxLines: 4,
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(AppStrings.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _save,
                    child: Text(AppStrings.save),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
