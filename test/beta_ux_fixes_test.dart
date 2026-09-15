import 'package:flutter_test/flutter_test.dart';
import 'package:veil_mobile/features/library/application/media_history_controller.dart';
import 'package:veil_mobile/features/library/presentation/library_section_visibility.dart';
import 'package:veil_mobile/features/player/presentation/widgets/mask_rect_resize.dart';
import 'package:veil_mobile/features/player/presentation/widgets/quick_mask_placement_overlay.dart';
import 'package:veil_mobile/core/track_packs/track_pack.dart';
import 'package:veil_mobile/shared/utils/veil_time_input.dart';

void main() {
  group('VeilTimeInput', () {
    test('formats milliseconds as HH:MM:SS', () {
      expect(VeilTimeInput.formatMs(0), '00:00:00');
      expect(VeilTimeInput.formatMs(1000), '00:00:01');
      expect(VeilTimeInput.formatMs(61000), '00:01:01');
      expect(VeilTimeInput.formatMs(3661000), '01:01:01');
    });

    test('parses HH:MM:SS and MM:SS', () {
      expect(VeilTimeInput.tryParseMs('00:00:00'), 0);
      expect(VeilTimeInput.tryParseMs('00:00:01'), 1000);
      expect(VeilTimeInput.tryParseMs('01:02:03'), 3723000);
      expect(VeilTimeInput.tryParseMs('02:30'), 150000);
      expect(VeilTimeInput.tryParseMs('45'), 45000);
    });

    test('rejects invalid time format', () {
      expect(VeilTimeInput.tryParseMs(''), isNull);
      expect(VeilTimeInput.tryParseMs('abc'), isNull);
      expect(VeilTimeInput.tryParseMs('00:99:00'), isNull);
      expect(VeilTimeInput.tryParseMs('1:2'), isNull);
    });

    test('validates start/end range', () {
      expect(VeilTimeInput.isValidRange(0, 1000), isTrue);
      expect(VeilTimeInput.isValidRange(1000, 1000), isFalse);
      expect(VeilTimeInput.isValidRange(2000, 1000), isFalse);
    });
  });

  group('library section visibility', () {
    const emptyHistory = MediaHistoryState();

    test('hides empty history sections', () {
      expect(libraryShowsLastSession(emptyHistory), isFalse);
      expect(libraryShowsRecentVideos(emptyHistory), isFalse);
      expect(libraryShowsRecentTracks(emptyHistory), isFalse);
    });

    test('splits sample and imported packs', () {
      final packs = [
        TrackPack.create(id: 'sample-family-safe', title: 'Sample'),
        TrackPack.create(id: 'user-pack-1', title: 'Imported'),
      ];
      final split = splitTrackPacks(packs);
      expect(split.samples, hasLength(1));
      expect(split.imported, hasLength(1));
      expect(isSampleTrackPack(split.samples.first), isTrue);
    });
  });

  group('mask rect resize', () {
    const rect = MaskRectPercents(
      xPercent: 20,
      yPercent: 20,
      widthPercent: 30,
      heightPercent: 25,
    );

    test('resizes from each corner', () {
      final bottomRight = resizeMaskRectFromCorner(
        rect: rect,
        corner: MaskResizeCorner.bottomRight,
        deltaXPercent: 5,
        deltaYPercent: 5,
      );
      expect(bottomRight.widthPercent, greaterThan(rect.widthPercent));
      expect(bottomRight.heightPercent, greaterThan(rect.heightPercent));
      expect(bottomRight.xPercent, rect.xPercent);
      expect(bottomRight.yPercent, rect.yPercent);

      final bottomLeft = resizeMaskRectFromCorner(
        rect: rect,
        corner: MaskResizeCorner.bottomLeft,
        deltaXPercent: -5,
        deltaYPercent: 5,
      );
      expect(bottomLeft.widthPercent, greaterThan(rect.widthPercent));
      expect(bottomLeft.xPercent, lessThan(rect.xPercent));

      final topRight = resizeMaskRectFromCorner(
        rect: rect,
        corner: MaskResizeCorner.topRight,
        deltaXPercent: 5,
        deltaYPercent: -5,
      );
      expect(topRight.heightPercent, greaterThan(rect.heightPercent));
      expect(topRight.yPercent, lessThan(rect.yPercent));

      final topLeft = resizeMaskRectFromCorner(
        rect: rect,
        corner: MaskResizeCorner.topLeft,
        deltaXPercent: -5,
        deltaYPercent: -5,
      );
      expect(topLeft.widthPercent, greaterThan(rect.widthPercent));
      expect(topLeft.heightPercent, greaterThan(rect.heightPercent));
      expect(topLeft.xPercent, lessThan(rect.xPercent));
      expect(topLeft.yPercent, lessThan(rect.yPercent));
    });
  });
}
