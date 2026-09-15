import 'package:uuid/uuid.dart';
import 'package:veil_mobile/core/veil/veil_segment_type.dart';

/// A timed region or point within a VEIL track.
class VeilSegment {
  const VeilSegment({
    required this.id,
    required this.type,
    required this.startMs,
    required this.endMs,
    this.label,
    this.notes,
    this.enabled = true,
    this.rect,
    this.style,
    this.source,
    this.rawExtra,
  });

  static const Map<String, dynamic> defaultRect = {
    'xPercent': 10,
    'yPercent': 78,
    'widthPercent': 80,
    'heightPercent': 18,
  };

  static const Map<String, dynamic> defaultStyle = {
    'mode': 'solid',
    'color': '#000000',
    'opacity': 1,
  };

  static const Map<String, dynamic> defaultSource = {'kind': 'manual-mobile'};

  final String id;
  final VeilSegmentType type;
  final int startMs;
  final int endMs;
  final String? label;
  final String? notes;
  final bool enabled;
  final Map<String, dynamic>? rect;
  final Map<String, dynamic>? style;
  final Map<String, dynamic>? source;
  final Map<String, dynamic>? rawExtra;

  bool get hasValidTiming {
    if (startMs < 0 || endMs < 0) {
      return false;
    }
    if (type == VeilSegmentType.marker || type == VeilSegmentType.bookmark) {
      return endMs >= startMs;
    }
    return endMs > startMs;
  }

  bool get isInformationalOnly =>
      type == VeilSegmentType.marker || type == VeilSegmentType.bookmark;

  /// Bookmark/marker position in milliseconds (uses [startMs]).
  int get pointMs => startMs;

  /// Creates a non-destructive bookmark at a single playback point.
  factory VeilSegment.bookmark({
    required int positionMs,
    required String title,
    String? note,
    String? id,
    bool enabled = true,
  }) {
    final trimmedTitle = title.trim();
    final trimmedNote = note?.trim();
    return VeilSegment(
      id: id ?? const Uuid().v4(),
      type: VeilSegmentType.bookmark,
      startMs: positionMs,
      endMs: positionMs,
      label: trimmedTitle.isEmpty ? null : trimmedTitle,
      notes: trimmedNote == null || trimmedNote.isEmpty ? null : trimmedNote,
      enabled: enabled,
      source: Map<String, dynamic>.from(defaultSource),
    );
  }

  /// Quick-action segment from the player (+ VEIL menu).
  factory VeilSegment.quickAction({
    required VeilSegmentType type,
    required int startMs,
    required int endMs,
    String? id,
    Map<String, dynamic>? maskRect,
  }) {
    final segmentId = id ?? const Uuid().v4();
    final isMask = type == VeilSegmentType.mask;
    return VeilSegment(
      id: segmentId,
      type: type,
      startMs: startMs,
      endMs: endMs,
      enabled: true,
      rect: isMask ? Map<String, dynamic>.from(maskRect ?? defaultRect) : null,
      style: isMask ? Map<String, dynamic>.from(defaultStyle) : null,
      source: Map<String, dynamic>.from(defaultSource),
    );
  }

  /// Creates a mobile segment with desktop-compatible defaults.
  factory VeilSegment.mobileDefault({
    String? id,
    VeilSegmentType type = VeilSegmentType.mask,
    int startMs = 0,
    int endMs = 1000,
    String? label,
    String? notes,
    bool enabled = true,
  }) {
    final isMask = type == VeilSegmentType.mask;
    return VeilSegment(
      id: id ?? const Uuid().v4(),
      type: type,
      startMs: startMs,
      endMs: endMs,
      label: label,
      notes: notes,
      enabled: enabled,
      rect: isMask ? Map<String, dynamic>.from(defaultRect) : null,
      style: isMask ? Map<String, dynamic>.from(defaultStyle) : null,
      source: Map<String, dynamic>.from(defaultSource),
    );
  }

  factory VeilSegment.fromJson(Map<String, dynamic> json) {
    final typeRaw = json['type'];
    if (typeRaw is! String) {
      throw const FormatException('Segment type must be a string.');
    }

    return VeilSegment(
      id: json['id'] as String? ?? const Uuid().v4(),
      type: VeilSegmentType.fromJson(typeRaw),
      startMs: _readMs(json['startMs'], 0),
      endMs: _readMs(json['endMs'], _readMs(json['startMs'], 0)),
      label: json['label'] as String?,
      notes: json['notes'] as String?,
      enabled: json['enabled'] as bool? ?? true,
      rect: _cloneMap(json['rect']),
      style: _cloneMap(json['style']),
      source: _cloneMap(json['source']),
      rawExtra: _cloneMap(json['rawExtra']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toJson(),
      'startMs': startMs,
      'endMs': endMs,
      'enabled': enabled,
      if (label != null && label!.isNotEmpty) 'label': label,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
      if (rect != null) 'rect': Map<String, dynamic>.from(rect!),
      if (style != null) 'style': Map<String, dynamic>.from(style!),
      if (source != null) 'source': Map<String, dynamic>.from(source!),
      if (rawExtra != null && rawExtra!.isNotEmpty)
        'rawExtra': Map<String, dynamic>.from(rawExtra!),
    };
  }

  VeilSegment copyWith({
    String? id,
    VeilSegmentType? type,
    int? startMs,
    int? endMs,
    String? label,
    String? notes,
    bool? enabled,
    Map<String, dynamic>? rect,
    Map<String, dynamic>? style,
    Map<String, dynamic>? source,
    Map<String, dynamic>? rawExtra,
    bool clearLabel = false,
    bool clearNotes = false,
  }) {
    return VeilSegment(
      id: id ?? this.id,
      type: type ?? this.type,
      startMs: startMs ?? this.startMs,
      endMs: endMs ?? this.endMs,
      label: clearLabel ? null : (label ?? this.label),
      notes: clearNotes ? null : (notes ?? this.notes),
      enabled: enabled ?? this.enabled,
      rect: rect ?? this.rect,
      style: style ?? this.style,
      source: source ?? this.source,
      rawExtra: rawExtra ?? this.rawExtra,
    );
  }

  static Map<String, dynamic>? _cloneMap(dynamic value) {
    if (value is! Map) {
      return null;
    }
    return Map<String, dynamic>.from(value);
  }

  static int _readMs(dynamic value, int fallback) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.round();
    }
    return fallback;
  }
}
