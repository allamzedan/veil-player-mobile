import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:veil_mobile/core/storage/media_history_models.dart';

/// Local-only persistence for recent videos, tracks, and last session.
///
/// Future: favorites, collections, cloud sync.
class MediaHistoryStorageService {
  MediaHistoryStorageService(this._prefs);

  static const String recentVideosKey = 'media_history_recent_videos';
  static const String recentTracksKey = 'media_history_recent_tracks';
  static const String lastSessionKey = 'media_history_last_session';

  final SharedPreferences _prefs;

  Future<List<RecentVideoEntry>> loadRecentVideos() async {
    return _decodeList(
      _prefs.getString(recentVideosKey),
      RecentVideoEntry.fromJson,
    );
  }

  Future<List<RecentTrackEntry>> loadRecentTracks() async {
    return _decodeList(
      _prefs.getString(recentTracksKey),
      RecentTrackEntry.fromJson,
    );
  }

  Future<LastSessionSnapshot?> loadLastSession() async {
    final raw = _prefs.getString(lastSessionKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return LastSessionSnapshot.fromJson(json);
    } on Object {
      return null;
    }
  }

  Future<void> recordRecentVideo(RecentVideoEntry entry) async {
    final items = await loadRecentVideos();
    final updated = _prependUnique(
      items,
      entry,
      entry.dedupeKey,
      (item) => item.dedupeKey,
    );
    await _prefs.setString(
      recentVideosKey,
      jsonEncode(updated.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> recordRecentTrack(RecentTrackEntry entry) async {
    final items = await loadRecentTracks();
    final updated = _prependUnique(
      items,
      entry,
      entry.dedupeKey,
      (item) => item.dedupeKey,
    );
    await _prefs.setString(
      recentTracksKey,
      jsonEncode(updated.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> saveLastSession(LastSessionSnapshot session) async {
    await _prefs.setString(lastSessionKey, jsonEncode(session.toJson()));
  }

  Future<void> clearLastSession() async {
    await _prefs.remove(lastSessionKey);
  }

  Future<bool> removeRecentVideo(String dedupeKey) async {
    final items = await loadRecentVideos();
    final updated = items.where((item) => item.dedupeKey != dedupeKey).toList();
    if (updated.length == items.length) {
      return false;
    }
    await _prefs.setString(
      recentVideosKey,
      jsonEncode(updated.map((e) => e.toJson()).toList()),
    );
    return true;
  }

  Future<bool> removeRecentTrack(String dedupeKey) async {
    final items = await loadRecentTracks();
    final updated = items.where((item) => item.dedupeKey != dedupeKey).toList();
    if (updated.length == items.length) {
      return false;
    }
    await _prefs.setString(
      recentTracksKey,
      jsonEncode(updated.map((e) => e.toJson()).toList()),
    );
    return true;
  }

  List<T> _prependUnique<T>(
    List<T> items,
    T entry,
    String key,
    String Function(T item) keyOf,
  ) {
    final filtered = items.where((item) => keyOf(item) != key).toList();
    return [
      entry,
      ...filtered,
    ].take(MediaHistoryLimits.maxRecentEntries).toList();
  }

  List<T> _decodeList<T>(
    String? raw,
    T Function(Map<String, dynamic> json) fromJson,
  ) {
    if (raw == null || raw.isEmpty) {
      return [];
    }
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return [
        for (final item in decoded)
          if (item is Map<String, dynamic>) fromJson(item),
      ];
    } on Object {
      return [];
    }
  }
}
