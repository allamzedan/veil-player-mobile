import 'package:flutter/material.dart';
import 'package:veil_mobile/core/veil/veil_segment.dart';
import 'package:veil_mobile/features/player/presentation/widgets/quick_mask_placement_overlay.dart';
import 'package:veil_mobile/shared/constants/app_strings.dart';
import 'package:video_player/video_player.dart';

/// Fullscreen mask placement mode — owns the screen without player chrome.
class MaskPlacementScreen extends StatefulWidget {
  const MaskPlacementScreen({
    super.key,
    required this.controller,
    this.initialRect,
  });

  final VideoPlayerController controller;
  final Map<String, dynamic>? initialRect;

  /// Opens placement above the app shell (no bottom nav / player chrome).
  static Future<Map<String, dynamic>?> open(
    BuildContext context,
    VideoPlayerController controller, {
    Map<String, dynamic>? initialRect,
  }) {
    return Navigator.of(
      context,
      rootNavigator: true,
    ).push<Map<String, dynamic>>(
      PageRouteBuilder<Map<String, dynamic>>(
        opaque: true,
        fullscreenDialog: true,
        pageBuilder: (context, animation, secondaryAnimation) =>
            MaskPlacementScreen(
              controller: controller,
              initialRect: initialRect,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  State<MaskPlacementScreen> createState() => _MaskPlacementScreenState();
}

class _MaskPlacementScreenState extends State<MaskPlacementScreen> {
  final GlobalKey<QuickMaskPlacementEditorState> _editorKey =
      GlobalKey<QuickMaskPlacementEditorState>();

  void _cancel() {
    Navigator.of(context).pop();
  }

  void _confirm() {
    final rect =
        _editorKey.currentState?.rectMap ??
        Map<String, dynamic>.from(VeilSegment.defaultRect);
    Navigator.of(context).pop(rect);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = widget.controller;
    final videoSize = controller.value.size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(4, 4, 8, 0),
              child: Row(
                children: [
                  TextButton(
                    onPressed: _cancel,
                    child: Text(AppStrings.cancel),
                  ),
                  Expanded(
                    child: Text(
                      AppStrings.playerQuickMaskPlacementTitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  FilledButton(
                    onPressed: _confirm,
                    child: Text(AppStrings.playerQuickMaskConfirm),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Text(
                AppStrings.playerQuickMaskPlacementHint,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                ),
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final frameSize = _fitVideoFrame(
                    Size(constraints.maxWidth, constraints.maxHeight),
                    videoSize,
                  );

                  return Center(
                    child: SizedBox(
                      width: frameSize.width,
                      height: frameSize.height,
                      child: Stack(
                        fit: StackFit.expand,
                        clipBehavior: Clip.hardEdge,
                        children: [
                          VideoPlayer(controller),
                          QuickMaskPlacementEditor(
                            key: _editorKey,
                            initialRect: widget.initialRect,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fits [videoSize] inside [maxSize] preserving aspect ratio (no FittedBox).
Size _fitVideoFrame(Size maxSize, Size videoSize) {
  if (videoSize.width <= 0 || videoSize.height <= 0) {
    return maxSize;
  }

  final aspect = videoSize.width / videoSize.height;
  var width = maxSize.width;
  var height = width / aspect;
  if (height > maxSize.height) {
    height = maxSize.height;
    width = height * aspect;
  }
  return Size(width, height);
}
