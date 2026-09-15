import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:veil_mobile/shared/utils/local_file_access.dart';

/// Result of picking a VEIL track file (`.veil`, `.veil.json`, or `.json`).
class VeilJsonPickResult {
  const VeilJsonPickResult({required this.content, this.path, this.name});

  final String content;
  final String? path;
  final String? name;
}

/// Whether [name] is a supported VEIL track filename.
bool isVeilTrackFileName(String? name) {
  if (name == null || name.isEmpty) {
    return false;
  }
  final lower = name.toLowerCase();
  return lower.endsWith('.veil') ||
      lower.endsWith('.veil.json') ||
      lower.endsWith('.json');
}

/// Picks a VEIL track file and returns its UTF-8 text content.
abstract final class VeilJsonFilePicker {
  static Future<VeilJsonPickResult?> pickJsonFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['json', 'veil'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return null;
    }

    final file = result.files.single;
    if (!isVeilTrackFileName(file.name)) {
      throw const FormatException(
        'Selected file is not a supported VEIL track file.',
      );
    }

    final content = await _readContent(file);
    if (content == null) {
      throw const FormatException(
        'Could not read the selected track file on this platform.',
      );
    }

    return VeilJsonPickResult(
      content: content,
      path: file.path,
      name: file.name,
    );
  }

  /// Backward-compatible helper that returns only file content.
  static Future<String?> pickJsonContent() async {
    final picked = await pickJsonFile();
    return picked?.content;
  }

  static Future<String?> _readContent(PlatformFile file) async {
    if (file.bytes != null) {
      return utf8.decode(file.bytes!, allowMalformed: true);
    }
    final path = file.path;
    if (path != null && path.isNotEmpty) {
      return readLocalTextFile(path);
    }
    return null;
  }
}
