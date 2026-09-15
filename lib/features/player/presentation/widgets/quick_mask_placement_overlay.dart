import 'package:flutter/material.dart';
import 'package:veil_mobile/core/veil/veil_segment.dart';
import 'package:veil_mobile/features/player/presentation/widgets/mask_rect_resize.dart';

/// Editable mask rectangle expressed as percentages of the video frame.
class MaskRectPercents {
  const MaskRectPercents({
    required this.xPercent,
    required this.yPercent,
    required this.widthPercent,
    required this.heightPercent,
  });

  static const double minWidthPercent = 8;
  static const double minHeightPercent = 5;

  final double xPercent;
  final double yPercent;
  final double widthPercent;
  final double heightPercent;

  factory MaskRectPercents.fromMap(Map<String, dynamic> rect) {
    return MaskRectPercents(
      xPercent: _read(rect, 'xPercent', VeilSegment.defaultRect['xPercent']!),
      yPercent: _read(rect, 'yPercent', VeilSegment.defaultRect['yPercent']!),
      widthPercent: _read(
        rect,
        'widthPercent',
        VeilSegment.defaultRect['widthPercent']!,
      ),
      heightPercent: _read(
        rect,
        'heightPercent',
        VeilSegment.defaultRect['heightPercent']!,
      ),
    );
  }

  factory MaskRectPercents.defaults() =>
      MaskRectPercents.fromMap(VeilSegment.defaultRect);

  Map<String, dynamic> toMap() {
    return {
      'xPercent': _round(xPercent),
      'yPercent': _round(yPercent),
      'widthPercent': _round(widthPercent),
      'heightPercent': _round(heightPercent),
    };
  }

  static double _read(Map<String, dynamic> rect, String key, num fallback) {
    final value = rect[key];
    if (value is num) {
      return value.toDouble();
    }
    return fallback.toDouble();
  }

  static double _round(double value) =>
      double.parse(value.clamp(0, 100).toStringAsFixed(2));
}

/// Drag + four-corner resize editor sharing the video frame coordinate space.
class QuickMaskPlacementEditor extends StatefulWidget {
  const QuickMaskPlacementEditor({super.key, this.initialRect});

  final Map<String, dynamic>? initialRect;

  @override
  State<QuickMaskPlacementEditor> createState() =>
      QuickMaskPlacementEditorState();
}

class QuickMaskPlacementEditorState extends State<QuickMaskPlacementEditor> {
  static const double _handleTouchSize = 48;

  late MaskRectPercents _rect;
  double _frameWidth = 1;
  double _frameHeight = 1;

  Map<String, dynamic> get rectMap => _rect.toMap();

  @override
  void initState() {
    super.initState();
    _rect = widget.initialRect == null
        ? MaskRectPercents.defaults()
        : MaskRectPercents.fromMap(widget.initialRect!);
  }

  void _applyRect(MaskRectPercents next) {
    setState(() => _rect = next);
  }

  void _onDrag(DragUpdateDetails details) {
    if (_frameWidth <= 0 || _frameHeight <= 0) {
      return;
    }

    final dx = details.delta.dx / _frameWidth * 100;
    final dy = details.delta.dy / _frameHeight * 100;
    final x = (_rect.xPercent + dx)
        .clamp(0, 100 - _rect.widthPercent)
        .toDouble();
    final y = (_rect.yPercent + dy)
        .clamp(0, 100 - _rect.heightPercent)
        .toDouble();
    _applyRect(
      MaskRectPercents(
        xPercent: x,
        yPercent: y,
        widthPercent: _rect.widthPercent,
        heightPercent: _rect.heightPercent,
      ),
    );
  }

  void _onResizeCorner(MaskResizeCorner corner, DragUpdateDetails details) {
    if (_frameWidth <= 0 || _frameHeight <= 0) {
      return;
    }

    final dx = details.delta.dx / _frameWidth * 100;
    final dy = details.delta.dy / _frameHeight * 100;
    _applyRect(
      resizeMaskRectFromCorner(
        rect: _rect,
        corner: corner,
        deltaXPercent: dx,
        deltaYPercent: dy,
      ),
    );
  }

  Widget _cornerHandle(MaskResizeCorner corner, AlignmentGeometry alignment) {
    final theme = Theme.of(context);

    return Positioned.fill(
      child: Align(
        alignment: alignment,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanUpdate: (details) => _onResizeCorner(corner, details),
          child: SizedBox(
            width: _handleTouchSize,
            height: _handleTouchSize,
            child: Align(
              alignment: alignment,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  border: Border.all(
                    color: theme.colorScheme.onPrimary,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        _frameWidth = constraints.maxWidth;
        _frameHeight = constraints.maxHeight;

        final left = _rect.xPercent / 100 * _frameWidth;
        final top = _rect.yPercent / 100 * _frameHeight;
        final rectWidth = _rect.widthPercent / 100 * _frameWidth;
        final rectHeight = _rect.heightPercent / 100 * _frameHeight;

        return Stack(
          clipBehavior: Clip.none,
          fit: StackFit.expand,
          children: [
            Positioned(
              left: left,
              top: top,
              width: rectWidth,
              height: rectHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onPanUpdate: _onDrag,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.85),
                          border: Border.all(
                            color: theme.colorScheme.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  _cornerHandle(
                    MaskResizeCorner.topLeft,
                    AlignmentDirectional.topStart,
                  ),
                  _cornerHandle(
                    MaskResizeCorner.topRight,
                    AlignmentDirectional.topEnd,
                  ),
                  _cornerHandle(
                    MaskResizeCorner.bottomLeft,
                    AlignmentDirectional.bottomStart,
                  ),
                  _cornerHandle(
                    MaskResizeCorner.bottomRight,
                    AlignmentDirectional.bottomEnd,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
