import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:veil_mobile/core/storage/veil_track_storage_service.dart';
import 'package:veil_mobile/core/storage/media_history_storage_service.dart';
import 'package:veil_mobile/core/storage/track_pack_storage_service.dart';

/// Initialized in [main] before the app runs.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main()',
  ),
);

final veilTrackStorageServiceProvider = Provider<VeilTrackStorageService>(
  (ref) => VeilTrackStorageService(ref.watch(sharedPreferencesProvider)),
);

final mediaHistoryStorageServiceProvider = Provider<MediaHistoryStorageService>(
  (ref) => MediaHistoryStorageService(ref.watch(sharedPreferencesProvider)),
);

final trackPackStorageServiceProvider = Provider<TrackPackStorageService>(
  (ref) => TrackPackStorageService(ref.watch(sharedPreferencesProvider)),
);
