import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:veil_mobile/core/recovery/recovery_provider.dart';
import 'package:veil_mobile/core/storage/storage_providers.dart';
import 'package:veil_mobile/core/storage/veil_track_storage_service.dart';
import 'package:veil_mobile/features/library/application/library_controller.dart';
import 'package:veil_mobile/core/veil/veil_segment.dart';
import 'package:veil_mobile/core/veil/veil_segment_type.dart';
import 'package:veil_mobile/core/veil/veil_track.dart';
import 'package:veil_mobile/core/veil/veil_track_codec.dart';
import 'package:veil_mobile/core/veil/veil_track_validator.dart';
import 'package:veil_mobile/features/track_builder/application/track_builder_state.dart';
import 'package:veil_mobile/shared/constants/app_strings.dart';
import 'package:veil_mobile/shared/utils/local_file_access.dart';
import 'package:veil_mobile/shared/utils/veil_error_messages.dart';

final trackBuilderControllerProvider =
    NotifierProvider<TrackBuilderController, TrackBuilderState>(
      TrackBuilderController.new,
    );

class TrackBuilderController extends Notifier<TrackBuilderState> {
  static const _uuid = Uuid();

  VeilTrack? _savedSnapshot;

  VeilTrackStorageService get _storage =>
      ref.read(veilTrackStorageServiceProvider);

  @override
  TrackBuilderState build() => TrackBuilderState(
    track: VeilTrack.empty(),
    statusMessage: AppStrings.trackStatusDraft,
  );

  void createNewTrack({String title = ''}) {
    resetTrack(title: title);
  }

  void resetTrack({String title = ''}) {
    _savedSnapshot = null;
    state = TrackBuilderState(
      track: VeilTrack.empty(title: title),
      hasUnsavedChanges: false,
      isPersisted: false,
      showValidationErrors: false,
      statusMessage: AppStrings.trackStatusDraft,
    );
    unawaited(
      ref.read(recoveryControllerProvider.notifier).clearTrackBuilderDraft(),
    );
  }

  void updateTitle(String title) {
    _setTrack(state.track.copyWith(title: title).touchUpdated());
  }

  void addSegment({
    VeilSegmentType type = VeilSegmentType.mask,
    int startMs = 0,
    int endMs = 1000,
    String? label,
    String? notes,
  }) {
    final segment = VeilSegment.mobileDefault(
      id: _uuid.v4(),
      type: type,
      startMs: startMs,
      endMs: endMs,
      label: label?.trim().isEmpty == true ? null : label?.trim(),
      notes: notes?.trim().isEmpty == true ? null : notes?.trim(),
    );
    _setTrack(
      state.track
          .copyWith(segments: [...state.track.segments, segment])
          .touchUpdated(),
    );
  }

  void updateSegment(VeilSegment segment) {
    final segments = [
      for (final existing in state.track.segments)
        if (existing.id == segment.id) segment else existing,
    ];
    _setTrack(state.track.copyWith(segments: segments).touchUpdated());
  }

  void deleteSegment(String segmentId) {
    _setTrack(
      state.track
          .copyWith(
            segments: state.track.segments
                .where((s) => s.id != segmentId)
                .toList(),
          )
          .touchUpdated(),
    );
  }

  void reorderSegments(int oldIndex, int newIndex) {
    final segments = List<VeilSegment>.from(state.track.segments);
    final item = segments.removeAt(oldIndex);
    segments.insert(newIndex, item);
    _setTrack(state.track.copyWith(segments: segments).touchUpdated());
  }

  List<String> validateTrack() => VeilTrackValidator.validate(state.track);

  String exportJsonPreview() => VeilTrackCodec.encode(state.track);

  String exportCurrentTrackJson() => _storage.exportTrackJson(state.track);

  bool get shouldConfirmDiscard =>
      state.hasUnsavedChanges ||
      state.track.segments.isNotEmpty ||
      state.track.title.trim().isNotEmpty;

  TrackBuilderOperationResult _failValidation() {
    state = state.copyWith(showValidationErrors: true);
    return TrackBuilderOperationResult(
      success: false,
      message: AppStrings.saveValidationFailed,
    );
  }

  /// Validates before export or preview; reveals errors when invalid.
  TrackBuilderOperationResult validateForExport() {
    if (validateTrack().isNotEmpty) {
      return _failValidation();
    }
    return TrackBuilderOperationResult(success: true, message: '');
  }

  Future<TrackBuilderOperationResult> saveCurrentTrack() async {
    final errors = validateTrack();
    if (errors.isNotEmpty) {
      return _failValidation();
    }

    try {
      final track = state.track.touchUpdated();
      await _storage.saveTrackLocally(track);
      _savedSnapshot = track;
      state = state.copyWith(
        track: track,
        hasUnsavedChanges: false,
        isPersisted: true,
        showValidationErrors: false,
        statusMessage: AppStrings.trackStatusSaved,
      );
      await ref.read(libraryControllerProvider.notifier).refresh();
      unawaited(
        ref.read(recoveryControllerProvider.notifier).clearTrackBuilderDraft(),
      );
      return TrackBuilderOperationResult(
        success: true,
        message: AppStrings.saveSuccess,
      );
    } on Object catch (error) {
      return TrackBuilderOperationResult(
        success: false,
        message: VeilErrorMessages.fromException(error),
      );
    }
  }

