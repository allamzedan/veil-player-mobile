import 'package:uuid/uuid.dart';
import 'package:veil_mobile/core/veil/veil_track.dart';
import 'package:veil_mobile/core/veil/veil_track_codec.dart';

/// A single VEIL track entry inside a [TrackPack].
class TrackPackTrack {
  const TrackPackTrack({
    required this.trackTitle,
    required this.trackJson,
  });

  final String trackTitle;
  final String trackJson;

  factory TrackPackTrack.fromVeilTrack(VeilTrack track) {
    return TrackPackTrack(
      trackTitle: track.title.trim().isEmpty
          ? VeilTrack.defaultUntitledTitle
          : track.title.trim(),
      trackJson: VeilTrackCodec.encode(track),
    );
  }

  VeilTrack? decodeTrack() => VeilTrackCodec.tryDecode(trackJson);
}

/// Local-only collection of shareable VEIL tracks.
class TrackPack {
  const TrackPack({
    required this.id,
    required this.title,
    required this.description,
    required this.version,
    required this.author,
    required this.createdAt,
    required this.updatedAt,
    required this.tags,
    required this.tracks,
  });

  static const String defaultVersion = '1.0.0';
  static const String defaultAuthor = 'VEIL Mobile';
  static const String defaultUntitledTitle = 'Untitled Pack';

  final String id;
  final String title;
  final String description;
  final String version;
  final String author;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;
  final List<TrackPackTrack> tracks;

  int get trackCount => tracks.length;

  factory TrackPack.create({
    required String title,
    String description = '',
    String author = defaultAuthor,
    List<String> tags = const [],
    List<TrackPackTrack> tracks = const [],
    String? id,
  }) {
    final now = DateTime.now().toUtc();
    return TrackPack(
      id: id ?? const Uuid().v4(),
      title: title.trim(),
      description: description.trim(),
      version: defaultVersion,
      author: author.trim().isEmpty ? defaultAuthor : author.trim(),
      createdAt: now,
      updatedAt: now,
      tags: List.unmodifiable(tags),
      tracks: List.unmodifiable(tracks),
    );
  }

  factory TrackPack.fromVeilTracks({
    required String title,
    required List<VeilTrack> tracks,
    String description = '',
    String author = defaultAuthor,
    List<String> tags = const [],
    String? id,
  }) {
    return TrackPack.create(
      id: id,
      title: title,
      description: description,
      author: author,
      tags: tags,
      tracks: [
        for (final track in tracks) TrackPackTrack.fromVeilTrack(track),
      ],
    );
  }

  TrackPack copyWith({
    String? title,
    String? description,
    String? version,
    String? author,
    DateTime? updatedAt,
    List<String>? tags,
    List<TrackPackTrack>? tracks,
  }) {
    return TrackPack(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      version: version ?? this.version,
      author: author ?? this.author,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now().toUtc(),
      tags: tags ?? this.tags,
      tracks: tracks ?? this.tracks,
    );
  }
}
