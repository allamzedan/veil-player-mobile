import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veil_mobile/core/storage/storage_providers.dart';
import 'package:veil_mobile/features/player/domain/player_playback_settings.dart';

final playerPlaybackSettingsProvider =
    NotifierProvider<PlayerPlaybackSettingsController, PlayerPlaybackSettings>(
      PlayerPlaybackSettingsController.new,
    );

class PlayerPlaybackSettingsController extends Notifier<PlayerPlaybackSettings> {
  @override
  PlayerPlaybackSettings build() {
    final stored = ref
        .read(sharedPreferencesProvider)
        .getString(PlayerPlaybackSettings.storageKey);
    return PlayerPlaybackSettings.fromStorage(stored);
  }

  Future<void> setAutoplayNextVideo(bool enabled) async {
    if (state.autoplayNextVideo == enabled) {
      return;
    }
    state = state.copyWith(autoplayNextVideo: enabled);
    await ref.read(sharedPreferencesProvider).setString(
          PlayerPlaybackSettings.storageKey,
          jsonEncode(state.toJson()),
        );
  }
}
