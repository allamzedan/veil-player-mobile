import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:veil_mobile/core/track_packs/track_pack.dart';
import 'package:veil_mobile/core/track_packs/track_pack_codec.dart';
import 'package:veil_mobile/core/track_packs/track_pack_samples.dart';

/// Persists imported track packs locally (no cloud).
class TrackPackStorageService {
  TrackPackStorageService(this._prefs);

  static const String packIdsKey = 'veil_pack_ids';
  static const String packKeyPrefix = 'veil_pack_';

  final SharedPreferences _prefs;

  Future<List<TrackPack>> loadSavedPacks() async {
    final ids = await _readPackIds();
    final packs = <TrackPack>[];

    for (final id in ids) {
      try {
        final pack = await loadPackById(id);
        if (pack != null) {
          packs.add(pack);
        }
      } on Object {
        // Skip corrupted entries without crashing the app.
      }
    }

    packs.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return packs;
  }

  Future<TrackPack?> loadPackById(String id) async {
    final json = _prefs.getString('$packKeyPrefix$id');
    if (json == null || json.isEmpty) {
      return null;
    }
    return importPackFromJson(json);
  }

  Future<void> savePackLocally(TrackPack pack) async {
    final json = TrackPackCodec.encode(pack);
    final packKey = '$packKeyPrefix${pack.id}';
    final saved = await _prefs.setString(packKey, json);
    if (!saved) {
      throw StateError('Failed to save track pack "${pack.id}" locally.');
    }

    final ids = await _readPackIds();
    if (!ids.contains(pack.id)) {
      ids.add(pack.id);
      await _writePackIds(ids);
    }
  }

  Future<void> deletePack(String id) async {
    await _prefs.remove('$packKeyPrefix$id');
    final ids = await _readPackIds();
    ids.remove(id);
    await _writePackIds(ids);
  }

  TrackPack importPackFromJson(String jsonSource) {
    return TrackPackCodec.decode(jsonSource);
  }

  String exportPackJson(TrackPack pack) => TrackPackCodec.encode(pack);

  bool get samplesSeeded => _prefs.getBool(TrackPackSamples.seedPrefKey) ?? false;

  Future<void> markSamplesSeeded() async {
    await _prefs.setBool(TrackPackSamples.seedPrefKey, true);
  }

  Future<List<String>> _readPackIds() async {
    final raw = _prefs.getString(packIdsKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return [];
      }
      return decoded.map((e) => e.toString()).toList();
    } on FormatException {
      return [];
    }
  }

  Future<void> _writePackIds(List<String> ids) async {
    final saved = await _prefs.setString(packIdsKey, jsonEncode(ids));
    if (!saved) {
      throw StateError('Failed to update saved track pack index.');
    }
  }
}
