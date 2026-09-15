import 'package:flutter/material.dart';

/// Neutral in-app brand placeholder until a final logo asset exists.
///
/// Uses a Material icon — not the Flutter logo and not generated artwork.
class AppBrandMark extends StatelessWidget {
  const AppBrandMark({super.key, this.size = 32});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.play_circle_outline,
      size: size,
      color: Theme.of(context).colorScheme.primary,
    );
  }
}
