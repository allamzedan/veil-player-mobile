import 'package:uuid/uuid.dart';
import 'package:veil_mobile/core/veil/veil_segment.dart';

/// A VEIL track document with metadata and segments.
class VeilTrack {
  const VeilTrack({
    required this.id,
    required this.title,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.segments,
    this.app,
    this.appVersion,
    this.exportedAt,
    this.videoName,
    this.videoDurationSeconds,
    this.videoFileSize,
    this.videoWidth,
    this.videoHeight,
    this.globalOffsetSeconds,
    this.subtitleCover,
    this.video,
    this.trackMetadata,
    this.rawExtra,
  });

  /// Legacy mobile storage format version.
  static const String mobileFormatVersion = '0.1.0';

  /// Desktop VEIL document version used for export.
  static const String desktopFormatVersion = '1.6.0';
  static const Set<String> supportedDesktopFormatVersions = {
    '1.0.0',
    '1.1.0',
    '1.2.0',
    '1.3.0',
    '1.4.0',
    '1.5.0',
    '1.6.0',
  };

  static const String defaultUntitledTitle = 'Untitled VEIL Track';

  final String id;
  final String title;
  final String version;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<VeilSegment> segments;
  final String? app;
  final String? appVersion;
  final DateTime? exportedAt;
  final String? videoName;
  final double? videoDurationSeconds;
  final num? videoFileSize;
  final num? videoWidth;
  final num? videoHeight;
  final double? globalOffsetSeconds;
  final Map<String, dynamic>? subtitleCover;
  final Map<String, dynamic>? video;
  final Map<String, dynamic>? trackMetadata;
  final Map<String, dynamic>? rawExtra;

  factory VeilTrack.empty({String title = ''}) {
    final now = DateTime.now().toUtc();
    return VeilTrack(
      id: const Uuid().v4(),
      title: title,
      version: desktopFormatVersion,
      createdAt: now,
      updatedAt: now,
      segments: const [],
      app: 'VEIL',
      appVersion: 'VEIL Mobile 0.2.3',
      globalOffsetSeconds: 0,
    );
  }

  factory VeilTrack.fromMobileJson(Map<String, dynamic> json) {
    final segmentsJson = json['segments'] as List<dynamic>? ?? [];
    return VeilTrack(
      id: json['id'] as String? ?? const Uuid().v4(),
      title: json['title'] as String? ?? '',
      version: json['version'] as String? ?? mobileFormatVersion,
      createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now().toUtc(),
      updatedAt:
          _parseDateTime(json['updatedAt']) ??
          _parseDateTime(json['createdAt']) ??
          DateTime.now().toUtc(),
      segments: _segmentsFromMobileJson(segmentsJson),
      app: json['app'] as String?,
      appVersion: json['appVersion'] as String?,
      exportedAt: _parseDateTime(json['exportedAt']),
      videoName: json['videoName'] as String?,
      videoDurationSeconds: (json['videoDurationSeconds'] as num?)?.toDouble(),
      videoFileSize: json['videoFileSize'] as num?,
      videoWidth: json['videoWidth'] as num?,
      videoHeight: json['videoHeight'] as num?,
      globalOffsetSeconds: (json['globalOffsetSeconds'] as num?)?.toDouble(),
      subtitleCover: _cloneMap(json['subtitleCover']),
      video: _cloneMap(json['video']),
      trackMetadata: _cloneMap(json['trackMetadata']),
      rawExtra: _cloneMap(json['rawExtra']),
    );
  }

  Map<String, dynamic> toMobileJson() {
    return {
      'id': id,
      'title': title,
      'version': version,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt.toUtc().toIso8601String(),
      'segments': segments.map((s) => s.toJson()).toList(),
      if (app != null) 'app': app,
      if (appVersion != null) 'appVersion': appVersion,
      if (exportedAt != null)
        'exportedAt': exportedAt!.toUtc().toIso8601String(),
      if (videoName != null) 'videoName': videoName,
      if (videoDurationSeconds != null)
        'videoDurationSeconds': videoDurationSeconds,
      if (videoFileSize != null) 'videoFileSize': videoFileSize,
      if (videoWidth != null) 'videoWidth': videoWidth,
      if (videoHeight != null) 'videoHeight': videoHeight,
      if (globalOffsetSeconds != null)
        'globalOffsetSeconds': globalOffsetSeconds,
      if (subtitleCover != null)
        'subtitleCover': Map<String, dynamic>.from(subtitleCover!),
      if (video != null) 'video': Map<String, dynamic>.from(video!),
      if (trackMetadata != null)
        'trackMetadata': Map<String, dynamic>.from(trackMetadata!),
      if (rawExtra != null && rawExtra!.isNotEmpty)
        'rawExtra': Map<String, dynamic>.from(rawExtra!),
    };
  }

  VeilTrack copyWith({
    String? id,
    String? title,
    String? version,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<VeilSegment>? segments,
    String? app,
    String? appVersion,
    DateTime? exportedAt,
    String? videoName,
    double? videoDurationSeconds,
    num? videoFileSize,
    num? videoWidth,
    num? videoHeight,
    double? globalOffsetSeconds,
    Map<String, dynamic>? subtitleCover,
    Map<String, dynamic>? video,
    Map<String, dynamic>? trackMetadata,
    Map<String, dynamic>? rawExtra,
  }) {
    return VeilTrack(
      id: id ?? this.id,
      title: title ?? this.title,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      segments: segments ?? this.segments,
      app: app ?? this.app,
      appVersion: appVersion ?? this.appVersion,
      exportedAt: exportedAt ?? this.exportedAt,
      videoName: videoName ?? this.videoName,
      videoDurationSeconds: videoDurationSeconds ?? this.videoDurationSeconds,
      videoFileSize: videoFileSize ?? this.videoFileSize,
      videoWidth: videoWidth ?? this.videoWidth,
      videoHeight: videoHeight ?? this.videoHeight,
      globalOffsetSeconds: globalOffsetSeconds ?? this.globalOffsetSeconds,
      subtitleCover: subtitleCover ?? this.subtitleCover,
      video: video ?? this.video,
      trackMetadata: trackMetadata ?? this.trackMetadata,
      rawExtra: rawExtra ?? this.rawExtra,
    );
  }

  static List<VeilSegment> _segmentsFromMobileJson(List<dynamic> segmentsJson) {
    final segments = <VeilSegment>[];
    for (final entry in segmentsJson) {
      if (entry is! Map<String, dynamic>) {
        continue;
      }
      try {
        segments.add(VeilSegment.fromJson(entry));
      } on Object {
        // Skip malformed mobile segments instead of failing the whole import.
      }
    }
    return segments;
  }

  VeilTrack touchUpdated() {
    return copyWith(updatedAt: DateTime.now().toUtc());
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value is! String || value.isEmpty) {
      return null;
    }
    return DateTime.parse(value);
  }

  static Map<String, dynamic>? _cloneMap(dynamic value) {
    if (value is! Map) {
      return null;
    }
    return Map<String, dynamic>.from(value);
  }
}
