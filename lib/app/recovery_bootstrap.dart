import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:veil_mobile/app/router.dart';
import 'package:veil_mobile/core/recovery/recovery_draft.dart';
import 'package:veil_mobile/core/recovery/recovery_provider.dart';
import 'package:veil_mobile/shared/constants/app_strings.dart';

/// Observes app lifecycle for forced autosave and shows recovery prompt on launch.
class RecoveryBootstrap extends ConsumerStatefulWidget {
  const RecoveryBootstrap({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<RecoveryBootstrap> createState() => _RecoveryBootstrapState();
}

class _RecoveryBootstrapState extends ConsumerState<RecoveryBootstrap>
    with WidgetsBindingObserver {
  bool _promptShownThisSession = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      unawaited(_maybeShowRecoveryPrompt());
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      unawaited(
        ref.read(recoveryControllerProvider.notifier).forceSaveAllDirty(),
      );
    }
  }

  Future<void> _maybeShowRecoveryPrompt() async {
    if (_promptShownThisSession || !mounted) {
      return;
    }

    final recovery = ref.read(recoveryControllerProvider);
    final draft = recovery.newestDirtyDraft;
    if (draft == null) {
      return;
    }

    _promptShownThisSession = true;
    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        final dirtyCount = recovery.dirtyDrafts.length;
        return AlertDialog(
          title: Text(AppStrings.recoveryDraftFoundTitle),
          content: Text(
            dirtyCount > 1
                ? AppStrings.recoveryDraftFoundMultipleMessage
                : AppStrings.recoveryDraftFoundMessage(draft.trackTitle),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(AppStrings.recoveryDismiss),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _discardDraft(draft.source);
              },
              child: Text(AppStrings.recoveryDiscardDraft),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _restoreDraft(draft);
              },
              child: Text(AppStrings.recoveryRestore),
            ),
          ],
        );
      },
    );
  }

  Future<void> _restoreDraft(RecoveryDraft draft) async {
    final recovery = ref.read(recoveryControllerProvider.notifier);
    final success = await recovery.restoreDraft(draft);
    if (!mounted) {
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

    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.recoveryDraftRestored),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _discardDraft(RecoveryDraftSource source) async {
    await ref.read(recoveryControllerProvider.notifier).discardDraft(source);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.recoveryDraftDiscarded),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
