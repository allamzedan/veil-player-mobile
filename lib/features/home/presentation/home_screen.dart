import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:veil_mobile/app/router.dart';
import 'package:veil_mobile/features/library/application/media_history_controller.dart';
import 'package:veil_mobile/features/player/application/player_setup_controller.dart';
import 'package:veil_mobile/shared/constants/app_strings.dart';
import 'package:veil_mobile/shared/widgets/app_snackbar.dart';
import 'package:veil_mobile/shared/widgets/app_brand_mark.dart';
import 'package:veil_mobile/shared/widgets/app_scaffold.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final historyAsync = ref.watch(mediaHistoryControllerProvider);

    return AppScaffold(
      title: AppStrings.homeTitle,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        children: [
          Center(
            child: Column(
              children: [
                const AppBrandMark(size: 48),
                const SizedBox(height: 12),
                Text(
                  AppStrings.appName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  AppStrings.homeDescription,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),
          historyAsync.maybeWhen(
            data: (history) {
              final session = history.lastSession;
              if (!history.hasLastSession || session == null) {
                return const SizedBox.shrink();
              }
              final videoName =
                  session.videoFilename ?? AppStrings.playerNoVideoSelected;
              return Column(
                children: [
                  _HomePrimaryButton(
                    label: AppStrings.continueLastSession,
                    subtitle: AppStrings.continueLastSessionSubtitle(videoName),
                    icon: Icons.play_arrow_rounded,
                    onTap: () => _resumeLastSession(context, ref),
                  ),
                  const SizedBox(height: 12),
                ],
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
          _HomePrimaryButton(
            label: AppStrings.openVideo,
            subtitle: AppStrings.openVideoSubtitle,
            icon: Icons.video_file_outlined,
            filled: historyAsync.maybeWhen(
              data: (history) => !history.hasLastSession,
              orElse: () => true,
            ),
            onTap: () => _openVideo(context, ref),
          ),
          const SizedBox(height: 28),
          _HomeSecondaryLink(
            label: AppStrings.openLibrary,
            icon: Icons.folder_open_outlined,
            onTap: () => context.go(AppRoutes.library),
          ),
          _HomeSecondaryLink(
            label: AppStrings.trackBuilderCard,
            icon: Icons.build_outlined,
            onTap: () => context.go(AppRoutes.trackBuilder),
          ),
        ],
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

  Future<void> _resumeLastSession(BuildContext context, WidgetRef ref) async {
    context.go(AppRoutes.player);
    final result = await ref
        .read(playerSetupControllerProvider.notifier)
        .resumeLastSession();
    await ref.read(mediaHistoryControllerProvider.notifier).refresh();
    if (!context.mounted) {
      return;
    }
    if (!result.success && result.message != null) {
      showAppSnackBar(
        context,
        result.message!,
        isError: true,
        abovePlayerControls: true,
      );
      return;
    }
    if (result.warning != null) {
      showAppSnackBar(context, result.warning!, abovePlayerControls: true);
    }
  }
}

class _HomePrimaryButton extends StatelessWidget {
  const _HomePrimaryButton({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.filled = false,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final child = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Icon(
            icon,
            size: 28,
            color: filled ? colorScheme.onPrimary : colorScheme.primary,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: filled ? colorScheme.onPrimary : null,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: filled
                        ? colorScheme.onPrimary.withValues(alpha: 0.82)
                        : colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: filled
                ? colorScheme.onPrimary.withValues(alpha: 0.8)
                : colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );

    if (filled) {
      return FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: child,
      );
    }

    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: child,
    );
  }
}

class _HomeSecondaryLink extends StatelessWidget {
  const _HomeSecondaryLink({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      style: TextButton.styleFrom(
        alignment: AlignmentDirectional.centerStart,
        padding: const EdgeInsets.symmetric(vertical: 10),
      ),
      icon: Icon(icon, size: 20),
      label: Text(label),
    );
  }
}
