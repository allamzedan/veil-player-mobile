import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veil_mobile/core/storage/storage_providers.dart';
import 'package:veil_mobile/features/player/domain/player_display_settings.dart';

final playerDisplaySettingsProvider =
    NotifierProvider<PlayerDisplaySettingsController, PlayerDisplaySettings>(
      PlayerDisplaySettingsController.new,
    );

class PlayerDisplaySettingsController extends Notifier<PlayerDisplaySettings> {
  @override
  PlayerDisplaySettings build() {
    final stored = ref
        .read(sharedPreferencesProvider)
        .getString(PlayerDisplaySettings.storageKey);
    return PlayerDisplaySettings.fromStorage(stored);
  }

  Future<void> setVolume(double volume) async {
    final clamped = PlayerDisplaySettings.clampLevel(volume);
    if (state.volume == clamped) {
      return;
    }
    state = state.copyWith(volume: clamped);
    await _persist();
  }

  Future<void> setBrightness(double brightness) async {
    final clamped = PlayerDisplaySettings.clampLevel(brightness);
    if (state.brightness == clamped) {
      return;
    }
    state = state.copyWith(brightness: clamped);
    await _persist();
  }

  Future<void> _persist() async {
    await ref.read(sharedPreferencesProvider).setString(
          PlayerDisplaySettings.storageKey,
          jsonEncode(state.toJson()),
        );
  }
}
