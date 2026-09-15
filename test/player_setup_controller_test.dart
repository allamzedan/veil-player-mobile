import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:veil_mobile/core/storage/storage_providers.dart';
import 'package:veil_mobile/core/veil/veil_segment.dart';
import 'package:veil_mobile/core/veil/veil_segment_type.dart';
import 'package:veil_mobile/core/veil/veil_track.dart';
import 'package:veil_mobile/features/player/application/player_setup_controller.dart';
import 'package:veil_mobile/features/player/application/player_setup_state.dart';
import 'package:veil_mobile/shared/constants/app_strings.dart';

Future<ProviderContainer> createTestContainer() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  return ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
}

void main() {
  group('PlayerSetupController.validatePairing', () {
    test('is ready when video and valid track are selected', () async {
      final container = await createTestContainer();
      addTearDown(container.dispose);

      final controller = container.read(playerSetupControllerProvider.notifier);
      container.read(playerSetupControllerProvider);

      controller.state = controller.state.copyWith(
        selectedVideoName: 'demo.mp4',
        selectedTrack: VeilTrack.empty(title: 'Demo'),
        selectedTrackTitle: 'Demo',
        videoPlaybackStatus: PlayerVideoPlaybackStatus.ready,
      );
      controller.validatePairing();

      final state = container.read(playerSetupControllerProvider);
      expect(state.isReadyForPlayback, isTrue);
      expect(state.errorMessage, isNull);
    });

    test('does not require track when only video is selected', () async {
      final container = await createTestContainer();
      addTearDown(container.dispose);

      final controller = container.read(playerSetupControllerProvider.notifier);

      controller.state = controller.state.copyWith(
        selectedVideoName: 'demo.mp4',
        videoPlaybackStatus: PlayerVideoPlaybackStatus.ready,
      );
      controller.validatePairing();

      final state = container.read(playerSetupControllerProvider);
      expect(state.errorMessage, isNull);
      expect(state.isReadyForPlayback, isFalse);
    });

    test('warns when track video name differs from selected file', () async {
      final container = await createTestContainer();
      addTearDown(container.dispose);

      final controller = container.read(playerSetupControllerProvider.notifier);

      final track = VeilTrack.empty(
        title: 'Demo',
      ).copyWith(videoName: 'Everyday Conversations.mp4', segments: []);

      controller.state = controller.state.copyWith(
        selectedVideoName: 'other-video.mp4',
        selectedTrack: track,
        selectedTrackTitle: 'Demo',
        videoPlaybackStatus: PlayerVideoPlaybackStatus.ready,
      );
      controller.validatePairing();

      final state = container.read(playerSetupControllerProvider);
      expect(state.isReadyForPlayback, isTrue);
      expect(state.validationMessages, isNotEmpty);
    });
  });

  group('PlayerSetupController.addQuickSegment', () {
    test('requires video before adding quick segment', () async {
      final container = await createTestContainer();
      addTearDown(container.dispose);

      final controller = container.read(playerSetupControllerProvider.notifier);
      final error = controller.addQuickSegment(
        type: VeilSegmentType.mask,
        duration: const Duration(seconds: 5),
      );

      expect(error, AppStrings.playerQuickActionRequiresVideo);
    });

    test('creates draft track and appends mask segment', () async {
      final container = await createTestContainer();
      addTearDown(container.dispose);

      final controller = container.read(playerSetupControllerProvider.notifier);
      controller.state = controller.state.copyWith(
        selectedVideoName: 'demo.mp4',
        videoPlaybackStatus: PlayerVideoPlaybackStatus.ready,
      );

      final error = controller.addQuickSegment(
        type: VeilSegmentType.mask,
        duration: const Duration(seconds: 5),
      );

      expect(error, isNull);
      final state = container.read(playerSetupControllerProvider);
      expect(state.selectedTrack, isNotNull);
      expect(state.selectedTrack!.segments, hasLength(1));
      expect(state.selectedTrack!.segments.first.type, VeilSegmentType.mask);
      expect(state.selectedTrack!.segments.first.startMs, 0);
      expect(state.selectedTrack!.segments.first.endMs, 5000);
      expect(state.hasUnsavedTrackChanges, isTrue);
    });

    test('appends to loaded track', () async {
      final container = await createTestContainer();
      addTearDown(container.dispose);

      final controller = container.read(playerSetupControllerProvider.notifier);
      final existing = VeilTrack.empty(title: 'Loaded');
      controller.state = controller.state.copyWith(
        selectedVideoName: 'demo.mp4',
        selectedTrack: existing,
        selectedTrackTitle: 'Loaded',
        videoPlaybackStatus: PlayerVideoPlaybackStatus.ready,
      );

      final error = controller.addQuickSegment(
        type: VeilSegmentType.mute,
        duration: const Duration(seconds: 3),
      );

      expect(error, isNull);
      final state = container.read(playerSetupControllerProvider);
      expect(state.selectedTrack!.segments, hasLength(1));
      expect(state.selectedTrack!.segments.first.type, VeilSegmentType.mute);
      expect(state.selectedTrack!.id, existing.id);
    });

    test('appends mask with custom rect', () async {
      final container = await createTestContainer();
      addTearDown(container.dispose);

      final controller = container.read(playerSetupControllerProvider.notifier);
      controller.state = controller.state.copyWith(
        selectedVideoName: 'demo.mp4',
        videoPlaybackStatus: PlayerVideoPlaybackStatus.ready,
      );

      final customRect = {
        'xPercent': 20.0,
        'yPercent': 30.0,
        'widthPercent': 40.0,
        'heightPercent': 25.0,
      };
      final error = controller.addQuickSegment(
        type: VeilSegmentType.mask,
        duration: const Duration(seconds: 5),
        maskRect: customRect,
      );

      expect(error, isNull);
      final segment = container
          .read(playerSetupControllerProvider)
          .selectedTrack!
          .segments
          .first;
      expect(segment.rect?['xPercent'], 20.0);
      expect(segment.rect?['widthPercent'], 40.0);
    });
  });

  group('PlayerSetupController.segmentManager', () {
    Future<ProviderContainer> readyContainer() async {
      final container = await createTestContainer();
      final controller = container.read(playerSetupControllerProvider.notifier);
      controller.state = controller.state.copyWith(
        selectedVideoName: 'demo.mp4',
        selectedTrack: VeilTrack.empty(title: 'Demo').copyWith(
          segments: [
            VeilSegment.quickAction(
              id: 'mask-1',
              type: VeilSegmentType.mask,
              startMs: 8000,
              endMs: 13000,
            ),
            VeilSegment.quickAction(
              id: 'mute-1',
              type: VeilSegmentType.mute,
              startMs: 25000,
              endMs: 28000,
            ),
          ],
        ),
        selectedTrackTitle: 'Demo',
        videoPlaybackStatus: PlayerVideoPlaybackStatus.ready,
      );
      return container;
    }

    test('sortedSegments returns segments ordered by start', () async {
      final container = await readyContainer();
      addTearDown(container.dispose);

      final sorted = container
          .read(playerSetupControllerProvider.notifier)
          .sortedSegments;
      expect(sorted.map((s) => s.id), ['mask-1', 'mute-1']);
    });

    test('deleteSegment removes segment and marks unsaved', () async {
      final container = await readyContainer();
      addTearDown(container.dispose);
      final controller = container.read(playerSetupControllerProvider.notifier);

      expect(controller.deleteSegment('mute-1'), isTrue);

      final state = container.read(playerSetupControllerProvider);
      expect(state.selectedTrack!.segments, hasLength(1));
      expect(state.selectedTrack!.segments.first.id, 'mask-1');
      expect(state.hasUnsavedTrackChanges, isTrue);
    });

    test('duplicateSegment offsets timing by one second', () async {
      final container = await readyContainer();
      addTearDown(container.dispose);
      final controller = container.read(playerSetupControllerProvider.notifier);

      final duplicate = controller.duplicateSegment('mask-1');

      expect(duplicate, isNotNull);
      expect(duplicate!.startMs, 9000);
      expect(duplicate.endMs, 14000);
      expect(
        container.read(playerSetupControllerProvider).selectedTrack!.segments,
        hasLength(3),
      );
    });

    test('updateSegment replaces segment data', () async {
      final container = await readyContainer();
      addTearDown(container.dispose);
      final controller = container.read(playerSetupControllerProvider.notifier);
      final original = controller.sortedSegments.first;

      final updated = original.copyWith(startMs: 10000, endMs: 15000);
      expect(controller.updateSegment(updated), isTrue);

      final saved = container
          .read(playerSetupControllerProvider)
          .selectedTrack!
          .segments
          .firstWhere((s) => s.id == 'mask-1');
      expect(saved.startMs, 10000);
      expect(saved.endMs, 15000);
    });

    test('setSegmentEnabled toggles enabled flag', () async {
      final container = await readyContainer();
      addTearDown(container.dispose);
      final controller = container.read(playerSetupControllerProvider.notifier);

      expect(controller.setSegmentEnabled('mask-1', false), isTrue);

      final segment = container
          .read(playerSetupControllerProvider)
          .selectedTrack!
          .segments
          .firstWhere((s) => s.id == 'mask-1');
      expect(segment.enabled, isFalse);
    });
  });
}
