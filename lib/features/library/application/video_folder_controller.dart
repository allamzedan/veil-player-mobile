import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veil_mobile/core/storage/storage_providers.dart';
import 'package:veil_mobile/shared/utils/video_folder_scanner.dart';

/// A user-selected folder saved for quick video browsing.
class SavedVideoFolder {
  const SavedVideoFolder({
    required this.path,
    required this.displayName,
    required this.addedAtMs,
  });

  final String path;
  final String displayName;
  final int addedAtMs;

  Map<String, dynamic> toJson() => {
    'path': path,
    'displayName': displayName,
    'addedAtMs': addedAtMs,
  };

  factory SavedVideoFolder.fromJson(Map<String, dynamic> json) {
    return SavedVideoFolder(
      path: json['path'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      addedAtMs: (json['addedAtMs'] as num?)?.toInt() ?? 0,
    );
  }
}

final videoFolderControllerProvider =
    AsyncNotifierProvider<VideoFolderController, List<SavedVideoFolder>>(
      VideoFolderController.new,
    );

class VideoFolderController extends AsyncNotifier<List<SavedVideoFolder>> {
  static const _storageKey = 'saved_video_folders_v1';

  @override
  Future<List<SavedVideoFolder>> build() async {
    return _load();
  }

  Future<List<SavedVideoFolder>> _load() async {
    final raw = ref.read(sharedPreferencesProvider).getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return const [];
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return const [];
      }
      return [
        for (final item in decoded)
          if (item is Map<String, dynamic>) SavedVideoFolder.fromJson(item),
      ];
    } on Object {
      return const [];
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _load());
  }

  Future<void> _persist(List<SavedVideoFolder> folders) async {
    final encoded = jsonEncode(folders.map((folder) => folder.toJson()).toList());
    await ref.read(sharedPreferencesProvider).setString(_storageKey, encoded);
    state = AsyncData(folders);
  }

  Future<void> addFolder({required String path, required String displayName}) async {
    final current = state.value ?? await _load();
    if (current.any((folder) => folder.path == path)) {
      return;
    }
    final next = [
      SavedVideoFolder(
        path: path,
        displayName: displayName,
        addedAtMs: DateTime.now().toUtc().millisecondsSinceEpoch,
      ),
      ...current,
    ];
    await _persist(next);
  }

  Future<void> removeFolder(String path) async {
    final current = state.value ?? await _load();
    final next = current.where((folder) => folder.path != path).toList();
    await _persist(next);
  }

  VideoFolderScanResult scanFolder(String path) => scanVideoFolder(path);
}
