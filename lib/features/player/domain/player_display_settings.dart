import 'dart:convert';

/// User playback display preferences (volume + in-app brightness).
class PlayerDisplaySettings {
  const PlayerDisplaySettings({
    this.volume = 1.0,
    this.brightness = 1.0,
  });

  static const String storageKey = 'player_display_settings';

  final double volume;
  final double brightness;

  static double clampLevel(double value) => value.clamp(0.0, 1.0);

  /// Volume sent to [VideoPlayerController] while respecting VEIL mute runtime.
  static double effectiveVolume({
    required double userVolume,
    required bool veilMuteActive,
  }) {
    if (veilMuteActive) {
      return 0.0;
    }
    return clampLevel(userVolume);
  }

  /// Opacity for the in-app brightness dim overlay (0 = none, higher = darker).
  static double brightnessOverlayOpacity(double brightness) {
    return (1.0 - clampLevel(brightness)) * _maxDimOpacity;
  }

  static const double _maxDimOpacity = 0.75;

  PlayerDisplaySettings copyWith({
    double? volume,
    double? brightness,
  }) {
    return PlayerDisplaySettings(
      volume: volume ?? this.volume,
      brightness: brightness ?? this.brightness,
    );
  }

  Map<String, dynamic> toJson() => {
    'volume': volume,
    'brightness': brightness,
  };

  factory PlayerDisplaySettings.fromJson(Map<String, dynamic> json) {
    return PlayerDisplaySettings(
      volume: clampLevel((json['volume'] as num?)?.toDouble() ?? 1.0),
      brightness: clampLevel((json['brightness'] as num?)?.toDouble() ?? 1.0),
    );
  }

  static PlayerDisplaySettings fromStorage(String? raw) {
    if (raw == null || raw.isEmpty) {
      return const PlayerDisplaySettings();
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return PlayerDisplaySettings.fromJson(decoded);
      }
    } on Object {
      // fall through
    }
    return const PlayerDisplaySettings();
  }
}
