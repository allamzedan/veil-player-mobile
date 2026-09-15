import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veil_mobile/core/storage/media_history_models.dart';
import 'package:veil_mobile/core/storage/media_history_storage_service.dart';
import 'package:veil_mobile/core/storage/storage_providers.dart';
import 'package:veil_mobile/shared/constants/app_strings.dart';

final mediaHistoryControllerProvider =
    AsyncNotifierProvider<MediaHistoryController, MediaHistoryState>(
      MediaHistoryController.new,
    );

class MediaHistoryState {
  const MediaHistoryState({
    this.recentVideos = const [],
    this.recentTracks = const [],
    this.lastSession,
  });

  final List<RecentVideoEntry> recentVideos;
  final List<RecentTrackEntry> recentTracks;
  final LastSessionSnapshot? lastSession;

  bool get hasLastSession => lastSession?.isResumable ?? false;
}

class MediaHistoryController extends AsyncNotifier<MediaHistoryState> {
  MediaHistoryStorageService get _storage =>
      ref.read(mediaHistoryStorageServiceProvider);

  @override
  Future<MediaHistoryState> build() => _loadState();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _loadState());
  }

  Future<bool> removeRecentVideo(String dedupeKey) async {
    final removed = await _storage.removeRecentVideo(dedupeKey);
    if (removed) {
      await refresh();
    }
    return removed;
  }

  Future<bool> removeRecentTrack(String dedupeKey) async {
    final removed = await _storage.removeRecentTrack(dedupeKey);
    if (removed) {
      await refresh();
    }
    return removed;
  }

  Future<MediaHistoryState> _loadState() async {
    final videos = await _storage.loadRecentVideos();
    final tracks = await _storage.loadRecentTracks();
    final session = await _storage.loadLastSession();
    return MediaHistoryState(
      recentVideos: videos,
      recentTracks: tracks,
      lastSession: session,
    );
  }
}

/// Refreshes media history after player updates recents/session.
void refreshMediaHistory(WidgetRef ref) {
  ref.read(mediaHistoryControllerProvider.notifier).refresh();
}

String mediaHistorySnackMessage({required bool success}) {
  return success
      ? AppStrings.libraryHistoryRemoved
      : AppStrings.libraryLoadError;
}
