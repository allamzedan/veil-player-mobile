/// Local media history models for recent videos, tracks, and last session.
///
/// Structured for future favorites, collections, and cloud sync.
abstract final class MediaHistoryLimits {
  static const int maxRecentEntries = 20;
}

/// A recently opened video file.
class RecentVideoEntry {
  const RecentVideoEntry({
    required this.filename,
    this.path,
    required this.durationMs,
    required this.lastOpenedAt,
    required this.lastPlaybackPositionMs,
  });

  final String filename;
  final String? path;
  final int durationMs;
  final DateTime lastOpenedAt;
  final int lastPlaybackPositionMs;

  String get dedupeKey => (path != null && path!.isNotEmpty) ? path! : filename;

  RecentVideoEntry copyWith({
    String? filename,
    String? path,
    int? durationMs,
    DateTime? lastOpenedAt,
    int? lastPlaybackPositionMs,
  }) {
    return RecentVideoEntry(
      filename: filename ?? this.filename,
      path: path ?? this.path,
      durationMs: durationMs ?? this.durationMs,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
      lastPlaybackPositionMs:
          lastPlaybackPositionMs ?? this.lastPlaybackPositionMs,
    );
  }

  Map<String, dynamic> toJson() => {
    'filename': filename,
    'path': path,
    'durationMs': durationMs,
    'lastOpenedAt': lastOpenedAt.toUtc().toIso8601String(),
    'lastPlaybackPositionMs': lastPlaybackPositionMs,
  };

  factory RecentVideoEntry.fromJson(Map<String, dynamic> json) {
    return RecentVideoEntry(
      filename: json['filename'] as String? ?? '',
      path: json['path'] as String?,
      durationMs: json['durationMs'] as int? ?? 0,
      lastOpenedAt: DateTime.parse(
        json['lastOpenedAt'] as String? ??
            DateTime.now().toUtc().toIso8601String(),
      ),
      lastPlaybackPositionMs: json['lastPlaybackPositionMs'] as int? ?? 0,
    );
  }
}

/// A recently opened VEIL track file.
class RecentTrackEntry {
  const RecentTrackEntry({
    required this.filename,
    this.path,
    required this.lastOpenedAt,
    required this.segmentCount,
  });

  final String filename;
  final String? path;
  final DateTime lastOpenedAt;
  final int segmentCount;

  String get dedupeKey => (path != null && path!.isNotEmpty) ? path! : filename;

  RecentTrackEntry copyWith({
    String? filename,
    String? path,
    DateTime? lastOpenedAt,
    int? segmentCount,
  }) {
    return RecentTrackEntry(
      filename: filename ?? this.filename,
      path: path ?? this.path,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
      segmentCount: segmentCount ?? this.segmentCount,
    );
  }

  Map<String, dynamic> toJson() => {
    'filename': filename,
    'path': path,
    'lastOpenedAt': lastOpenedAt.toUtc().toIso8601String(),
    'segmentCount': segmentCount,
  };

  factory RecentTrackEntry.fromJson(Map<String, dynamic> json) {
    return RecentTrackEntry(
      filename: json['filename'] as String? ?? '',
      path: json['path'] as String?,
      lastOpenedAt: DateTime.parse(
        json['lastOpenedAt'] as String? ??
            DateTime.now().toUtc().toIso8601String(),
      ),
      segmentCount: json['segmentCount'] as int? ?? 0,
    );
  }
}

/// Snapshot of the most recent playback session.
class LastSessionSnapshot {
  const LastSessionSnapshot({
    this.videoFilename,
    this.videoPath,
    this.videoDurationMs,
    this.trackFilename,
    this.trackPath,
    this.trackJson,
    this.subtitleFilename,
    this.subtitlePath,
    this.subtitlesEnabled = false,
    this.playbackPositionMs = 0,
    this.playbackSpeed = 1.0,
    required this.savedAt,
  });

  final String? videoFilename;
  final String? videoPath;
  final int? videoDurationMs;
  final String? trackFilename;
  final String? trackPath;
  final String? trackJson;
  final String? subtitleFilename;
  final String? subtitlePath;
  final bool subtitlesEnabled;
  final int playbackPositionMs;
  final double playbackSpeed;
  final DateTime savedAt;

  bool get hasVideo =>
      videoFilename != null && videoFilename!.trim().isNotEmpty;

  bool get hasTrack =>
      (trackPath != null && trackPath!.isNotEmpty) ||
      (trackJson != null && trackJson!.isNotEmpty);

  bool get isResumable => hasVideo;

  LastSessionSnapshot copyWith({
    String? videoFilename,
    String? videoPath,
    int? videoDurationMs,
    String? trackFilename,
    String? trackPath,
    String? trackJson,
    String? subtitleFilename,
    String? subtitlePath,
    bool? subtitlesEnabled,
    int? playbackPositionMs,
    double? playbackSpeed,
    DateTime? savedAt,
  }) {
    return LastSessionSnapshot(
      videoFilename: videoFilename ?? this.videoFilename,
      videoPath: videoPath ?? this.videoPath,
      videoDurationMs: videoDurationMs ?? this.videoDurationMs,
      trackFilename: trackFilename ?? this.trackFilename,
      trackPath: trackPath ?? this.trackPath,
      trackJson: trackJson ?? this.trackJson,
      subtitleFilename: subtitleFilename ?? this.subtitleFilename,
      subtitlePath: subtitlePath ?? this.subtitlePath,
      subtitlesEnabled: subtitlesEnabled ?? this.subtitlesEnabled,
      playbackPositionMs: playbackPositionMs ?? this.playbackPositionMs,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      savedAt: savedAt ?? this.savedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'videoFilename': videoFilename,
    'videoPath': videoPath,
    'videoDurationMs': videoDurationMs,
    'trackFilename': trackFilename,
    'trackPath': trackPath,
    'trackJson': trackJson,
    'subtitleFilename': subtitleFilename,
    'subtitlePath': subtitlePath,
    'subtitlesEnabled': subtitlesEnabled,
    'playbackPositionMs': playbackPositionMs,
    'playbackSpeed': playbackSpeed,
    'savedAt': savedAt.toUtc().toIso8601String(),
  };

  factory LastSessionSnapshot.fromJson(Map<String, dynamic> json) {
    return LastSessionSnapshot(
      videoFilename: json['videoFilename'] as String?,
      videoPath: json['videoPath'] as String?,
      videoDurationMs: json['videoDurationMs'] as int?,
      trackFilename: json['trackFilename'] as String?,
      trackPath: json['trackPath'] as String?,
      trackJson: json['trackJson'] as String?,
      subtitleFilename: json['subtitleFilename'] as String?,
      subtitlePath: json['subtitlePath'] as String?,
      subtitlesEnabled: json['subtitlesEnabled'] as bool? ?? false,
      playbackPositionMs: json['playbackPositionMs'] as int? ?? 0,
      playbackSpeed: (json['playbackSpeed'] as num?)?.toDouble() ?? 1.0,
      savedAt: DateTime.parse(
        json['savedAt'] as String? ?? DateTime.now().toUtc().toIso8601String(),
      ),
    );
  }
}