  void loadTrack(VeilTrack track) {
    _savedSnapshot = track;
    state = TrackBuilderState(
      track: track,
      hasUnsavedChanges: false,
      isPersisted: true,
      showValidationErrors: false,
      statusMessage: AppStrings.trackStatusLoaded,
    );
  }

  /// Loads a draft track from the player without marking it persisted.
  void loadTrackDraft(VeilTrack track) {
    _savedSnapshot = null;
    state = TrackBuilderState(
      track: track,
      hasUnsavedChanges: true,
      isPersisted: false,
      showValidationErrors: false,
      statusMessage: AppStrings.trackStatusDraft,
    );
  }

  Future<TrackBuilderOperationResult> loadTrackById(String id) async {
    try {
      final track = await _storage.loadTrackById(id);
      if (track == null) {
        return TrackBuilderOperationResult(
          success: false,
          message: AppStrings.trackNotFound,
        );
      }

      loadTrack(track);
      return TrackBuilderOperationResult(
        success: true,
        message: AppStrings.trackStatusLoaded,
      );
    } on Object catch (error) {
      return TrackBuilderOperationResult(
        success: false,
        message: VeilErrorMessages.fromException(error),
      );
    }
  }

  Future<TrackBuilderOperationResult> importFromJson(String source) async {
    try {
      final track = _storage.importTrackFromJson(source.trim());
      final errors = VeilTrackValidator.validate(track);
      if (errors.isNotEmpty) {
        return TrackBuilderOperationResult(
          success: false,
          message:
              '${AppStrings.importValidationFailed}: '
              '${errors.join('; ')}',
        );
      }

      _savedSnapshot = null;
      final persisted = await _storage.isTrackSaved(track.id);
      state = TrackBuilderState(
        track: track,
        hasUnsavedChanges: !persisted,
        isPersisted: persisted,
        showValidationErrors: false,
        statusMessage: AppStrings.trackStatusImported,
      );
      if (!persisted) {
        unawaited(
          ref
              .read(recoveryControllerProvider.notifier)
              .autosaveTrackBuilder(),
        );
      }
      return TrackBuilderOperationResult(
        success: true,
        message: AppStrings.importSuccess,
      );
    } on Object catch (error) {
      return TrackBuilderOperationResult(
        success: false,
        message: VeilErrorMessages.fromException(error),
      );
    }
  }

  Future<TrackBuilderOperationResult> importFromPath(String path) async {
    if (!localFileExists(path)) {
      return TrackBuilderOperationResult(
        success: false,
        message: AppStrings.mediaHistorySourceMissing(_basename(path)),
      );
    }

    final content = await readLocalTextFile(path);
    if (content == null) {
      return TrackBuilderOperationResult(
        success: false,
        message: AppStrings.playerTrackLoadError,
      );
    }

    return importFromJson(content);
  }

  Future<TrackBuilderOperationResult> deleteCurrentTrackIfSaved() async {
    if (!state.isPersisted) {
      return TrackBuilderOperationResult(
        success: false,
        message: AppStrings.deleteNotSaved,
      );
    }

    try {
      await _storage.deleteTrack(state.track.id);
      resetTrack();
      await ref.read(libraryControllerProvider.notifier).refresh();
      return TrackBuilderOperationResult(
        success: true,
        message: AppStrings.deleteSuccess,
      );
    } on Object catch (error) {
      return TrackBuilderOperationResult(
        success: false,
        message: VeilErrorMessages.fromException(error),
      );
    }
  }

  Future<TrackBuilderOperationResult> deleteSavedTrack(String id) async {
    try {
      await _storage.deleteTrack(id);
      if (state.track.id == id) {
        resetTrack();
      }
      await ref.read(libraryControllerProvider.notifier).refresh();
      return TrackBuilderOperationResult(
        success: true,
        message: AppStrings.deleteSuccess,
      );
    } on Object catch (error) {
      return TrackBuilderOperationResult(
        success: false,
        message: VeilErrorMessages.fromException(error),
      );
    }
  }

  void _setTrack(VeilTrack track) {
    final errors = VeilTrackValidator.validate(track);
    final hideErrors = state.showValidationErrors && errors.isEmpty;

    state = state.copyWith(
      track: track,
      hasUnsavedChanges: _computeHasUnsavedChanges(track),
      showValidationErrors: hideErrors ? false : state.showValidationErrors,
      clearStatusMessage: true,
    );
    if (state.hasUnsavedChanges) {
      unawaited(
        ref.read(recoveryControllerProvider.notifier).autosaveTrackBuilder(),
      );
    }
  }

  bool _computeHasUnsavedChanges(VeilTrack track) {
    if (_savedSnapshot == null) {
      return track.segments.isNotEmpty || track.title.trim().isNotEmpty;
    }
    return VeilTrackCodec.encode(track) !=
        VeilTrackCodec.encode(_savedSnapshot!);
  }

  static String _basename(String path) {
    final separator = path.contains('\\') ? '\\' : '/';
    return path.split(separator).last;
  }
}
