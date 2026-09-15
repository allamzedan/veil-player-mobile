import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:veil_mobile/core/storage/media_history_models.dart';
import 'package:veil_mobile/core/storage/media_history_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MediaHistoryStorageService', () {
    late MediaHistoryStorageService storage;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      storage = MediaHistoryStorageService(prefs);
    });

    test('stores recent videos with dedupe and max limit', () async {
      for (var i = 0; i < 22; i++) {
        await storage.recordRecentVideo(
          RecentVideoEntry(
            filename: 'video-$i.mp4',
            path: '/tmp/video-$i.mp4',
            durationMs: 60_000,
            lastOpenedAt: DateTime.utc(2026, 1, i + 1),
            lastPlaybackPositionMs: i * 1000,
          ),
        );
      }

      final videos = await storage.loadRecentVideos();
      expect(videos, hasLength(MediaHistoryLimits.maxRecentEntries));
      expect(videos.first.filename, 'video-21.mp4');
      expect(videos.last.filename, 'video-2.mp4');
    });

    test('moves duplicate recent video to front', () async {
      await storage.recordRecentVideo(
        RecentVideoEntry(
          filename: 'a.mp4',
          path: '/tmp/a.mp4',
          durationMs: 1000,
          lastOpenedAt: DateTime.utc(2026, 1, 1),
          lastPlaybackPositionMs: 0,
        ),
      );
      await storage.recordRecentVideo(
        RecentVideoEntry(
          filename: 'b.mp4',
          path: '/tmp/b.mp4',
          durationMs: 2000,
          lastOpenedAt: DateTime.utc(2026, 1, 2),
          lastPlaybackPositionMs: 0,
        ),
      );
      await storage.recordRecentVideo(
        RecentVideoEntry(
          filename: 'a.mp4',
          path: '/tmp/a.mp4',
          durationMs: 1000,
          lastOpenedAt: DateTime.utc(2026, 1, 3),
          lastPlaybackPositionMs: 500,
        ),
      );

      final videos = await storage.loadRecentVideos();
      expect(videos, hasLength(2));
      expect(videos.first.lastPlaybackPositionMs, 500);
      expect(videos.first.filename, 'a.mp4');
    });

    test('stores recent tracks and last session', () async {
      await storage.recordRecentTrack(
        RecentTrackEntry(
          filename: 'track.json',
          path: '/tmp/track.json',
          lastOpenedAt: DateTime.utc(2026, 3, 1),
          segmentCount: 3,
        ),
      );

      await storage.saveLastSession(
        LastSessionSnapshot(
          videoFilename: 'movie.mp4',
          videoPath: '/tmp/movie.mp4',
          videoDurationMs: 120_000,
          trackFilename: 'track.json',
          trackPath: '/tmp/track.json',
          playbackPositionMs: 45_000,
          playbackSpeed: 1.25,
          savedAt: DateTime.utc(2026, 3, 1, 12),
        ),
      );

      final tracks = await storage.loadRecentTracks();
      expect(tracks.single.segmentCount, 3);

      final session = await storage.loadLastSession();
      expect(session?.videoFilename, 'movie.mp4');
      expect(session?.playbackPositionMs, 45_000);
      expect(session?.playbackSpeed, 1.25);
    });

    test('removes recent entries', () async {
      await storage.recordRecentVideo(
        RecentVideoEntry(
          filename: 'remove-me.mp4',
          path: '/tmp/remove-me.mp4',
          durationMs: 1000,
          lastOpenedAt: DateTime.utc(2026, 4, 1),
          lastPlaybackPositionMs: 0,
        ),
      );

      final removed = await storage.removeRecentVideo('/tmp/remove-me.mp4');
      expect(removed, isTrue);
      expect(await storage.loadRecentVideos(), isEmpty);
    });
  });
}
