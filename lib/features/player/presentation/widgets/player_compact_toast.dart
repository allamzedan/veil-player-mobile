import 'dart:async';

import 'package:flutter/material.dart';

/// Short-lived compact toast above the player — does not cover video center.
void showPlayerCompactToast(
  BuildContext context, {
  required String message,
  String? secondary,
  Duration duration = const Duration(milliseconds: 2200),
}) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) {
    return;
  }

  final theme = Theme.of(context);
  final top = MediaQuery.paddingOf(context).top + 10;
  late OverlayEntry entry;
  Timer? timer;

  entry = OverlayEntry(
    builder: (context) => Positioned(
      top: top,
      left: 48,
      right: 48,
      child: Material(
        color: theme.colorScheme.inverseSurface.withValues(alpha: 0.94),
        elevation: 3,
        shadowColor: Colors.black45,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 16,
                color: theme.colorScheme.onInverseSurface,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onInverseSurface,
                      ),
                    ),
                    if (secondary != null && secondary.isNotEmpty)
                      Text(
                        secondary,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onInverseSurface
                              .withValues(alpha: 0.82),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  overlay.insert(entry);
  timer = Timer(duration, () {
    if (entry.mounted) {
      entry.remove();
    }
    timer?.cancel();
  });
}
