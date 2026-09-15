import 'package:veil_mobile/features/player/presentation/widgets/quick_mask_placement_overlay.dart';

enum MaskResizeCorner { topLeft, topRight, bottomLeft, bottomRight }

/// Applies a corner drag delta to a percentage-based mask rect.
MaskRectPercents resizeMaskRectFromCorner({
  required MaskRectPercents rect,
  required MaskResizeCorner corner,
  required double deltaXPercent,
  required double deltaYPercent,
}) {
  switch (corner) {
    case MaskResizeCorner.bottomRight:
      return _resizeBottomRight(rect, deltaXPercent, deltaYPercent);
    case MaskResizeCorner.bottomLeft:
      return _resizeBottomLeft(rect, deltaXPercent, deltaYPercent);
    case MaskResizeCorner.topRight:
      return _resizeTopRight(rect, deltaXPercent, deltaYPercent);
    case MaskResizeCorner.topLeft:
      return _resizeTopLeft(rect, deltaXPercent, deltaYPercent);
  }
}

MaskRectPercents _resizeBottomRight(
  MaskRectPercents rect,
  double dx,
  double dy,
) {
  final width = (rect.widthPercent + dx)
      .clamp(MaskRectPercents.minWidthPercent, 100 - rect.xPercent)
      .toDouble();
  final height = (rect.heightPercent + dy)
      .clamp(MaskRectPercents.minHeightPercent, 100 - rect.yPercent)
      .toDouble();
  return MaskRectPercents(
    xPercent: rect.xPercent,
    yPercent: rect.yPercent,
    widthPercent: width,
    heightPercent: height,
  );
}

MaskRectPercents _resizeBottomLeft(
  MaskRectPercents rect,
  double dx,
  double dy,
) {
  final right = rect.xPercent + rect.widthPercent;
  var x = rect.xPercent + dx;
  var width = right - x;
  if (width < MaskRectPercents.minWidthPercent) {
    width = MaskRectPercents.minWidthPercent;
    x = right - width;
  }
  if (x < 0) {
    x = 0;
    width = right;
  }
  final height = (rect.heightPercent + dy)
      .clamp(MaskRectPercents.minHeightPercent, 100 - rect.yPercent)
      .toDouble();
  return MaskRectPercents(
    xPercent: x,
    yPercent: rect.yPercent,
    widthPercent: width,
    heightPercent: height,
  );
}

MaskRectPercents _resizeTopRight(
  MaskRectPercents rect,
  double dx,
  double dy,
) {
  final bottom = rect.yPercent + rect.heightPercent;
  var y = rect.yPercent + dy;
  var height = bottom - y;
  if (height < MaskRectPercents.minHeightPercent) {
    height = MaskRectPercents.minHeightPercent;
    y = bottom - height;
  }
  if (y < 0) {
    y = 0;
    height = bottom;
  }
  final width = (rect.widthPercent + dx)
      .clamp(MaskRectPercents.minWidthPercent, 100 - rect.xPercent)
      .toDouble();
  return MaskRectPercents(
    xPercent: rect.xPercent,
    yPercent: y,
    widthPercent: width,
    heightPercent: height,
  );
}

MaskRectPercents _resizeTopLeft(
  MaskRectPercents rect,
  double dx,
  double dy,
) {
  final right = rect.xPercent + rect.widthPercent;
  final bottom = rect.yPercent + rect.heightPercent;

  var x = rect.xPercent + dx;
  var width = right - x;
  if (width < MaskRectPercents.minWidthPercent) {
    width = MaskRectPercents.minWidthPercent;
    x = right - width;
  }
  if (x < 0) {
    x = 0;
    width = right;
  }

  var y = rect.yPercent + dy;
  var height = bottom - y;
  if (height < MaskRectPercents.minHeightPercent) {
    height = MaskRectPercents.minHeightPercent;
    y = bottom - height;
  }
  if (y < 0) {
    y = 0;
    height = bottom;
  }

  return MaskRectPercents(
    xPercent: x,
    yPercent: y,
    widthPercent: width,
    heightPercent: height,
  );
}
