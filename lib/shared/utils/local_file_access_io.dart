import 'dart:io';

bool localFileExistsImpl(String? path) {
  if (path == null || path.trim().isEmpty) {
    return false;
  }
  return File(path).existsSync();
}

Future<String?> readLocalTextFileImpl(String path) async {
  try {
    final file = File(path);
    if (!await file.exists()) {
      return null;
    }
    return file.readAsString();
  } on Object {
    return null;
  }
}

Future<int?> localVideoFileSizeImpl(String path) async {
  try {
    final file = File(path);
    if (!await file.exists()) {
      return null;
    }
    return file.length();
  } on Object {
    return null;
  }
}
