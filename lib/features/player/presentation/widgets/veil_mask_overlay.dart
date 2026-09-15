import 'package:flutter/material.dart';
import 'package:veil_mobile/core/veil/veil_runtime_evaluator.dart';
import 'package:veil_mobile/core/veil/veil_segment.dart';

// TODO(veil-mobile): draggable/resizable mask handles over video.

/// Solid mask rectangles aligned to the native video frame.
class VeilMaskOverlay extends StatelessWidget {
  const VeilMaskOverlay({super.key, required this.segments});

  final List<VeilSegment> segments;

  @override
  Widget build(BuildContext context) {
    if (segments.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        return Stack(
          fit: StackFit.expand,
          children: [
            for (final segment in segments)
              _MaskRectBox(
                rect: VeilMaskRect.fromSegment(segment),
                colorValue: VeilMaskStyle.colorValueFromStyle(segment.style),
                opacity: VeilMaskStyle.opacityFromStyle(segment.style),
                layoutWidth: width,
                layoutHeight: height,
              ),
          ],
        );
      },
    );
  }
}

class _MaskRectBox extends StatelessWidget {
  const _MaskRectBox({
    required this.rect,
    required this.colorValue,
    required this.opacity,
    required this.layoutWidth,
    required this.layoutHeight,
  });

  final VeilMaskRect rect;
  final int colorValue;
  final double opacity;
  final double layoutWidth;
  final double layoutHeight;

  @override
  Widget build(BuildContext context) {
    final left = layoutWidth * rect.xPercent / 100;
    final top = layoutHeight * rect.yPercent / 100;
    final boxWidth = layoutWidth * rect.widthPercent / 100;
    final boxHeight = layoutHeight * rect.heightPercent / 100;

    return Positioned(
      left: left,
      top: top,
      width: boxWidth,
      height: boxHeight,
      child: IgnorePointer(
        child: ColoredBox(color: Color(colorValue).withValues(alpha: opacity)),
      ),
    );
  }
}
