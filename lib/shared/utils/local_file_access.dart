import 'local_file_access_stub.dart'
    if (dart.library.io) 'local_file_access_io.dart';

/// Whether a local filesystem path exists (IO platforms only).
bool localFileExists(String? path) => localFileExistsImpl(path);

/// Reads UTF-8 text from a local path, or `null` when unavailable.
Future<String?> readLocalTextFile(String path) => readLocalTextFileImpl(path);

/// Returns the byte length of a local file, or `null` when unavailable.
Future<int?> localVideoFileSize(String path) => localVideoFileSizeImpl(path);
