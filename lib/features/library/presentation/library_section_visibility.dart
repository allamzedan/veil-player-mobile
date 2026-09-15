import 'package:veil_mobile/core/track_packs/track_pack.dart';
import 'package:veil_mobile/features/library/application/media_history_controller.dart';

/// Whether the last-session block should appear in the library list.
bool libraryShowsLastSession(MediaHistoryState history) {
  return history.hasLastSession && history.lastSession != null;
}

/// Whether recent videos should appear (non-empty only).
bool libraryShowsRecentVideos(MediaHistoryState history) {
  return history.recentVideos.isNotEmpty;
}

/// Whether recent tracks should appear (non-empty only).
bool libraryShowsRecentTracks(MediaHistoryState history) {
  return history.recentTracks.isNotEmpty;
}

/// Sample packs seeded on first launch use ids prefixed with `sample-`.
bool isSampleTrackPack(TrackPack pack) => pack.id.startsWith('sample-');

/// Splits packs into imported/user packs first, then samples.
({List<TrackPack> imported, List<TrackPack> samples}) splitTrackPacks(
  List<TrackPack> packs,
) {
  final imported = <TrackPack>[];
  final samples = <TrackPack>[];

  for (final pack in packs) {
    if (isSampleTrackPack(pack)) {
      samples.add(pack);
    } else {
      imported.add(pack);
    }
  }

  return (imported: imported, samples: samples);
}
