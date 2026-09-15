import 'dart:async';

import 'package:flutter/material.dart';
import 'package:veil_mobile/features/player/presentation/widgets/player_gesture_classifier.dart';
import 'package:veil_mobile/shared/constants/app_strings.dart';
import 'package:veil_mobile/shared/utils/veil_duration_format.dart';
import 'package:video_player/video_player.dart';

/// Player gesture layer: seek, scrub, speed boost, volume, and brightness.
class PlayerGestureOverlay extends StatefulWidget {
  const PlayerGestureOverlay({
    super.key,
    required this.enabled,
    required this.controller,
    required this.playbackSpeed,
    required this.volume,
    required this.brightness,
    required this.onSeekTo,
    required this.onSeekRelative,
    required this.onSetPlaybackSpeed,
    required this.onVolumeChanged,
    required this.onBrightnessChanged,
    this.onSingleTap,
    required this.child,
  });

  final bool enabled;
  final VideoPlayerController controller;
  final double playbackSpeed;
  final double volume;
  final double brightness;
  final Future<void> Function(Duration position) onSeekTo;
  final Future<void> Function(Duration offset) onSeekRelative;
  final Future<void> Function(double speed) onSetPlaybackSpeed;
  final ValueChanged<double> onVolumeChanged;
  final ValueChanged<double> onBrightnessChanged;
  final VoidCallback? onSingleTap;
  final Widget child;

  static const double speedBoostRate = 2.0;
  static const Duration overlayFadeDuration = Duration(milliseconds: 700);
  static const Duration doubleTapWindow = Duration(milliseconds: 280);
  static const Duration longPressDelay = Duration(milliseconds: 400);
  static const double touchSlop = PlayerGestureClassifier.touchSlop;

  @override
  State<PlayerGestureOverlay> createState() => _PlayerGestureOverlayState();
}

enum _GesturePhase {
  idle,
  pending,
  scrubbing,
  longPress,
  volumeAdjust,
  brightnessAdjust,
}

enum _OverlayKind {
  none,
  seekBack,
  seekForward,
  speedBoost,
  scrub,
  volume,
  brightness,
}

class _PlayerGestureOverlayState extends State<PlayerGestureOverlay> {
  _GesturePhase _phase = _GesturePhase.idle;
  Timer? _longPressTimer;
  Timer? _singleTapTimer;
  Timer? _overlayTimer;

  Offset? _pointerDown;
  int? _scrubStartMs;
  int? _scrubPreviewMs;
  double? _speedBeforeBoost;
  double? _levelAdjustStart;

  DateTime? _lastTapTime;
  bool _lastTapWasLeft = false;
  double _layoutWidth = 1;
  double _layoutHeight = 1;

  _OverlayKind _overlayKind = _OverlayKind.none;
  String? _scrubOverlayText;
  String? _levelOverlayText;

