import 'package:flutter/material.dart';
import 'package:veil_mobile/core/veil/veil_segment_type.dart';
import 'package:veil_mobile/features/track_builder/presentation/track_builder_quick_add_row.dart';
import 'package:veil_mobile/shared/constants/app_strings.dart';

/// Empty segment list with quick-add shortcuts.
class TrackBuilderEmptySegments extends StatelessWidget {
  const TrackBuilderEmptySegments({
    super.key,
    required this.onAdd,
  });

  final void Function(VeilSegmentType type) onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Icon(
            Icons.layers_outlined,
            size: 40,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 12),
          Text(
            AppStrings.trackBuilderNoActionsYet,
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          TrackBuilderQuickAddRow(onAdd: onAdd),
        ],
      ),
    );
  }
}
