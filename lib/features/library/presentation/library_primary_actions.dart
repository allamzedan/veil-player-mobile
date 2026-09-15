import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:veil_mobile/app/router.dart';
import 'package:veil_mobile/features/player/application/player_setup_controller.dart';
import 'package:veil_mobile/shared/constants/app_strings.dart';

/// Compact primary actions at the top of the library screen.
class LibraryPrimaryActions extends ConsumerWidget {
  const LibraryPrimaryActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: FilledButton.icon(
        onPressed: () => _openVideo(context, ref),
        icon: const Icon(Icons.play_arrow_outlined, size: 20),
        label: Text(AppStrings.libraryOpenVideoAction),
      ),
    );
  }

  Future<void> _openVideo(BuildContext context, WidgetRef ref) async {
    final ctrl = ref.read(playerSetupControllerProvider.notifier);
    await ctrl.pickVideo();
    if (!context.mounted) {
      return;
    }
    if (ref.read(playerSetupControllerProvider).hasVideoSelection) {
      context.go(AppRoutes.player);
    }
  }
}
