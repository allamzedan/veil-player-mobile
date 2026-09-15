import 'package:flutter/material.dart';
import 'package:veil_mobile/features/track_builder/presentation/track_builder_segment_filter.dart';
import 'package:veil_mobile/shared/constants/app_strings.dart';

class TrackBuilderSegmentToolbar extends StatelessWidget {
  const TrackBuilderSegmentToolbar({
    super.key,
    required this.searchController,
    required this.filter,
    required this.onFilterChanged,
  });

  final TextEditingController searchController;
  final SegmentListFilter filter;
  final ValueChanged<SegmentListFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: AppStrings.trackBuilderSegmentSearchHint,
            prefixIcon: const Icon(Icons.search, size: 20),
            isDense: true,
          ),
          textInputAction: TextInputAction.search,
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _FilterChip(
                label: AppStrings.trackBuilderFilterAll,
                selected: filter == SegmentListFilter.all,
                onTap: () => onFilterChanged(SegmentListFilter.all),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: AppStrings.trackBuilderFilterMasks,
                selected: filter == SegmentListFilter.mask,
                onTap: () => onFilterChanged(SegmentListFilter.mask),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: AppStrings.trackBuilderFilterMutes,
                selected: filter == SegmentListFilter.mute,
                onTap: () => onFilterChanged(SegmentListFilter.mute),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: AppStrings.trackBuilderFilterSkips,
                selected: filter == SegmentListFilter.skip,
                onTap: () => onFilterChanged(SegmentListFilter.skip),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: AppStrings.trackBuilderFilterBookmarks,
                selected: filter == SegmentListFilter.bookmark,
                onTap: () => onFilterChanged(SegmentListFilter.bookmark),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
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
      showCheckmark: false,
      visualDensity: VisualDensity.compact,
    );
  }
}
