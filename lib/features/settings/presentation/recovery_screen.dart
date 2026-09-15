import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:veil_mobile/app/router.dart';
import 'package:veil_mobile/core/recovery/recovery_draft.dart';
import 'package:veil_mobile/core/recovery/recovery_provider.dart';
import 'package:veil_mobile/shared/constants/app_strings.dart';
import 'package:veil_mobile/shared/widgets/app_scaffold.dart';

class RecoveryScreen extends ConsumerWidget {
  const RecoveryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recovery = ref.watch(recoveryControllerProvider);
    final theme = Theme.of(context);

    return AppScaffold(
      title: AppStrings.recoveryTitle,
      showBackButton: true,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (recovery.playerDraft == null &&
              recovery.trackBuilderDraft == null)
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  AppStrings.recoveryNoDrafts,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ),
          if (recovery.playerDraft != null) ...[
            _DraftCard(
              title: AppStrings.recoveryPlayerDraft,
              draft: recovery.playerDraft!,
              sourceLabel: AppStrings.recoverySourcePlayer,
              onRestore: () => _restore(context, ref, recovery.playerDraft!),
              onDiscard: () => _discard(context, ref, RecoveryDraftSource.player),
            ),
            const SizedBox(height: 16),
          ],
          if (recovery.trackBuilderDraft != null)
            _DraftCard(
              title: AppStrings.recoveryTrackBuilderDraft,
              draft: recovery.trackBuilderDraft!,
              sourceLabel: AppStrings.recoverySourceTrackBuilder,
              onRestore: () =>
                  _restore(context, ref, recovery.trackBuilderDraft!),
              onDiscard: () =>
                  _discard(context, ref, RecoveryDraftSource.trackBuilder),
            ),
        ],
      ),
    );
  }

  Future<void> _restore(
    BuildContext context,
    WidgetRef ref,
    RecoveryDraft draft,
  ) async {
    final success =
        await ref.read(recoveryControllerProvider.notifier).restoreDraft(draft);
    if (!context.mounted) {
      return;
    }
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.recoveryRestoreFailed),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final route = switch (draft.source) {
      RecoveryDraftSource.player => AppRoutes.player,
      RecoveryDraftSource.trackBuilder => AppRoutes.trackBuilder,
    };
    context.go(route);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.recoveryDraftRestored),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _discard(
    BuildContext context,
    WidgetRef ref,
    RecoveryDraftSource source,
  ) async {
    await ref.read(recoveryControllerProvider.notifier).discardDraft(source);
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.recoveryDraftDiscarded),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _DraftCard extends StatelessWidget {
  const _DraftCard({
    required this.title,
    required this.draft,
    required this.sourceLabel,
    required this.onRestore,
    required this.onDiscard,
  });

  final String title;
  final RecoveryDraft draft;
  final String sourceLabel;
  final VoidCallback onRestore;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final updated = MaterialLocalizations.of(
      context,
    ).formatShortDate(draft.updatedAt.toLocal());

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(draft.trackTitle, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 8),
            Text(
              '$sourceLabel · ${AppStrings.recoverySegmentCount}: '
              '${draft.segmentCount}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              '${AppStrings.recoveryUpdatedAt}: $updated',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (draft.isDirty) ...[
              const SizedBox(height: 4),
              Text(
                AppStrings.recoveryDirty,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                FilledButton(
                  onPressed: onRestore,
                  child: Text(AppStrings.recoveryRestore),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: onDiscard,
                  child: Text(AppStrings.recoveryDiscardDraft),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
