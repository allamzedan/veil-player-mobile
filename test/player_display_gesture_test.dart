import 'package:flutter_test/flutter_test.dart';
import 'package:veil_mobile/features/player/domain/player_display_settings.dart';
import 'package:veil_mobile/features/player/presentation/widgets/player_gesture_classifier.dart';

void main() {
  group('PlayerDisplaySettings', () {
    test('clampLevel stays within 0.0 and 1.0', () {
      expect(PlayerDisplaySettings.clampLevel(-0.2), 0.0);
      expect(PlayerDisplaySettings.clampLevel(0.65), 0.65);
      expect(PlayerDisplaySettings.clampLevel(1.4), 1.0);
    });

    test('effectiveVolume is zero under VEIL mute but keeps user preference', () {
      const userVolume = 0.82;
      expect(
        PlayerDisplaySettings.effectiveVolume(
          userVolume: userVolume,
          veilMuteActive: true,
        ),
        0.0,
      );
      expect(userVolume, 0.82);
      expect(
        PlayerDisplaySettings.effectiveVolume(
          userVolume: userVolume,
          veilMuteActive: false,
        ),
        0.82,
      );
    });

    test('brightness overlay opacity increases as brightness decreases', () {
      expect(
        PlayerDisplaySettings.brightnessOverlayOpacity(1.0),
        0.0,
      );
      expect(
        PlayerDisplaySettings.brightnessOverlayOpacity(0.0),
        closeTo(0.75, 0.001),
      );
    });

    test('fromStorage tolerates invalid JSON', () {
      expect(
        PlayerDisplaySettings.fromStorage('not-json').volume,
        1.0,
      );
    });
  });

  group('PlayerGestureClassifier', () {
    test('classifies horizontal scrub when horizontal delta dominates', () {
      expect(
        PlayerGestureClassifier.classify(
          deltaX: 24,
          deltaY: 4,
          localX: 200,
          layoutWidth: 400,
        ),
        PlayerGestureDragKind.horizontal,
      );
    });

    test('classifies right-side vertical drag as volume', () {
      expect(
        PlayerGestureClassifier.classify(
          deltaX: 2,
          deltaY: -30,
          localX: 300,
          layoutWidth: 400,
        ),
        PlayerGestureDragKind.verticalVolume,
      );
    });

    test('classifies left-side vertical drag as brightness', () {
      expect(
        PlayerGestureClassifier.classify(
          deltaX: 1,
          deltaY: 28,
          localX: 80,
          layoutWidth: 400,
        ),
        PlayerGestureDragKind.verticalBrightness,
      );
    });

    test('returns none below touch slop', () {
      expect(
        PlayerGestureClassifier.classify(
          deltaX: 5,
          deltaY: 6,
          localX: 80,
          layoutWidth: 400,
        ),
        PlayerGestureDragKind.none,
      );
    });

    test('levelFromVerticalDrag swipe up increases level', () {
      expect(
        PlayerGestureClassifier.levelFromVerticalDrag(
          startLevel: 0.5,
          deltaY: -120,
          layoutHeight: 400,
        ),
        closeTo(0.8, 0.001),
      );
    });

    test('levelFromVerticalDrag swipe down decreases level', () {
      expect(
        PlayerGestureClassifier.levelFromVerticalDrag(
          startLevel: 0.7,
          deltaY: 80,
          layoutHeight: 400,
        ),
        closeTo(0.5, 0.001),
      );
    });

    test('levelFromVerticalDrag clamps at bounds', () {
      expect(
        PlayerGestureClassifier.levelFromVerticalDrag(
          startLevel: 0.9,
          deltaY: -400,
          layoutHeight: 400,
        ),
        1.0,
      );
      expect(
        PlayerGestureClassifier.levelFromVerticalDrag(
          startLevel: 0.1,
          deltaY: 400,
          layoutHeight: 400,
        ),
        0.0,
      );
    });
  });
}
