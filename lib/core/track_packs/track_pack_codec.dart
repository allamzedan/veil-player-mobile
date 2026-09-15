import 'dart:convert';

import 'package:uuid/uuid.dart';
import 'package:veil_mobile/core/track_packs/track_pack.dart';

/// Encodes and decodes `.veilpack.json` documents.
abstract final class TrackPackCodec {
  static const String formatId = 'veil.pack';
  static const String fileExtension = 'veilpack.json';

  static const _uuid = Uuid();

  static String encode(TrackPack pack) {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(_toJson(pack));
  }

  static TrackPack decode(String source) {
    final dynamic decoded;
    try {
      decoded = jsonDecode(source);
    } on Object {
      throw const FormatException('Invalid JSON.');
    }
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Track pack root must be a JSON object.');
    }
    if (decoded['format'] != formatId) {
      throw const FormatException('Unsupported track pack format.');
    }

    final packJson = decoded['pack'];
    if (packJson is! Map<String, dynamic>) {
      throw const FormatException('Track pack document is missing pack data.');
    }

    return _packFromJson(packJson);
  }

  static TrackPack? tryDecode(String source) {
    try {
      return decode(source);
    } on Object {
      return null;
    }
  }

  static Map<String, dynamic> _toJson(TrackPack pack) {
    return {
      'format': formatId,
      'version': pack.version,
      'pack': {
        'id': pack.id,
        'title': pack.title,
        'description': pack.description,
        'author': pack.author,
        'createdAt': pack.createdAt.toUtc().toIso8601String(),
        'updatedAt': pack.updatedAt.toUtc().toIso8601String(),
        'tags': pack.tags,
        'tracks': [
          for (final track in pack.tracks) _trackToJson(track),
        ],
      },
    };
  }

  static Map<String, dynamic> _trackToJson(TrackPackTrack track) {
    final parsed = jsonDecode(track.trackJson);
    return {
      'trackTitle': track.trackTitle,
      'trackJson': parsed,
    };
  }

  static TrackPack _packFromJson(Map<String, dynamic> json) {
    final tracksJson = json['tracks'] as List<dynamic>? ?? [];
    return TrackPack(
      id: json['id'] as String? ?? _uuid.v4(),
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      version: json['version'] as String? ?? TrackPack.defaultVersion,
      author: json['author'] as String? ?? TrackPack.defaultAuthor,
      createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now().toUtc(),
      updatedAt:
          _parseDateTime(json['updatedAt']) ??
          _parseDateTime(json['createdAt']) ??
          DateTime.now().toUtc(),
      tags: _parseTags(json['tags']),
      tracks: _parseTracks(tracksJson),
    );
  }

  static List<String> _parseTags(dynamic value) {
    if (value is! List) {
      return const [];
    }
    return [
      for (final tag in value)
        if (tag is String && tag.trim().isNotEmpty) tag.trim(),
    ];
  }

  static List<TrackPackTrack> _parseTracks(List<dynamic> tracksJson) {
    final tracks = <TrackPackTrack>[];
    for (final entry in tracksJson) {
      if (entry is! Map<String, dynamic>) {
        continue;
      }
      try {
        tracks.add(_trackFromJson(entry));
      } on Object {
        // Skip malformed pack tracks instead of failing the whole pack.
      }
    }
    return tracks;
  }

  static TrackPackTrack _trackFromJson(Map<String, dynamic> json) {
    final title = json['trackTitle'] as String? ?? '';
    final trackJsonRaw = json['trackJson'];
    if (trackJsonRaw is String) {
      return TrackPackTrack(trackTitle: title, trackJson: trackJsonRaw);
    }
    if (trackJsonRaw is Map<String, dynamic>) {
      return TrackPackTrack(
        trackTitle: title,
        trackJson: jsonEncode(trackJsonRaw),
      );
    }
    throw const FormatException('Pack track is missing trackJson.');
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value is! String || value.isEmpty) {
      return null;
    }
    try {
      return DateTime.parse(value);
    } on Object {
      return null;
    }
  }
}
