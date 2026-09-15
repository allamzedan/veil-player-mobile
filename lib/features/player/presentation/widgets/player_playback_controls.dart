import 'package:flutter/material.dart';
import 'package:veil_mobile/core/veil/veil_segment.dart';
import 'package:veil_mobile/features/player/application/player_setup_state.dart';
import 'package:veil_mobile/features/player/presentation/player_fullscreen_mode.dart';
import 'package:veil_mobile/features/player/presentation/widgets/player_timeline_bookmarks.dart';
import 'package:veil_mobile/shared/constants/app_strings.dart';
import 'package:veil_mobile/shared/utils/veil_duration_format.dart';
import 'package:video_player/video_player.dart';

/// Single-rail playback controls:
/// [Play] [Current] [Seekbar] [Duration] [Subtitle] [Speed] [Fullscreen]
class PlayerPlaybackControls extends StatelessWidget {
  const PlayerPlaybackControls({
    super.key,
    required this.controller,
    required this.setup,
    required this.onTogglePlayPause,
    required this.onSeek,
    required this.onFullscreen,
    required this.isFullscreen,
    required this.onPickSubtitle,
    required this.onToggleSubtitles,
    required this.onOpenSubtitleSettings,
    required this.onSetSpeed,
    this.bookmarks = const [],
    this.onBookmarkSeek,
  });

  final VideoPlayerController controller;
  final PlayerSetupState setup;
  final VoidCallback onTogglePlayPause;
  final Future<void> Function(Duration position) onSeek;
  final VoidCallback onFullscreen;
  final bool isFullscreen;
  final VoidCallback onPickSubtitle;
  final VoidCallback onToggleSubtitles;
  final VoidCallback onOpenSubtitleSettings;
  final ValueChanged<double> onSetSpeed;
  final List<VeilSegment> bookmarks;
  final ValueChanged<VeilSegment>? onBookmarkSeek;

  static const _speedOptions = [0.5, 1.0, 1.25, 1.5, 2.0];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.88)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 10, 4, 6),
        child: ValueListenableBuilder<VideoPlayerValue>(
          valueListenable: controller,
          builder: (context, value, _) {
            final duration = value.duration;
            final position = value.position;
            final maxMs = duration.inMilliseconds;
            final sliderValue = maxMs > 0
                ? position.inMilliseconds.clamp(0, maxMs).toDouble()
                : 0.0;
            final positionLabel = VeilDurationFormat.format(position);
            final durationLabel = VeilDurationFormat.format(duration);
            final timeWidth = duration.inHours > 0 ? 54.0 : 40.0;

            final rail = Row(
              children: [
                IconButton(
                  onPressed: value.isInitialized ? onTogglePlayPause : null,
                  icon: Icon(
                    value.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.all(6),
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                ),
                SizedBox(
                  width: timeWidth,
                  child: Text(
                    positionLabel,
                    style: _timeStyle(theme),
                    textAlign: TextAlign.end,
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (bookmarks.isNotEmpty && onBookmarkSeek != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: PlayerTimelineBookmarks(
                            bookmarks: bookmarks,
                            durationMs: maxMs,
                            onTapBookmark: onBookmarkSeek!,
                          ),
                        ),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: theme.colorScheme.primary,
                          inactiveTrackColor: Colors.white24,
                          thumbColor: theme.colorScheme.primary,
                          overlayColor: theme.colorScheme.primary.withValues(
                            alpha: 0.2,
                          ),
                          trackHeight: 3,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 12,
                          ),
                        ),
                        child: Slider(
                          value: sliderValue,
                          max: maxMs > 0 ? maxMs.toDouble() : 1,
                          onChanged: value.isInitialized && maxMs > 0
                              ? (ms) {
                                  onSeek(Duration(milliseconds: ms.round()));
                                }
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: timeWidth,
                  child: Text(
                    durationLabel,
                    style: _timeStyle(theme),
                    textAlign: TextAlign.start,
                  ),
                ),
                _SubtitleIconButton(
                  setup: setup,
                  onPick: onPickSubtitle,
                  onToggle: onToggleSubtitles,
                  onOpenSettings: onOpenSubtitleSettings,
                ),
                _SpeedChip(
                  label: setup.playbackSpeedLabel,
                  onSelected: onSetSpeed,
                  currentSpeed: setup.playbackSpeed,
                ),
                if (PlayerFullscreenMode.isSupported)
                  IconButton(
                    onPressed: onFullscreen,
                    tooltip: isFullscreen
                        ? AppStrings.playerExitFullscreen
                        : AppStrings.playerFullscreen,
                    icon: Icon(
                      isFullscreen
                          ? Icons.fullscreen_exit_rounded
                          : Icons.fullscreen_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                  ),
              ],
            );

            return LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 320) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: constraints.maxWidth,
                      ),
                      child: rail,
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: rail,
                );
              },
            );
          },
        ),
      ),
    );
  }

  static TextStyle? _timeStyle(ThemeData theme) {
    return theme.textTheme.labelSmall?.copyWith(
      color: Colors.white70,
      fontFeatures: const [FontFeature.tabularFigures()],
      fontSize: 11,
    );
  }

  static String _speedLabel(double speed) {
    if (speed == speed.roundToDouble()) {
      return '${speed.toInt()}x';
    }
    return '${speed}x';
  }
}

class _SubtitleIconButton extends StatelessWidget {
  const _SubtitleIconButton({
    required this.setup,
    required this.onPick,
    required this.onToggle,
    required this.onOpenSettings,
  });

  final PlayerSetupState setup;
  final VoidCallback onPick;
  final VoidCallback onToggle;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final hasFile = setup.hasSubtitleFile;
    final enabled = setup.subtitlesEnabled && hasFile;
    final fileHint = setup.subtitleFileName;

    return IconButton(
      onPressed: hasFile ? onToggle : onPick,
      onLongPress: onOpenSettings,
      tooltip: hasFile
          ? (enabled
                ? '${AppStrings.playerSubtitlesOn}${fileHint != null ? ' · $fileHint' : ''}'
                : '${AppStrings.playerSubtitlesOff}${fileHint != null ? ' · $fileHint' : ''}')
          : AppStrings.playerPickSubtitle,
      icon: Icon(
        enabled ? Icons.closed_caption : Icons.closed_caption_off_outlined,
        color: hasFile && enabled ? Colors.white : Colors.white60,
        size: 20,
      ),
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.all(6),
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
    );
  }
}

class _SpeedChip extends StatelessWidget {
  const _SpeedChip({
    required this.label,
    required this.onSelected,
    required this.currentSpeed,
  });

  final String label;
  final ValueChanged<double> onSelected;
  final double currentSpeed;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<double>(
      tooltip: AppStrings.playerPlaybackSpeed,
      padding: EdgeInsets.zero,
      initialValue: currentSpeed,
      onSelected: onSelected,
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: Container(
        constraints: const BoxConstraints(minWidth: 32, minHeight: 26),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
      ),
      itemBuilder: (context) => [
        for (final speed in PlayerPlaybackControls._speedOptions)
          PopupMenuItem(
            value: speed,
            child: Text(PlayerPlaybackControls._speedLabel(speed)),
          ),
      ],
    );
  }
}

/// Floating snackbar above player controls and bottom navigation.
void showPlayerFloatingSnackBar(
  BuildContext context,
  String message, {
  Color? backgroundColor,
}) {
  final media = MediaQuery.of(context);
  final bottomMargin =
      media.viewPadding.bottom + kBottomNavigationBarHeight + 88;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.fromLTRB(16, 0, 16, bottomMargin),
      backgroundColor: backgroundColor,
    ),
  );
}
