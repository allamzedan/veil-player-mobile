/// Types of segments in a VEIL track.
enum VeilSegmentType {
  mask,
  mute,
  skip,
  marker,
  bookmark;

  String toJson() => name;

  static VeilSegmentType fromJson(String value) {
    for (final type in VeilSegmentType.values) {
      if (type.name == value) {
        return type;
      }
    }
    throw FormatException('Unknown segment type: $value');
  }

  /// Localization-ready key suffix for segment type labels.
  String get labelKey => 'segmentType_$name';
}
