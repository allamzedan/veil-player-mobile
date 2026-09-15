import 'package:flutter/material.dart';
import 'package:veil_mobile/core/veil/veil_segment_type.dart';
import 'package:veil_mobile/features/track_builder/presentation/segment_type_style.dart';
import 'package:veil_mobile/shared/constants/app_strings.dart';

/// Mask / Mute / Skip / Bookmark quick-add buttons at the top of Track Builder.
class TrackBuilderQuickAddRow extends StatelessWidget {
  const TrackBuilderQuickAddRow({
    super.key,
    required this.onAdd,
  });

  final void Function(VeilSegmentType type) onAdd;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _QuickAddButton(
          type: VeilSegmentType.mask,
          label: AppStrings.trackBuilderQuickAddMask,
          onTap: () => onAdd(VeilSegmentType.mask),
        ),
        _QuickAddButton(
          type: VeilSegmentType.mute,
          label: AppStrings.trackBuilderQuickAddMute,
          onTap: () => onAdd(VeilSegmentType.mute),
        ),
        _QuickAddButton(
          type: VeilSegmentType.skip,
          label: AppStrings.trackBuilderQuickAddSkip,
          onTap: () => onAdd(VeilSegmentType.skip),
        ),
        _QuickAddButton(
          type: VeilSegmentType.bookmark,
          label: AppStrings.trackBuilderQuickAddBookmark,
          onTap: () => onAdd(VeilSegmentType.bookmark),
        ),
      ],
    );
  }
}

class _QuickAddButton extends StatelessWidget {
  const _QuickAddButton({
    required this.type,
    required this.label,
    required this.onTap,
  });

  final VeilSegmentType type;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = SegmentTypeStyle.accentFor(type, scheme);
    final background = SegmentTypeStyle.backgroundFor(type, scheme);

    return SizedBox(
      width: (MediaQuery.sizeOf(context).width - 56) / 2,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, size: 16, color: accent),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
