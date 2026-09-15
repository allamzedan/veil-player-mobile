import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:veil_mobile/core/recovery/recovery_draft.dart';

/// Persists at most one recovery draft per source (player / track builder).
class RecoveryStorageService {
  RecoveryStorageService(this._prefs);

  static const String playerDraftKey = 'recovery_draft_player';
  static const String trackBuilderDraftKey = 'recovery_draft_track_builder';

  final SharedPreferences _prefs;

  RecoveryDraft? loadPlayerDraft() => _loadDraft(playerDraftKey);

  RecoveryDraft? loadTrackBuilderDraft() => _loadDraft(trackBuilderDraftKey);

  RecoveryDraft? loadDraft(RecoveryDraftSource source) {
    return switch (source) {
      RecoveryDraftSource.player => loadPlayerDraft(),
      RecoveryDraftSource.trackBuilder => loadTrackBuilderDraft(),
    };
  }

  Future<void> saveDraft(RecoveryDraft draft) async {
    final key = switch (draft.source) {
      RecoveryDraftSource.player => playerDraftKey,
      RecoveryDraftSource.trackBuilder => trackBuilderDraftKey,
    };
    await _prefs.setString(key, jsonEncode(draft.toJson()));
  }

  Future<void> deleteDraft(RecoveryDraftSource source) async {
    final key = switch (source) {
      RecoveryDraftSource.player => playerDraftKey,
      RecoveryDraftSource.trackBuilder => trackBuilderDraftKey,
    };
    await _prefs.remove(key);
  }

  Future<void> clearAll() async {
    await _prefs.remove(playerDraftKey);
    await _prefs.remove(trackBuilderDraftKey);
  }

  RecoveryDraft? _loadDraft(String key) {
    final raw = _prefs.getString(key);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return RecoveryDraft.tryFromJson(json);
    } on Object {
      return null;
    }
  }
}
