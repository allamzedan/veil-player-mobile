import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:veil_mobile/app/incoming_file_classifier.dart';
import 'package:veil_mobile/app/router.dart';
import 'package:veil_mobile/core/tracks/track_summary.dart';
import 'package:veil_mobile/features/player/application/player_setup_controller.dart';
import 'package:veil_mobile/features/track_builder/application/track_builder_controller.dart';
import 'package:veil_mobile/features/tracks/presentation/track_preview_dialog.dart';
import 'package:veil_mobile/platform/android_open_intent.dart';
import 'package:veil_mobile/shared/constants/app_strings.dart';
import 'package:veil_mobile/shared/utils/video_file_limits.dart';
import 'package:veil_mobile/shared/widgets/app_snackbar.dart';

final openIntentHandlerProvider = Provider<OpenIntentHandler>(
  OpenIntentHandler.new,
);

/// Routes Android ACTION_VIEW intents into Player or Track Builder.
class OpenIntentHandler {
  OpenIntentHandler(this._ref);

  final Ref _ref;
  StreamSubscription<OpenIntentPayload>? _subscription;
  bool _initialized = false;
  bool _handling = false;

  Future<void> initialize(BuildContext context) async {
    if (_initialized) {
      return;
    }
    _initialized = true;

    final initial = await getInitialAndroidOpenIntent();
    if (initial != null) {
      if (!context.mounted) {
        return;
      }
      await _handlePayload(context, initial);
    }

    _subscription ??= watchAndroidOpenIntents().listen((payload) async {
      if (!context.mounted) {
        return;
      }
      await _handlePayload(context, payload);
    });
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _initialized = false;
  }

  Future<void> _handlePayload(
    BuildContext context,
    OpenIntentPayload payload,
  ) async {
    if (_handling || payload.uri.isEmpty) {
      return;
    }

    _handling = true;
    try {
      final filename = _resolveFilename(payload.displayName, payload.uri);
      final kind = IncomingFileClassifier.classify(
        filename: filename,
        mimeType: payload.mimeType,
      );

      if (kind == IncomingFileKind.video) {
        final size = await queryAndroidOpenableSize(payload.uri);
        if (size != null && !VideoFileLimits.isWithinLimit(size)) {
          if (context.mounted) {
            _showMessage(
              context,
              AppStrings.playerVideoTooLarge(size),
              isError: true,
            );
          }
          return;
        }
      }

      final path = await resolveAndroidOpenablePath(payload.uri);
      if (!context.mounted) {
        return;
      }
      if (path == null || path.isEmpty) {
        _showMessage(context, AppStrings.openIntentFileUnavailable);
        return;
      }

      final resolvedFilename = _resolveFilename(payload.displayName, path);

      switch (kind) {
        case IncomingFileKind.video:
          await _openVideo(context, path: path, filename: resolvedFilename);
        case IncomingFileKind.track:
          await _openTrack(context, path: path, filename: resolvedFilename);
        case IncomingFileKind.unsupported:
          _showMessage(context, AppStrings.openIntentUnsupportedFile(resolvedFilename));
      }
    } on Object {
      if (context.mounted) {
        _showMessage(
          context,
          AppStrings.openIntentUnexpectedError,
          isError: true,
        );
      }
    } finally {
      _handling = false;
    }
  }

  Future<void> _openVideo(
    BuildContext context, {
    required String path,
    required String filename,
  }) async {
    if (context.mounted) {
      context.go(AppRoutes.player);
    }

    final player = _ref.read(playerSetupControllerProvider.notifier);
    final error = await player.openVideoFromPath(
      path: path,
      filename: filename,
    );
    if (!context.mounted) {
      return;
    }
    if (error != null) {
      _showMessage(context, error, isError: true);
    }
  }

  Future<void> _openTrack(
    BuildContext context, {
    required String path,
    required String filename,
  }) async {
    final track = await loadTrackFromPathForPreview(path);
    if (!context.mounted) {
      return;
    }
    if (track == null) {
      _showMessage(context, AppStrings.playerTrackLoadError, isError: true);
      return;
    }

    final load = await TrackPreviewDialog.show(context: context, track: track);
    if (!context.mounted || load != true) {
      return;
    }

    final setup = _ref.read(playerSetupControllerProvider);
    final player = _ref.read(playerSetupControllerProvider.notifier);

    if (setup.isVideoReady) {
      final error = await player.loadTrackFromPath(
        path: path,
        filename: filename,
      );
      if (!context.mounted) {
        return;
      }
      if (error != null) {
        _showMessage(context, error, isError: true);
        return;
      }
      context.go(AppRoutes.player);
      return;
    }

    final builder = _ref.read(trackBuilderControllerProvider.notifier);
    final result = await builder.importFromPath(path);
    if (!context.mounted) {
      return;
    }
    if (!result.success) {
      _showMessage(context, result.message, isError: true);
      return;
    }
    context.go(AppRoutes.trackBuilder);
  }

  void _showMessage(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    showAppSnackBar(
      context,
      message,
      isError: isError,
      abovePlayerControls: true,
    );
  }

  String _resolveFilename(String? displayName, String path) {
    if (displayName != null && displayName.trim().isNotEmpty) {
      return displayName.trim();
    }
    final separator = path.contains('\\') ? '\\' : '/';
    return path.split(separator).last;
  }
}
