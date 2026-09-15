import 'package:flutter/material.dart';
import 'package:veil_mobile/core/subtitles/subtitle_settings.dart';

/// Subtitle text rendered over the video frame.
class PlayerSubtitleOverlay extends StatelessWidget {
  const PlayerSubtitleOverlay({
    super.key,
    required this.text,
    required this.visible,
    required this.settings,
  });

  final String? text;
  final bool visible;
  final SubtitleSettings settings;

  @override
  Widget build(BuildContext context) {
    if (!visible || text == null || text!.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final padding = switch (settings.position) {
      SubtitlePosition.bottom => const EdgeInsets.fromLTRB(20, 0, 20, 28),
      SubtitlePosition.middle => const EdgeInsets.symmetric(horizontal: 20),
      SubtitlePosition.top => const EdgeInsets.fromLTRB(20, 28, 20, 0),
    };

    final alignment = switch (settings.position) {
      SubtitlePosition.bottom => Alignment.bottomCenter,
      SubtitlePosition.middle => Alignment.center,
      SubtitlePosition.top => Alignment.topCenter,
    };

    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: settings.fontSizePx,
      fontWeight: FontWeight.w500,
      height: 1.25,
      shadows: settings.backgroundEnabled
          ? null
          : const [
              Shadow(
                blurRadius: 6,
                color: Colors.black87,
                offset: Offset(0, 1),
              ),
            ],
    );

    final subtitleText = Text(
      text!,
      textAlign: TextAlign.center,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      style: textStyle,
    );

    return IgnorePointer(
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: padding,
          child: settings.backgroundEnabled
              ? DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(
                      alpha: settings.backgroundOpacity,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    child: subtitleText,
                  ),
                )
              : subtitleText,
        ),
      ),
    );
  }
}