  @override
  void didUpdateWidget(covariant PlayerGestureOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.enabled && widget.enabled) {
      _cancelTimers();
      _phase = _GesturePhase.idle;
      _pointerDown = null;
      _lastTapTime = null;
    }
  }

  @override
  void dispose() {
    _cancelTimers();
    super.dispose();
  }

  void _cancelTimers() {
    _longPressTimer?.cancel();
    _singleTapTimer?.cancel();
    _overlayTimer?.cancel();
    _longPressTimer = null;
    _singleTapTimer = null;
    _overlayTimer = null;
  }

  void _scheduleOverlayHide() {
    _overlayTimer?.cancel();
    _overlayTimer = Timer(PlayerGestureOverlay.overlayFadeDuration, () {
      if (mounted) {
        setState(() {
          _overlayKind = _OverlayKind.none;
          _scrubOverlayText = null;
          _levelOverlayText = null;
        });
      }
    });
  }

  void _showOverlay(
    _OverlayKind kind, {
    String? scrubText,
    String? levelText,
    bool autoHide = true,
  }) {
    setState(() {
      _overlayKind = kind;
      _scrubOverlayText = scrubText;
      _levelOverlayText = levelText;
    });
    if (autoHide && kind != _OverlayKind.scrub) {
      _scheduleOverlayHide();
    } else if (kind == _OverlayKind.scrub) {
      _overlayTimer?.cancel();
    }
  }

  void _hideOverlay() {
    _overlayTimer?.cancel();
    if (_overlayKind != _OverlayKind.none ||
        _scrubOverlayText != null ||
        _levelOverlayText != null) {
      setState(() {
        _overlayKind = _OverlayKind.none;
        _scrubOverlayText = null;
        _levelOverlayText = null;
      });
    }
  }

  void _onPointerDown(PointerDownEvent event) {
    if (!widget.enabled) {
      return;
    }

    _cancelTimers();
    _phase = _GesturePhase.pending;
    _pointerDown = event.localPosition;
    _scrubStartMs = null;
    _scrubPreviewMs = null;
    _levelAdjustStart = null;

    _longPressTimer = Timer(PlayerGestureOverlay.longPressDelay, () {
      if (!mounted || _phase != _GesturePhase.pending) {
        return;
      }
      _startSpeedBoost();
    });
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (!widget.enabled || _pointerDown == null) {
      return;
    }

    final delta = event.localPosition - _pointerDown!;

    if (_phase == _GesturePhase.pending) {
      final kind = PlayerGestureClassifier.classify(
        deltaX: delta.dx,
        deltaY: delta.dy,
        localX: _pointerDown!.dx,
        layoutWidth: _layoutWidth,
      );
      switch (kind) {
        case PlayerGestureDragKind.horizontal:
          _longPressTimer?.cancel();
          _beginScrub();
        case PlayerGestureDragKind.verticalVolume:
          _longPressTimer?.cancel();
          _beginVolumeAdjust();
          _updateVolumeAdjust(delta.dy);
        case PlayerGestureDragKind.verticalBrightness:
          _longPressTimer?.cancel();
          _beginBrightnessAdjust();
          _updateBrightnessAdjust(delta.dy);
        case PlayerGestureDragKind.none:
          break;
      }
      return;
    }

    switch (_phase) {
      case _GesturePhase.scrubbing:
        _updateScrubPreview(delta.dx);
      case _GesturePhase.volumeAdjust:
        _updateVolumeAdjust(delta.dy);
      case _GesturePhase.brightnessAdjust:
        _updateBrightnessAdjust(delta.dy);
      case _GesturePhase.idle:
      case _GesturePhase.pending:
      case _GesturePhase.longPress:
        break;
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    if (!widget.enabled) {
      return;
    }

    switch (_phase) {
      case _GesturePhase.longPress:
        unawaited(_endSpeedBoost());
      case _GesturePhase.scrubbing:
        unawaited(_commitScrub());
      case _GesturePhase.volumeAdjust:
      case _GesturePhase.brightnessAdjust:
        _scheduleOverlayHide();
      case _GesturePhase.pending:
        _handleTapEnd(event.localPosition);
      case _GesturePhase.idle:
        break;
    }

    _phase = _GesturePhase.idle;
    _pointerDown = null;
    _levelAdjustStart = null;
    _longPressTimer?.cancel();
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (_phase == _GesturePhase.longPress) {
      unawaited(_endSpeedBoost());
    } else if (_phase == _GesturePhase.scrubbing) {
      _hideOverlay();
    } else if (_phase == _GesturePhase.volumeAdjust ||
        _phase == _GesturePhase.brightnessAdjust) {
      _scheduleOverlayHide();
    }
    _phase = _GesturePhase.idle;
    _pointerDown = null;
    _levelAdjustStart = null;
    _longPressTimer?.cancel();
  }

  void _beginScrub() {
    final value = widget.controller.value;
    if (!value.isInitialized) {
      return;
    }

    _phase = _GesturePhase.scrubbing;
    _scrubStartMs = value.position.inMilliseconds;
    _scrubPreviewMs = _scrubStartMs;
    _updateScrubOverlay();
  }

  void _beginVolumeAdjust() {
    _phase = _GesturePhase.volumeAdjust;
    _levelAdjustStart = widget.volume;
  }

  void _beginBrightnessAdjust() {
    _phase = _GesturePhase.brightnessAdjust;
    _levelAdjustStart = widget.brightness;
  }

  void _updateVolumeAdjust(double deltaY) {
    final start = _levelAdjustStart ?? widget.volume;
    final level = PlayerGestureClassifier.levelFromVerticalDrag(
      startLevel: start,
      deltaY: deltaY,
      layoutHeight: _layoutHeight,
    );
    widget.onVolumeChanged(level);
    _showOverlay(
      _OverlayKind.volume,
      levelText: AppStrings.playerVolumeOverlay(
        PlayerGestureClassifier.levelPercent(level),
      ),
    );
  }

  void _updateBrightnessAdjust(double deltaY) {
    final start = _levelAdjustStart ?? widget.brightness;
    final level = PlayerGestureClassifier.levelFromVerticalDrag(
      startLevel: start,
      deltaY: deltaY,
      layoutHeight: _layoutHeight,
    );
    widget.onBrightnessChanged(level);
    _showOverlay(
      _OverlayKind.brightness,
      levelText: AppStrings.playerBrightnessOverlay(
        PlayerGestureClassifier.levelPercent(level),
      ),
    );
  }

  void _updateScrubPreview(double deltaX) {
    final value = widget.controller.value;
    if (!value.isInitialized || _scrubStartMs == null) {
      return;
    }

    final width = _layoutWidth;
    final durationMs = value.duration.inMilliseconds;
    if (durationMs <= 0 || width <= 0) {
      return;
    }

    final deltaMs = (deltaX / width * durationMs).round();
    _scrubPreviewMs = (_scrubStartMs! + deltaMs).clamp(0, durationMs);
    _updateScrubOverlay();
  }

  void _updateScrubOverlay() {
    final value = widget.controller.value;
    final previewMs = _scrubPreviewMs;
    if (previewMs == null || !value.isInitialized) {
      return;
    }

    final preview = VeilDurationFormat.format(
      Duration(milliseconds: previewMs),
    );
    final duration = VeilDurationFormat.format(value.duration);
    setState(() {
      _overlayKind = _OverlayKind.scrub;
      _scrubOverlayText = '$preview / $duration';
    });
  }

  Future<void> _commitScrub() async {
    final previewMs = _scrubPreviewMs;
    _hideOverlay();
    if (previewMs == null) {
      return;
    }
    await widget.onSeekTo(Duration(milliseconds: previewMs));
  }

  Future<void> _startSpeedBoost() async {
    _phase = _GesturePhase.longPress;
    _speedBeforeBoost = widget.playbackSpeed;
    _showOverlay(_OverlayKind.speedBoost);
    await widget.onSetPlaybackSpeed(PlayerGestureOverlay.speedBoostRate);
  }

  Future<void> _endSpeedBoost() async {
    _hideOverlay();
    final restore = _speedBeforeBoost ?? widget.playbackSpeed;
    _speedBeforeBoost = null;
    if (restore != PlayerGestureOverlay.speedBoostRate) {
      await widget.onSetPlaybackSpeed(restore);
    } else {
      await widget.onSetPlaybackSpeed(1.0);
    }
  }

  void _handleTapEnd(Offset localPosition) {
    final down = _pointerDown;
    if (down == null) {
      return;
    }

    final movement = (localPosition - down).distance;
    if (movement > PlayerGestureOverlay.touchSlop) {
      return;
    }

    final width = _layoutWidth;
    final isLeft = localPosition.dx < width / 2;
    final now = DateTime.now();

    if (_lastTapTime != null &&
        now.difference(_lastTapTime!) <= PlayerGestureOverlay.doubleTapWindow &&
        _lastTapWasLeft == isLeft) {
      _singleTapTimer?.cancel();
      _lastTapTime = null;
      if (isLeft) {
        unawaited(widget.onSeekRelative(const Duration(seconds: -10)));
        _showOverlay(_OverlayKind.seekBack);
      } else {
        unawaited(widget.onSeekRelative(const Duration(seconds: 10)));
        _showOverlay(_OverlayKind.seekForward);
      }
      return;
    }

    _lastTapTime = now;
    _lastTapWasLeft = isLeft;

    _singleTapTimer?.cancel();
    _singleTapTimer = Timer(PlayerGestureOverlay.doubleTapWindow, () {
      if (!mounted) {
        return;
      }
      _lastTapTime = null;
      widget.onSingleTap?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _layoutWidth = constraints.maxWidth;
        _layoutHeight = constraints.maxHeight;

        return Stack(
          fit: StackFit.expand,
          children: [
            widget.child,
            if (widget.enabled)
              Positioned.fill(
                child: Listener(
                  behavior: HitTestBehavior.translucent,
                  onPointerDown: _onPointerDown,
                  onPointerMove: _onPointerMove,
                  onPointerUp: _onPointerUp,
                  onPointerCancel: _onPointerCancel,
                ),
              ),
            if (_overlayKind != _OverlayKind.none)
              _GestureOverlayBubble(
                kind: _overlayKind,
                width: constraints.maxWidth,
                scrubText: _scrubOverlayText,
                levelText: _levelOverlayText,
              ),
          ],
        );
      },
    );
  }
}

