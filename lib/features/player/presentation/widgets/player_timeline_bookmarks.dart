import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:veil_mobile/core/veil/veil_segment.dart';
import 'package:veil_mobile/core/veil/bookmark_segments.dart';

/// Teal diamond bookmark indicators overlaid on the player seek bar.
class PlayerTimelineBookmarks extends StatelessWidget {
  const PlayerTimelineBookmarks({
    super.key,
    required this.bookmarks,
    required this.durationMs,
    required this.onTapBookmark,
    this.markerColor,
  });

  final List<VeilSegment> bookmarks;
  final int durationMs;
  final ValueChanged<VeilSegment> onTapBookmark;
  final Color? markerColor;

  static const Color _bookmarkTeal = Color(0xFF26A69A);

  @override
  Widget build(BuildContext context) {
    if (bookmarks.isEmpty || durationMs <= 0) {
      return const SizedBox.shrink();
    }

    final color = markerColor ?? _bookmarkTeal;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return SizedBox(
          height: 14,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              for (final bookmark in bookmarks)
                Positioned(
                  left: _markerLeft(
                    bookmark: bookmark,
                    trackWidth: width,
                    durationMs: durationMs,
                  ),
                  top: 2,
                  child: _BookmarkDiamondMarker(
                    color: color,
                    onTap: () => onTapBookmark(bookmark),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  static double _markerLeft({
    required VeilSegment bookmark,
    required double trackWidth,
    required int durationMs,
  }) {
    const markerWidth = 9.0;
    final fraction = BookmarkSegments.timelineFraction(
      positionMs: bookmark.pointMs,
      durationMs: durationMs,
    );
    final center = fraction * trackWidth;
    return (center - markerWidth / 2).clamp(0.0, trackWidth - markerWidth);
  }
}

class _BookmarkDiamondMarker extends StatelessWidget {
  const _BookmarkDiamondMarker({required this.color, required this.onTap});

  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Transform.rotate(
          angle: math.pi / 4,
          child: Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: Colors.white70, width: 1),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 2,
                  color: Colors.black45,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
