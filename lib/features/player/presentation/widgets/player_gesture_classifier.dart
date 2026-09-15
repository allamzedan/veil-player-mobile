/// Classifies pointer drag intent for the player gesture layer.
enum PlayerGestureDragKind {
  none,
  horizontal,
  verticalVolume,
  verticalBrightness,
}

abstract final class PlayerGestureClassifier {
  static const double touchSlop = 18;

  /// Returns drag kind once movement exceeds [touchSlop]; [none] until then.
  static PlayerGestureDragKind classify({
    required double deltaX,
    required double deltaY,
    required double localX,
    required double layoutWidth,
    double slop = touchSlop,
  }) {
    if (deltaX.abs() <= slop && deltaY.abs() <= slop) {
      return PlayerGestureDragKind.none;
    }

    if (deltaX.abs() > deltaY.abs()) {
      return deltaX.abs() > slop
          ? PlayerGestureDragKind.horizontal
          : PlayerGestureDragKind.none;
    }

    if (deltaY.abs() <= slop) {
      return PlayerGestureDragKind.none;
    }

    final isLeftHalf = localX < layoutWidth / 2;
    return isLeftHalf
        ? PlayerGestureDragKind.verticalBrightness
        : PlayerGestureDragKind.verticalVolume;
  }

  /// Maps vertical drag to a level change (swipe up increases).
  static double levelFromVerticalDrag({
    required double startLevel,
    required double deltaY,
    required double layoutHeight,
  }) {
    if (layoutHeight <= 0) {
      return startLevel;
    }
    final next = startLevel - (deltaY / layoutHeight);
    return next.clamp(0.0, 1.0);
  }

  static int levelPercent(double level) {
    return (level.clamp(0.0, 1.0) * 100).round();
  }
}
