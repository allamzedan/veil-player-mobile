import 'package:flutter/material.dart';

/// Consistent bottom sheet shell: scroll-safe, SafeArea, max height cap.
abstract final class AppBottomSheet {
  static const double defaultMaxHeightFactor = 0.85;

  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    double maxHeightFactor = defaultMaxHeightFactor,
    bool scrollable = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      builder: (sheetContext) {
        final maxHeight =
            MediaQuery.sizeOf(sheetContext).height * maxHeightFactor;
        final viewInsets = MediaQuery.viewInsetsOf(sheetContext).bottom;
        final bottomPadding =
            MediaQuery.viewPaddingOf(sheetContext).bottom + 16;

        final child = builder(sheetContext);

        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: Padding(
              padding: EdgeInsets.only(bottom: viewInsets),
              child: scrollable
                  ? SingleChildScrollView(
                      padding: EdgeInsets.only(bottom: bottomPadding),
                      child: child,
                    )
                  : Padding(
                      padding: EdgeInsets.only(bottom: bottomPadding),
                      child: child,
                    ),
            ),
          ),
        );
      },
    );
  }
}
