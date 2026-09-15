import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:veil_mobile/core/track_packs/track_pack_codec.dart';
import 'package:veil_mobile/shared/utils/local_file_access.dart';

/// Result of picking a `.veilpack.json` file.
class VeilPackPickResult {
  const VeilPackPickResult({required this.content, this.path, this.name});

  final String content;
  final String? path;
  final String? name;
}

/// Picks a track pack file and returns its UTF-8 text content.
abstract final class VeilPackFilePicker {
  static Future<VeilPackPickResult?> pickPackFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return null;
    }

    final file = result.files.single;
    final name = file.name.toLowerCase();
    if (!name.endsWith('.veilpack.json') && !name.endsWith('veilpack.json')) {
      throw const FormatException('Selected file is not a .veilpack.json file.');
    }

    final content = await _readContent(file);
    if (content == null) {
      throw const FormatException(
        'Could not read the selected pack file on this platform.',
      );
    }

    if (TrackPackCodec.tryDecode(content) == null) {
      throw const FormatException('Unsupported track pack format.');
    }

    return VeilPackPickResult(
      content: content,
      path: file.path,
      name: file.name,
    );
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
