import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:veil_mobile/core/veil/veil_track.dart';
import 'package:veil_mobile/core/veil/veil_track_codec.dart';

/// Persists VEIL tracks locally using [SharedPreferences].
class VeilTrackStorageService {
  VeilTrackStorageService(this._prefs);

  static const String trackIdsKey = 'veil_track_ids';
  static const String trackKeyPrefix = 'veil_track_';

  final SharedPreferences _prefs;

  Future<void> saveTrackLocally(VeilTrack track) async {
    final json = VeilTrackCodec.encodeMobile(track);
    final trackKey = '$trackKeyPrefix${track.id}';
    final saved = await _prefs.setString(trackKey, json);
    if (!saved) {
      throw StateError('Failed to save track "${track.id}" locally.');
    }

    final ids = await _readTrackIds();
    if (!ids.contains(track.id)) {
      ids.add(track.id);
      await _writeTrackIds(ids);
    }
  }

  Future<List<VeilTrack>> loadSavedTracks() async {
    final ids = await _readTrackIds();
    final tracks = <VeilTrack>[];

    for (final id in ids) {
      try {
        final track = await loadTrackById(id);
        if (track != null) {
          tracks.add(track);
        }
      } on Object {
        // Skip corrupted entries without crashing the app.
      }
    }

    tracks.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return tracks;
  }

  Future<VeilTrack?> loadTrackById(String id) async {
    final json = _prefs.getString('$trackKeyPrefix$id');
    if (json == null || json.isEmpty) {
      return null;
    }
    return importTrackFromJson(json);
  }

  Future<void> deleteTrack(String id) async {
    await _prefs.remove('$trackKeyPrefix$id');
    final ids = await _readTrackIds();
    ids.remove(id);
    await _writeTrackIds(ids);
  }

  String exportTrackJson(VeilTrack track) => VeilTrackCodec.encode(track);

  VeilTrack importTrackFromJson(String jsonSource) {
    return VeilTrackCodec.decode(jsonSource);
  }

  Future<bool> isTrackSaved(String id) async {
    final ids = await _readTrackIds();
    return ids.contains(id) && _prefs.containsKey('$trackKeyPrefix$id');
  }

  Future<List<String>> _readTrackIds() async {
    final raw = _prefs.getString(trackIdsKey);
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

  Future<void> _writeTrackIds(List<String> ids) async {
    final saved = await _prefs.setString(trackIdsKey, jsonEncode(ids));
    if (!saved) {
      throw StateError('Failed to update saved track index.');
    }
  }
}
