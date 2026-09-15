import 'package:veil_mobile/core/veil/veil_segment.dart';
import 'package:veil_mobile/core/veil/veil_segment_type.dart';

/// One-tap segment list filters in Track Builder.
enum SegmentListFilter { all, mask, mute, skip, bookmark }

VeilSegmentType? segmentListFilterType(SegmentListFilter filter) {
  return switch (filter) {
    SegmentListFilter.all => null,
    SegmentListFilter.mask => VeilSegmentType.mask,
    SegmentListFilter.mute => VeilSegmentType.mute,
    SegmentListFilter.skip => VeilSegmentType.skip,
    SegmentListFilter.bookmark => VeilSegmentType.bookmark,
  };
}

/// Filters segments by type chip and search query (type label, label, notes).
List<VeilSegment> filterBuilderSegments({
  required List<VeilSegment> segments,
  required SegmentListFilter filter,
  required String searchQuery,
  required String Function(VeilSegmentType type) typeLabel,
}) {
  final query = searchQuery.trim().toLowerCase();
  final typeFilter = segmentListFilterType(filter);

  return [
    for (final segment in segments)
      if (_matchesType(segment, typeFilter) &&
          _matchesSearch(segment, query, typeLabel))
        segment,
  ];
}

bool _matchesType(VeilSegment segment, VeilSegmentType? typeFilter) {
  if (typeFilter == null) {
    return true;
  }
  return segment.type == typeFilter;
}

bool _matchesSearch(
  VeilSegment segment,
  String query,
  String Function(VeilSegmentType type) typeLabel,
) {
  if (query.isEmpty) {
    return true;
  }

  final haystack = [
    typeLabel(segment.type),
    segment.type.name,
    segment.label ?? '',
    segment.notes ?? '',
  ].join(' ').toLowerCase();

  return haystack.contains(query);
}
