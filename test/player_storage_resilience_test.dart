import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:veil_mobile/core/recovery/recovery_draft.dart';
import 'package:veil_mobile/core/recovery/recovery_provider.dart';
import 'package:veil_mobile/core/recovery/recovery_storage_service.dart';
import 'package:veil_mobile/core/storage/storage_providers.dart';
import 'package:veil_mobile/core/tracks/track_summary.dart';
import 'package:veil_mobile/core/veil/veil_segment.dart';
import 'package:veil_mobile/core/veil/veil_segment_type.dart';
import 'package:veil_mobile/core/veil/veil_track.dart';
import 'package:veil_mobile/features/player/application/player_setup_controller.dart';
import 'package:veil_mobile/features/player/application/player_setup_state.dart';
import 'package:veil_mobile/features/tracks/presentation/track_details_sheet.dart';
import 'package:veil_mobile/shared/constants/app_strings.dart';

void main() {
  group('+VEIL menu build safety', () {
    test('export subtitle is null for bookmark-only tracks', () {
      final track = VeilTrack.empty(title: 'Bookmarks only').copyWith(
        segments: [
          VeilSegment.bookmark(
            positionMs: 60_000,
            title: 'Chapter',
          ),
        ],
      );
      final summary = TrackSummary.fromTrack(track);

      expect(summary.totalActions, 0);
      expect(summary.bookmarkCount, 1);
      expect(trackExportSummarySubtitle(summary), isNull);
    });

    test('bookmark-only track keeps export menu eligible without subtitle text', () {
      final track = VeilTrack.empty(title: 'Bookmarks only').copyWith(
        segments: [
          VeilSegment.bookmark(
            positionMs: 10_000,
            title: 'Note',
          ),
        ],
      );

      expect(track.segments, isNotEmpty);
      expect(TrackSummary.fromTrack(track).totalActions, 0);
      expect(trackExportSummarySubtitle(TrackSummary.fromTrack(track)), isNull);
    });
  });

  group('recovery autosave resilience', () {
    test('autosave failure returns false without throwing', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          recoveryStorageServiceProvider.overrideWithValue(
            _ThrowingRecoveryStorageService(prefs),
          ),
          playerSetupControllerProvider.overrideWith(
            () => _DirtyPlayerController(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final saved = await container
          .read(recoveryControllerProvider.notifier)
          .autosavePlayer(force: true);

      expect(saved, isFalse);
    });
  });

  group('player quick action resilience', () {
    test('addQuickBookmark succeeds when recovery autosave fails', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          recoveryStorageServiceProvider.overrideWithValue(
            _ThrowingRecoveryStorageService(prefs),
          ),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(playerSetupControllerProvider.notifier);
      controller.state = const PlayerSetupState(
        selectedVideoName: 'clip.mp4',
        videoPlaybackStatus: PlayerVideoPlaybackStatus.ready,
      );

      final error = controller.addQuickBookmark(
        title: 'Scene',
        positionMs: 5_000,
      );
      expect(error, isNull);
      expect(controller.state.selectedTrack?.segments, hasLength(1));
      expect(
        controller.state.selectedTrack?.segments.single.type,
        VeilSegmentType.bookmark,
      );

      await Future<void>.delayed(Duration.zero);
      expect(
        controller.state.storageSnackMessage,
        AppStrings.storageWriteFailedKeepVideoOpen,
      );
    });
  });

  group('storage messaging', () {
    test('storageWriteFailedKeepVideoOpen mentions video stays open', () {
      expect(
        AppStrings.storageWriteFailedKeepVideoOpen,
        contains('video is still open'),
      );
    });
  });
}

class _ThrowingRecoveryStorageService extends RecoveryStorageService {
  _ThrowingRecoveryStorageService(super.prefs);

  @override
  Future<void> saveDraft(RecoveryDraft draft) async {
    throw StateError('Failed to save recovery draft locally.');
  }
}

class _DirtyPlayerController extends PlayerSetupController {
  @override
  PlayerSetupState build() {
    return PlayerSetupState(
      selectedVideoName: 'clip.mp4',
      videoPlaybackStatus: PlayerVideoPlaybackStatus.ready,
      selectedTrack: VeilTrack.empty(title: 'Draft'),
      hasUnsavedTrackChanges: true,
    );
  }
}
