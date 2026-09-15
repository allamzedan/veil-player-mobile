import 'package:veil_mobile/core/track_packs/track_pack.dart';

/// Example local track pack templates illustrating common use cases.
abstract final class TrackPackSamples {
  static const String seedPrefKey = 'track_packs_samples_seeded_v1';

  static List<TrackPack> examples() {
    return [
      TrackPack.create(
        id: 'sample-family-safe',
        title: 'Family Safe Collection',
        description: 'Tracks curated for family-friendly viewing sessions.',
        tags: const ['family', 'safe'],
      ),
      TrackPack.create(
        id: 'sample-english-learning',
        title: 'English Learning Collection',
        description: 'Masks and skips tuned for language-learning videos.',
        tags: const ['english', 'learning'],
      ),
      TrackPack.create(
        id: 'sample-lecture',
        title: 'Lecture Collection',
        description: 'Lecture tracks with intro skips and focused mutes.',
        tags: const ['lecture', 'education'],
      ),
      TrackPack.create(
        id: 'sample-no-intro',
        title: 'No Intro Collection',
        description: 'Tracks that skip recurring intros and outros.',
        tags: const ['intro', 'skip'],
      ),
    ];
  }
}
