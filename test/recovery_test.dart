import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:veil_mobile/core/recovery/recovery_autosave_throttle.dart';
import 'package:veil_mobile/core/recovery/recovery_draft.dart';
import 'package:veil_mobile/core/recovery/recovery_storage_service.dart';

void main() {
  group('RecoveryDraft', () {
    test('serializes and deserializes', () {
      final draft = RecoveryDraft(
        id: 'draft-1',
        source: RecoveryDraftSource.player,
        trackId: 'track-1',
        trackTitle: 'Demo track',
        trackJson: '{"title":"Demo"}',
        videoName: 'clip.mp4',
        videoPath: '/tmp/clip.mp4',
        updatedAt: DateTime.utc(2026, 6, 18, 12),
        reason: RecoveryDraftReason.autosave,
        segmentCount: 2,
        isDirty: true,
      );

      final restored = RecoveryDraft.fromJson(draft.toJson());

      expect(restored.id, draft.id);
      expect(restored.source, RecoveryDraftSource.player);
      expect(restored.trackTitle, 'Demo track');
      expect(restored.videoPath, '/tmp/clip.mp4');
      expect(restored.segmentCount, 2);
      expect(restored.isDirty, isTrue);
      expect(restored.reason, RecoveryDraftReason.autosave);
    });

    test('tryFromJson returns null for missing required fields', () {
      expect(
        RecoveryDraft.tryFromJson({'id': 'x', 'source': 'player'}),
        isNull,
      );
      expect(
        RecoveryDraft.tryFromJson({
          'id': 'x',
          'source': 'player',
          'trackTitle': 'Title',
          'trackJson': '{}',
          'updatedAt': 'not-a-date',
        }),
        isNotNull,
      );
    });
  });

  group('RecoveryStorageService', () {
    late SharedPreferences prefs;
    late RecoveryStorageService storage;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      storage = RecoveryStorageService(prefs);
    });

    test('saves and loads one draft per source', () async {
      final playerDraft = RecoveryDraft(
        id: 'p1',
        source: RecoveryDraftSource.player,
        trackTitle: 'Player draft',
        trackJson: '{}',
        updatedAt: DateTime.utc(2026, 1, 1),
        reason: RecoveryDraftReason.autosave,
        segmentCount: 1,
        isDirty: true,
      );
      final builderDraft = RecoveryDraft(
        id: 'b1',
        source: RecoveryDraftSource.trackBuilder,
        trackTitle: 'Builder draft',
        trackJson: '{}',
        updatedAt: DateTime.utc(2026, 1, 2),
        reason: RecoveryDraftReason.background,
        segmentCount: 3,
        isDirty: true,
      );

      await storage.saveDraft(playerDraft);
      await storage.saveDraft(builderDraft);

      expect(storage.loadPlayerDraft()?.id, 'p1');
      expect(storage.loadTrackBuilderDraft()?.id, 'b1');
    });

    test('overwrites existing draft for same source', () async {
      await storage.saveDraft(
        RecoveryDraft(
          id: 'old',
          source: RecoveryDraftSource.player,
          trackTitle: 'Old',
          trackJson: '{}',
          updatedAt: DateTime.utc(2026, 1, 1),
          reason: RecoveryDraftReason.autosave,
          segmentCount: 0,
          isDirty: true,
        ),
      );
      await storage.saveDraft(
        RecoveryDraft(
          id: 'new',
          source: RecoveryDraftSource.player,
          trackTitle: 'New',
          trackJson: '{"v":2}',
          updatedAt: DateTime.utc(2026, 1, 2),
          reason: RecoveryDraftReason.autosave,
          segmentCount: 1,
          isDirty: true,
        ),
      );

      expect(storage.loadPlayerDraft()?.id, 'new');
      expect(storage.loadPlayerDraft()?.trackJson, '{"v":2}');
    });

    test('returns null for corrupt stored draft JSON', () async {
      await prefs.setString(
        RecoveryStorageService.playerDraftKey,
        '{"id":"x","source":"player"}',
      );

      expect(storage.loadPlayerDraft(), isNull);
    });

    test('deletes draft by source', () async {
      await storage.saveDraft(
        RecoveryDraft(
          id: 'p1',
          source: RecoveryDraftSource.player,
          trackTitle: 'Draft',
          trackJson: '{}',
          updatedAt: DateTime.utc(2026, 1, 1),
          reason: RecoveryDraftReason.autosave,
          segmentCount: 0,
          isDirty: true,
        ),
      );

      await storage.deleteDraft(RecoveryDraftSource.player);

      expect(storage.loadPlayerDraft(), isNull);
    });
  });

  group('RecoveryAutosaveThrottle', () {
    test('allows first save and blocks within interval', () async {
      final throttle = RecoveryAutosaveThrottle(
        minInterval: const Duration(milliseconds: 50),
      );

      expect(throttle.shouldSave(force: false), isTrue);
      throttle.markSaved();
      expect(throttle.shouldSave(force: false), isFalse);
      expect(throttle.shouldSave(force: true), isTrue);

      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(throttle.shouldSave(force: false), isTrue);
    });
  });
}
