import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:veil_mobile/core/storage/veil_track_storage_service.dart';
import 'package:veil_mobile/core/veil/veil_segment.dart';
import 'package:veil_mobile/core/veil/veil_segment_type.dart';
import 'package:veil_mobile/core/veil/veil_track.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('VeilTrackStorageService', () {
    late VeilTrackStorageService storage;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      storage = VeilTrackStorageService(prefs);
    });

    test('saves, loads, and deletes tracks', () async {
      final track = VeilTrack(
        id: 'track-a',
        title: 'Demo',
        version: VeilTrack.desktopFormatVersion,
        createdAt: DateTime.utc(2026, 1, 1),
        updatedAt: DateTime.utc(2026, 1, 2),
        segments: const [
          VeilSegment(
            id: 'seg-1',
            type: VeilSegmentType.mask,
            startMs: 0,
            endMs: 1000,
          ),
        ],
      );

      await storage.saveTrackLocally(track);

      final loaded = await storage.loadTrackById('track-a');
      expect(loaded?.title, 'Demo');

      final all = await storage.loadSavedTracks();
      expect(all, hasLength(1));

      await storage.deleteTrack('track-a');
      expect(await storage.loadTrackById('track-a'), isNull);
      expect(await storage.loadSavedTracks(), isEmpty);
    });

    test('import and export JSON', () {
      final track = VeilTrack(
        id: 'track-b',
        title: 'Export',
        version: VeilTrack.desktopFormatVersion,
        createdAt: DateTime.utc(2026, 2, 1),
        updatedAt: DateTime.utc(2026, 2, 1),
        videoName: 'export-video.mp4',
        segments: const [],
      );

      final json = storage.exportTrackJson(track);
      final imported = storage.importTrackFromJson(json);

      expect(imported.title, 'export-video.mp4');
      expect(imported.segments, isEmpty);
      expect(json, contains('"subtitleCover"'));
      expect(json, isNot(contains('"manual-mobile"')));
    });
  });
}
