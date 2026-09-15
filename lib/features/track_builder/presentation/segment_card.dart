import 'package:flutter/material.dart';
import 'package:veil_mobile/core/veil/veil_segment.dart';
import 'package:veil_mobile/core/veil/veil_segment_type.dart';
import 'package:veil_mobile/features/track_builder/presentation/segment_type_style.dart';
import 'package:veil_mobile/shared/constants/app_strings.dart';
import 'package:veil_mobile/shared/utils/veil_time_input.dart';

class SegmentCard extends StatelessWidget {
  const SegmentCard({
    super.key,
    required this.segment,
    required this.onEdit,
    required this.onDelete,
    this.onTap,
    this.reorderHandle,
  });

  final VeilSegment segment;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onTap;
  final Widget? reorderHandle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accent = SegmentTypeStyle.accentFor(segment.type, colorScheme);
    final background = SegmentTypeStyle.backgroundFor(segment.type, colorScheme);
    final typeLabel = AppStrings.segmentTypeLabel(segment.type.name);
    final isBookmark = segment.type == VeilSegmentType.bookmark;
    final timeRange = isBookmark
        ? VeilTimeInput.formatMs(segment.startMs)
        : '${VeilTimeInput.formatMsShort(segment.startMs)} → '
              '${VeilTimeInput.formatMsShort(segment.endMs)}';
    final duration = isBookmark
        ? null
        : VeilTimeInput.formatDurationMs(segment.startMs, segment.endMs);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: accent.withValues(alpha: 0.25)),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(4, 4, 4, 4),
        child: Row(
          children: [
            ?reorderHandle,
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 4, 8),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: background,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            SegmentTypeStyle.iconFor(segment.type),
                            size: 20,
                            color: accent,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    typeLabel,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      color: accent,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (!segment.enabled) ...[
                                    const SizedBox(width: 6),
                                    Text(
                                      AppStrings.segmentDisabled,
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                timeRange,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                              if (segment.label?.isNotEmpty == true ||
                                  segment.notes?.isNotEmpty == true) ...[
                                const SizedBox(height: 2),
                                Text(
                                  segment.label?.isNotEmpty == true
                                      ? segment.label!
                                      : segment.notes!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (duration != null)
                          Text(
                            duration,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined, size: 20),
              tooltip: AppStrings.segmentEdit,
              visualDensity: VisualDensity.compact,
            ),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline, size: 20),
              tooltip: AppStrings.segmentDelete,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}
