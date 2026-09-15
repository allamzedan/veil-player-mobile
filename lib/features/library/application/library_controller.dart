import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veil_mobile/core/storage/storage_providers.dart';
import 'package:veil_mobile/core/storage/veil_track_storage_service.dart';
import 'package:veil_mobile/core/veil/veil_track.dart';
import 'package:veil_mobile/core/veil/veil_track_validator.dart';
import 'package:veil_mobile/shared/constants/app_strings.dart';
import 'package:veil_mobile/shared/utils/veil_error_messages.dart';

final libraryControllerProvider =
    AsyncNotifierProvider<LibraryController, List<LibraryTrackItem>>(
      LibraryController.new,
    );

/// A saved track entry shown in the library list.
class LibraryTrackItem {
  const LibraryTrackItem({required this.track, required this.validationErrors});

  final VeilTrack track;
  final List<String> validationErrors;

  bool get isValid => validationErrors.isEmpty;
}

class LibraryOperationResult {
  const LibraryOperationResult({required this.success, required this.message});

  final bool success;
  final String message;
}

class LibraryController extends AsyncNotifier<List<LibraryTrackItem>> {
  VeilTrackStorageService get _storage =>
      ref.read(veilTrackStorageServiceProvider);

  @override
  Future<List<LibraryTrackItem>> build() => _loadItems();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _loadItems());
  }

  Future<LibraryOperationResult> deleteTrack(String id) async {
    try {
      await _storage.deleteTrack(id);
      await refresh();
      return LibraryOperationResult(
        success: true,
        message: AppStrings.deleteSuccess,
      );
    } on Object catch (error) {
      return LibraryOperationResult(
        success: false,
        message: VeilErrorMessages.fromException(error),
      );
    }
  }

  Future<List<LibraryTrackItem>> _loadItems() async {
    final tracks = await _storage.loadSavedTracks();
    return [
      for (final track in tracks)
        LibraryTrackItem(
          track: track,
          validationErrors: VeilTrackValidator.validate(
            track,
            forWriting: false,
          ),
        ),
    ];
  }
}
