import 'dart:convert';

/// User playback preferences (autoplay next video, etc.).
class PlayerPlaybackSettings {
  const PlayerPlaybackSettings({this.autoplayNextVideo = false});

  static const String storageKey = 'player_playback_settings';

  final bool autoplayNextVideo;

  PlayerPlaybackSettings copyWith({bool? autoplayNextVideo}) {
    return PlayerPlaybackSettings(
      autoplayNextVideo: autoplayNextVideo ?? this.autoplayNextVideo,
    );
  }

  Map<String, dynamic> toJson() => {
    'autoplayNextVideo': autoplayNextVideo,
  };

  factory PlayerPlaybackSettings.fromJson(Map<String, dynamic> json) {
    return PlayerPlaybackSettings(
      autoplayNextVideo: json['autoplayNextVideo'] as bool? ?? false,
    );
  }

  static PlayerPlaybackSettings fromStorage(String? raw) {
    if (raw == null || raw.isEmpty) {
      return const PlayerPlaybackSettings();
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return PlayerPlaybackSettings.fromJson(decoded);
      }
    } on Object {
      // fall through
    }
    return const PlayerPlaybackSettings();
  }
}
