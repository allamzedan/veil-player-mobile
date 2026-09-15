import 'dart:convert';

/// User-facing subtitle appearance and timing preferences.
enum SubtitleFontSize { small, medium, large }

enum SubtitlePosition { bottom, middle, top }

class SubtitleSettings {
  const SubtitleSettings({
    this.fontSize = SubtitleFontSize.medium,
    this.position = SubtitlePosition.bottom,
    this.backgroundEnabled = true,
    this.backgroundOpacity = 0.58,
    this.delayMs = 0,
  });

  static const storageKey = 'subtitle_settings_v1';
  static const SubtitleSettings defaults = SubtitleSettings();

  final SubtitleFontSize fontSize;
  final SubtitlePosition position;
  final bool backgroundEnabled;
  final double backgroundOpacity;
  final int delayMs;

  double get fontSizePx => switch (fontSize) {
    SubtitleFontSize.small => 13,
    SubtitleFontSize.medium => 16,
    SubtitleFontSize.large => 20,
  };

  /// Playback position used when looking up subtitle cues.
  int effectivePositionMs(int videoPositionMs) => videoPositionMs + delayMs;

  String formatDelayLabel() {
    if (delayMs == 0) {
      return '0ms';
    }
    if (delayMs > 0) {
      return '+${delayMs}ms';
    }
    return '${delayMs}ms';
  }

  SubtitleSettings copyWith({
    SubtitleFontSize? fontSize,
    SubtitlePosition? position,
    bool? backgroundEnabled,
    double? backgroundOpacity,
    int? delayMs,
  }) {
    return SubtitleSettings(
      fontSize: fontSize ?? this.fontSize,
      position: position ?? this.position,
      backgroundEnabled: backgroundEnabled ?? this.backgroundEnabled,
      backgroundOpacity: backgroundOpacity ?? this.backgroundOpacity,
      delayMs: delayMs ?? this.delayMs,
    );
  }

  Map<String, dynamic> toJson() => {
    'fontSize': fontSize.name,
    'position': position.name,
    'backgroundEnabled': backgroundEnabled,
    'backgroundOpacity': backgroundOpacity,
    'delayMs': delayMs,
  };

  factory SubtitleSettings.fromJson(Map<String, dynamic> json) {
    return SubtitleSettings(
      fontSize: _enumByName(
        SubtitleFontSize.values,
        json['fontSize'] as String?,
        SubtitleFontSize.medium,
      ),
      position: _enumByName(
        SubtitlePosition.values,
        json['position'] as String?,
        SubtitlePosition.bottom,
      ),
      backgroundEnabled: json['backgroundEnabled'] as bool? ?? true,
      backgroundOpacity: _clampOpacity(
        (json['backgroundOpacity'] as num?)?.toDouble() ?? 0.58,
      ),
      delayMs: (json['delayMs'] as num?)?.round() ?? 0,
    );
  }

  static SubtitleSettings fromStorage(String? raw) {
    if (raw == null || raw.isEmpty) {
      return defaults;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return defaults;
      }
      return SubtitleSettings.fromJson(decoded);
    } on Object {
      return defaults;
    }
  }

  static T _enumByName<T extends Enum>(
    List<T> values,
    String? name,
    T fallback,
  ) {
    if (name == null) {
      return fallback;
    }
    for (final value in values) {
      if (value.name == name) {
        return value;
      }
    }
    return fallback;
  }

  static double _clampOpacity(double value) => value.clamp(0.0, 1.0);
}
