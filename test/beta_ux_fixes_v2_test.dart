import 'package:flutter_test/flutter_test.dart';
import 'package:veil_mobile/app/incoming_file_classifier.dart';
import 'package:veil_mobile/core/storage/media_history_models.dart';
import 'package:veil_mobile/core/veil/bookmark_segments.dart';
import 'package:veil_mobile/core/veil/veil_segment.dart';
import 'package:veil_mobile/core/veil/veil_track.dart';
import 'package:veil_mobile/features/library/application/media_history_controller.dart';
import 'package:veil_mobile/features/player/domain/next_video_suggestion.dart';
import 'package:veil_mobile/features/player/domain/player_playback_settings.dart';
import 'package:veil_mobile/shared/utils/veil_json_file_picker.dart';
import 'package:veil_mobile/shared/utils/veil_track_file_export.dart';
import 'package:veil_mobile/shared/utils/video_folder_scanner.dart';

void main() {
  group('veil track file extension', () {
    test('export filename uses .veil by default', () {
      expect(
        veilTrackExportFileName(trackTitle: 'Family Safe Demo'),
        'family_safe_demo.veil',
      );
      expect(veilTrackExportFileName(), startsWith('veil_track_'));
      expect(veilTrackExportFileName(), endsWith('.veil'));
    });

    test('import accepts .veil, .veil.json, and .json names', () {
      expect(isVeilTrackFileName('demo.veil'), isTrue);
      expect(isVeilTrackFileName('demo.veil.json'), isTrue);
      expect(isVeilTrackFileName('demo.json'), isTrue);
      expect(isVeilTrackFileName('readme.txt'), isFalse);
    });

    test('classifier accepts standalone .veil files', () {
      expect(
        IncomingFileClassifier.classify(
          filename: 'track.veil',
          mimeType: 'application/json',
        ),
        IncomingFileKind.track,
      );
    });
  });

  group('PlayerPlaybackSettings', () {
    test('autoplay next video defaults to false', () {
      expect(const PlayerPlaybackSettings().autoplayNextVideo, isFalse);
      expect(PlayerPlaybackSettings.fromStorage(null).autoplayNextVideo, isFalse);
      expect(
        PlayerPlaybackSettings.fromStorage('{"autoplayNextVideo": true}')
            .autoplayNextVideo,
        isTrue,
      );
    });
  });

  group('BookmarkSegments', () {
    test('orders bookmarks by start time', () {
      final now = DateTime.utc(2026, 5, 19);
      final track = VeilTrack(
        id: 't1',
        title: 'Test',
        version: '1.0.0',
        createdAt: now,
        updatedAt: now,
        segments: [
          VeilSegment.bookmark(positionMs: 9000, title: 'B'),
          VeilSegment.bookmark(positionMs: 1000, title: 'A'),
        ],
      );
      final bookmarks = BookmarkSegments.fromTrack(track);
      expect(bookmarks.map((b) => b.label), ['A', 'B']);
    });
  });

  group('NextVideoSuggestionResolver', () {
    test('prefers next file in folder listing', () {
      const history = MediaHistoryState();
      final next = NextVideoSuggestionResolver.resolve(
        currentVideoPath: '/videos/a.mp4',
        history: history,
        folderVideos: const [
          FolderVideoEntry(path: '/videos/a.mp4', filename: 'a.mp4'),
          FolderVideoEntry(path: '/videos/b.mp4', filename: 'b.mp4'),
        ],
      );
      expect(next?.filename, 'b.mp4');
    });

    test('falls back to recent videos', () {
      final opened = DateTime.utc(2026, 5, 19);
      final history = MediaHistoryState(
        recentVideos: [
          RecentVideoEntry(
            filename: 'current.mp4',
            path: '/current.mp4',
            durationMs: 1000,
            lastOpenedAt: opened,
            lastPlaybackPositionMs: 0,
          ),
          RecentVideoEntry(
            filename: 'other.mp4',
            path: '/other.mp4',
            durationMs: 1000,
            lastOpenedAt: opened,
            lastPlaybackPositionMs: 0,
          ),
        ],
      );
      final next = NextVideoSuggestionResolver.resolve(
        currentVideoPath: '/current.mp4',
        history: history,
        folderVideos: const [],
      );
      expect(next?.filename, 'other.mp4');
    });
  });
}
