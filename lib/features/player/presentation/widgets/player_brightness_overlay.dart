import 'package:flutter/material.dart';
import 'package:veil_mobile/features/player/domain/player_display_settings.dart';

/// In-app brightness dimming overlay (does not change system brightness).
class PlayerBrightnessOverlay extends StatelessWidget {
  const PlayerBrightnessOverlay({
    super.key,
    required this.brightness,
  });

  final double brightness;

  @override
  Widget build(BuildContext context) {
    final opacity = PlayerDisplaySettings.brightnessOverlayOpacity(brightness);
    if (opacity <= 0) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: ColoredBox(color: Colors.black.withValues(alpha: opacity)),
    );
  }
}