class _GestureOverlayBubble extends StatelessWidget {
  const _GestureOverlayBubble({
    required this.kind,
    required this.width,
    this.scrubText,
    this.levelText,
  });

  final _OverlayKind kind;
  final double width;
  final String? scrubText;
  final String? levelText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final text = switch (kind) {
      _OverlayKind.seekBack => AppStrings.playerSeekBackOverlay,
      _OverlayKind.seekForward => AppStrings.playerSeekForwardOverlay,
      _OverlayKind.speedBoost => AppStrings.playerSpeedBoostOverlay,
      _OverlayKind.scrub => scrubText ?? '',
      _OverlayKind.volume => levelText ?? '',
      _OverlayKind.brightness => levelText ?? '',
      _OverlayKind.none => '',
    };

    final alignment = switch (kind) {
      _OverlayKind.seekBack => AlignmentDirectional.centerStart,
      _OverlayKind.seekForward => AlignmentDirectional.centerEnd,
      _OverlayKind.brightness => AlignmentDirectional.centerStart,
      _OverlayKind.volume => AlignmentDirectional.centerEnd,
      _ => Alignment.center,
    };

    final padding = switch (kind) {
      _OverlayKind.seekBack => const EdgeInsetsDirectional.only(start: 48),
      _OverlayKind.seekForward => const EdgeInsetsDirectional.only(end: 48),
      _OverlayKind.brightness => const EdgeInsetsDirectional.only(start: 48),
      _OverlayKind.volume => const EdgeInsetsDirectional.only(end: 48),
      _ => EdgeInsets.zero,
    };

    return IgnorePointer(
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: padding,
          child: AnimatedOpacity(
            opacity: 1,
            duration: const Duration(milliseconds: 120),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.62),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Text(
                  text,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
