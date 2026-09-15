import 'package:veil_mobile/core/track_packs/track_pack.dart';
import 'package:veil_mobile/core/tracks/track_summary.dart';

/// Read-only statistics for a track inside a pack.
class TrackPackTrackPreview {
  const TrackPackTrackPreview({
    required this.trackTitle,
    required this.summary,
    required this.decodeSucceeded,
  });

  final String trackTitle;
  final TrackSummary? summary;
  final bool decodeSucceeded;

  static TrackPackTrackPreview fromPackTrack(TrackPackTrack track) {
    final decoded = track.decodeTrack();
    if (decoded == null) {
      return TrackPackTrackPreview(
        trackTitle: track.trackTitle,
        summary: null,
        decodeSucceeded: false,
      );
    }

    return TrackPackTrackPreview(
      trackTitle: track.trackTitle,
      summary: TrackSummary.fromTrack(decoded),
      decodeSucceeded: true,
    );
  }
}

/// Read-only summary for a local track pack.
class TrackPackSummary {
  const TrackPackSummary({
    required this.title,
    required this.author,
    required this.trackCount,
    required this.tags,
    required this.description,
  });

  final String title;
  final String author;
  final int trackCount;
  final List<String> tags;
  final String description;

  factory TrackPackSummary.fromPack(TrackPack pack) {
    return TrackPackSummary(
      title: pack.title.trim().isEmpty
          ? TrackPack.defaultUntitledTitle
          : pack.title.trim(),
      author: pack.author,
      trackCount: pack.trackCount,
      tags: pack.tags,
      description: pack.description,
    );
  }
}

List<TrackPackTrackPreview> trackPackTrackPreviews(TrackPack pack) {
  return [
    for (final track in pack.tracks) TrackPackTrackPreview.fromPackTrack(track),
  ];
}
