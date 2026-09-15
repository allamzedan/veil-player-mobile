import 'dart:async';

import 'package:flutter/material.dart';
import 'package:veil_mobile/features/player/domain/next_video_suggestion.dart';
import 'package:veil_mobile/shared/constants/app_strings.dart';

/// End-of-video overlay with replay, next suggestion, and monetization placeholder.
class PlayerEndScreenOverlay extends StatefulWidget {
  const PlayerEndScreenOverlay({
    super.key,
    required this.nextVideo,
    required this.autoplayEnabled,
    required this.onReplay,
    required this.onPlayNext,
    required this.onChooseVideo,
    required this.onDismiss,
  });

  final NextVideoSuggestion? nextVideo;
  final bool autoplayEnabled;
  final VoidCallback onReplay;
  final VoidCallback onPlayNext;
  final VoidCallback onChooseVideo;
  final VoidCallback onDismiss;

  static const Duration countdownDuration = Duration(seconds: 5);

  @override
  State<PlayerEndScreenOverlay> createState() => _PlayerEndScreenOverlayState();
}

class _PlayerEndScreenOverlayState extends State<PlayerEndScreenOverlay> {
  Timer? _timer;
  int _secondsLeft = PlayerEndScreenOverlay.countdownDuration.inSeconds;
  bool _countdownActive = false;

  @override
  void initState() {
    super.initState();
    if (widget.autoplayEnabled && widget.nextVideo != null) {
      _startCountdown();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _countdownActive = true;
    _secondsLeft = PlayerEndScreenOverlay.countdownDuration.inSeconds;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsLeft <= 1) {
        timer.cancel();
        widget.onPlayNext();
        return;
      }
      setState(() => _secondsLeft -= 1);
    });
  }

  void _cancelCountdown() {
    _timer?.cancel();
    _countdownActive = false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final next = widget.nextVideo;

    return Material(
      color: Colors.black.withValues(alpha: 0.82),
      child: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                onPressed: widget.onDismiss,
                icon: const Icon(Icons.close, color: Colors.white70),
              ),
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (next != null) ...[
                        Text(
                          AppStrings.playerEndScreenTitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          next.filename,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 20),
                        if (_countdownActive)
                          _CountdownBadge(secondsLeft: _secondsLeft),
                        const SizedBox(height: 24),
                      ],
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          OutlinedButton(
                            onPressed: () {
                              _cancelCountdown();
                              widget.onReplay();
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white38),
                            ),
                            child: Text(AppStrings.playerReplay),
                          ),
                          if (next != null)
                            FilledButton(
                              onPressed: () {
                                _cancelCountdown();
                                widget.onPlayNext();
                              },
                              child: Text(AppStrings.playerPlayNext),
                            ),
                          TextButton(
                            onPressed: () {
                              _cancelCountdown();
                              widget.onChooseVideo();
                            },
                            child: Text(AppStrings.playerChooseVideo),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      // Structural placeholder for future monetization — no ads in beta.
                      SizedBox(
                        height: 48,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              ' ',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white24,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountdownBadge extends StatelessWidget {
  const _CountdownBadge({required this.secondsLeft});

  final int secondsLeft;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 72,
          height: 72,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: secondsLeft / PlayerEndScreenOverlay.countdownDuration.inSeconds,
                strokeWidth: 3,
                color: Theme.of(context).colorScheme.primary,
                backgroundColor: Colors.white24,
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white.withValues(alpha: 0.92),
                    size: 22,
                  ),
                  Text(
                    '$secondsLeft',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.playerEndCountdown(secondsLeft),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}
