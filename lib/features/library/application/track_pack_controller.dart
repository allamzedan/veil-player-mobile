import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veil_mobile/core/storage/storage_providers.dart';
import 'package:veil_mobile/core/storage/track_pack_storage_service.dart';
import 'package:veil_mobile/core/track_packs/track_pack.dart';
import 'package:veil_mobile/core/track_packs/track_pack_samples.dart';
import 'package:veil_mobile/core/veil/veil_track.dart';
import 'package:veil_mobile/shared/constants/app_strings.dart';
import 'package:veil_mobile/shared/utils/veil_error_messages.dart';

final trackPackControllerProvider =
    AsyncNotifierProvider<TrackPackController, List<TrackPack>>(
      TrackPackController.new,
    );

class TrackPackOperationResult {
  const TrackPackOperationResult({required this.success, required this.message});

  final bool success;
  final String message;
}

class TrackPackController extends AsyncNotifier<List<TrackPack>> {
  TrackPackStorageService get _storage =>
      ref.read(trackPackStorageServiceProvider);

  @override
  Future<List<TrackPack>> build() async {
    await _seedSamplesIfNeeded();
    return _loadPacks();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _loadPacks());
  }

  Future<TrackPackOperationResult> importPack(TrackPack pack) async {
    try {
      await _storage.savePackLocally(pack);
      await refresh();
      return TrackPackOperationResult(
        success: true,
        message: AppStrings.trackPackImportSuccess,
      );
    } on Object catch (error) {
      return TrackPackOperationResult(
        success: false,
        message: VeilErrorMessages.fromException(error),
      );
    }
  }

  Future<TrackPackOperationResult> deletePack(String id) async {
    try {
      await _storage.deletePack(id);
      await refresh();
      return TrackPackOperationResult(
        success: true,
        message: AppStrings.trackPackDeleteSuccess,
      );
    } on Object catch (error) {
      return TrackPackOperationResult(
        success: false,
        message: VeilErrorMessages.fromException(error),
      );
    }
  }

  TrackPack buildPackFromTracks({
    required String title,
    required List<VeilTrack> tracks,
    String description = '',
    String author = TrackPack.defaultAuthor,
    List<String> tags = const [],
  }) {
    return TrackPack.fromVeilTracks(
      title: title,
      tracks: tracks,
      description: description,
      author: author,
      tags: tags,
    );
  }

  Future<List<TrackPack>> _loadPacks() => _storage.loadSavedPacks();

  Future<void> _seedSamplesIfNeeded() async {
    if (_storage.samplesSeeded) {
      return;
    }

    final existing = await _storage.loadSavedPacks();
    if (existing.isNotEmpty) {
      await _storage.markSamplesSeeded();
      return;
    }

    for (final sample in TrackPackSamples.examples()) {
      await _storage.savePackLocally(sample);
    }
    await _storage.markSamplesSeeded();
  }
}
