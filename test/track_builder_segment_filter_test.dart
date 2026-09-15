import 'package:flutter_test/flutter_test.dart';
import 'package:veil_mobile/core/veil/veil_segment.dart';
import 'package:veil_mobile/core/veil/veil_segment_type.dart';
import 'package:veil_mobile/features/track_builder/presentation/track_builder_segment_filter.dart';

VeilSegment _segment({
  required String id,
  required VeilSegmentType type,
  String? label,
  String? notes,
}) {
  return VeilSegment(
    id: id,
    type: type,
    startMs: 1000,
    endMs: 2000,
    label: label,
    notes: notes,
  );
}

void main() {
  final segments = [
    _segment(id: '1', type: VeilSegmentType.mask, label: 'Face cover'),
    _segment(id: '2', type: VeilSegmentType.mute, notes: 'loud scene'),
    _segment(id: '3', type: VeilSegmentType.skip, label: 'intro'),
  ];

  String typeLabel(VeilSegmentType type) => type.name;

  group('filterBuilderSegments', () {
    test('returns all segments when filter is all and search is empty', () {
      final result = filterBuilderSegments(
        segments: segments,
        filter: SegmentListFilter.all,
        searchQuery: '',
        typeLabel: typeLabel,
      );

      expect(result, hasLength(3));
    });

    test('filters bookmark chip', () {
      final bookmarks = filterBuilderSegments(
        segments: [
          ...segments,
          VeilSegment.bookmark(positionMs: 1000, title: 'Note'),
        ],
        filter: SegmentListFilter.bookmark,
        searchQuery: '',
        typeLabel: typeLabel,
      );

      expect(bookmarks, hasLength(1));
      expect(bookmarks.first.type, VeilSegmentType.bookmark);
    });

    test('filters mask chip', () {
      final masks = filterBuilderSegments(
        segments: segments,
        filter: SegmentListFilter.mask,
        searchQuery: '',
        typeLabel: typeLabel,
      );

      expect(masks, hasLength(1));
      expect(masks.first.type, VeilSegmentType.mask);
    });

    test('filters by search query on label', () {
      final result = filterBuilderSegments(
        segments: segments,
        filter: SegmentListFilter.all,
        searchQuery: 'face',
        typeLabel: typeLabel,
      );

      expect(result, hasLength(1));
      expect(result.first.id, '1');
    });

    test('filters by search query on notes', () {
      final result = filterBuilderSegments(
        segments: segments,
        filter: SegmentListFilter.all,
        searchQuery: 'loud',
        typeLabel: typeLabel,
      );

      expect(result, hasLength(1));
      expect(result.first.id, '2');
    });

    test('combines type filter and search', () {
      final result = filterBuilderSegments(
        segments: segments,
        filter: SegmentListFilter.skip,
        searchQuery: 'intro',
        typeLabel: typeLabel,
      );

      expect(result, hasLength(1));
      expect(result.first.id, '3');
    });

    test('returns empty when search has no matches', () {
      final result = filterBuilderSegments(
        segments: segments,
        filter: SegmentListFilter.all,
        searchQuery: 'missing',
        typeLabel: typeLabel,
      );

      expect(result, isEmpty);
    });
  });
}
