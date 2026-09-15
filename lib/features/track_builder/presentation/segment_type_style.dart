import 'package:flutter/material.dart';
import 'package:veil_mobile/core/veil/veil_segment_type.dart';

/// Subtle accent colors and icons for segment types in Track Builder.
abstract final class SegmentTypeStyle {
  static IconData iconFor(VeilSegmentType type) {
    return switch (type) {
      VeilSegmentType.mask => Icons.crop_square_outlined,
      VeilSegmentType.mute => Icons.volume_off_outlined,
      VeilSegmentType.skip => Icons.skip_next_outlined,
      VeilSegmentType.marker => Icons.place_outlined,
      VeilSegmentType.bookmark => Icons.bookmark_outline,
    };
  }

  static Color accentFor(VeilSegmentType type, ColorScheme scheme) {
    return switch (type) {
      VeilSegmentType.mask => const Color(0xFF7E57C2),
      VeilSegmentType.mute => const Color(0xFFFFB300),
      VeilSegmentType.skip => const Color(0xFF43A047),
      VeilSegmentType.bookmark => const Color(0xFF26A69A),
      VeilSegmentType.marker => scheme.outline,
    };
  }

  static Color backgroundFor(VeilSegmentType type, ColorScheme scheme) {
    return accentFor(type, scheme).withValues(alpha: 0.12);
  }
}
