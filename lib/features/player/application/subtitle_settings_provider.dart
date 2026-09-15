import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veil_mobile/core/storage/storage_providers.dart';
import 'package:veil_mobile/core/subtitles/subtitle_settings.dart';
import 'package:veil_mobile/features/player/application/player_setup_controller.dart';

final subtitleSettingsProvider =
    NotifierProvider<SubtitleSettingsController, SubtitleSettings>(
      SubtitleSettingsController.new,
    );

class SubtitleSettingsController extends Notifier<SubtitleSettings> {
  @override
  SubtitleSettings build() {
    final stored = ref
        .read(sharedPreferencesProvider)
        .getString(SubtitleSettings.storageKey);
    return SubtitleSettings.fromStorage(stored);
  }

  Future<void> updateSettings(SubtitleSettings settings) async {
    state = settings;
    await ref
        .read(sharedPreferencesProvider)
        .setString(
          SubtitleSettings.storageKey,
          jsonEncode(settings.toJson()),
        );
    ref
        .read(playerSetupControllerProvider.notifier)
        .resyncSubtitleAtCurrentPosition();
  }

  Future<void> adjustDelay(int deltaMs) {
    return updateSettings(state.copyWith(delayMs: state.delayMs + deltaMs));
  }

  Future<void> resetDelay() {
    return updateSettings(state.copyWith(delayMs: 0));
  }
}
