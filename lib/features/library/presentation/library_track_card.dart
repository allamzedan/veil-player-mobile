import 'package:flutter/material.dart';
import 'package:veil_mobile/features/library/application/library_controller.dart';
import 'package:veil_mobile/shared/constants/app_strings.dart';
import 'package:veil_mobile/shared/utils/veil_date_format.dart';

class LibraryTrackCard extends StatelessWidget {
  const LibraryTrackCard({
    super.key,
    required this.item,
    this.onEdit,
    this.onDelete,
    this.selectionMode = false,
    this.selected = false,
    this.onSelectionChanged,
  });

  final LibraryTrackItem item;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool selectionMode;
  final bool selected;
  final ValueChanged<bool>? onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final track = item.track;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: selectionMode
            ? () => onSelectionChanged?.call(!selected)
            : null,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 12, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (selectionMode) ...[
                    Checkbox(
                      value: selected,
                      onChanged: (value) =>
                          onSelectionChanged?.call(value ?? false),
                    ),
                    const SizedBox(width: 4),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          track.title.trim().isEmpty
                              ? AppStrings.untitledTrack
                              : track.title,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          AppStrings.savedTrackMeta(
                            segmentCount: track.segments.length,
                            updatedAt: VeilDateFormat.formatDateTime(
                              track.updatedAt,
                            ),
                          ),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    item.isValid
                        ? Icons.check_circle_outline
                        : Icons.warning_amber_outlined,
                    size: 18,
                    color:
                        item.isValid ? colorScheme.primary : colorScheme.error,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    item.isValid
                        ? AppStrings.libraryValidationValid
                        : AppStrings.libraryValidationInvalid,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: item.isValid
                          ? colorScheme.primary
                          : colorScheme.error,
                    ),
                  ),
                ],
              ),
              if (!selectionMode) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (onEdit != null)
                      FilledButton.tonal(
                        onPressed: onEdit,
                        child: Text(AppStrings.libraryEditTrack),
                      ),
                    if (onEdit != null && onDelete != null)
                      const SizedBox(width: 8),
                    if (onDelete != null)
                      OutlinedButton(
                        onPressed: onDelete,
                        child: Text(AppStrings.delete),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
