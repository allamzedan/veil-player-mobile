import 'package:flutter/material.dart';
import 'package:veil_mobile/features/player/presentation/widgets/player_playback_controls.dart';

/// Shows a floating snackbar with consistent margins.
void showAppSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
  bool abovePlayerControls = false,
}) {
  if (abovePlayerControls) {
    showPlayerFloatingSnackBar(
      context,
      message,
      backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
    );
    return;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
    ),
  );
}
