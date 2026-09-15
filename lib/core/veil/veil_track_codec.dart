import 'dart:convert';

import 'package:uuid/uuid.dart';
import 'package:veil_mobile/core/veil/veil_segment.dart';
import 'package:veil_mobile/core/veil/veil_segment_type.dart';
import 'package:veil_mobile/core/veil/veil_track.dart';

enum VeilParseStatus {
  accept('ACCEPT'),
  acceptPartial('ACCEPT_PARTIAL'),
  rejectDocument('REJECT_DOCUMENT'),
  limitExceeded('LIMIT_EXCEEDED');

  const VeilParseStatus(this.wireName);
  final String wireName;
}

class _DuplicateMemberScanner {
  _DuplicateMemberScanner(this.source);

  final String source;
  var _index = 0;
  var _duplicate = false;

  static bool hasDuplicate(String source) {
    final scanner = _DuplicateMemberScanner(source);
    try {
      scanner._skipWhitespace();
      scanner._value();
      return scanner._duplicate;
    } on Object {
      return false;
    }
  }

  void _value() {
    _skipWhitespace();
    if (_index >= source.length) throw const FormatException();
    switch (source.codeUnitAt(_index)) {
      case 0x7b:
        _object();
        return;
      case 0x5b:
        _array();
        return;
      case 0x22:
        _string();
        return;
      default:
        while (_index < source.length &&
            !',]} \t\r\n'.contains(source[_index])) {
          _index++;
        }
    }
  }

  void _object() {
    _index++;
    final keys = <String>{};
    _skipWhitespace();
    if (_consume(0x7d)) return;
    while (true) {
      _skipWhitespace();
      final key = _string();
      if (!keys.add(key)) _duplicate = true;
      _skipWhitespace();
      if (!_consume(0x3a)) throw const FormatException();
      _value();
      _skipWhitespace();
      if (_consume(0x7d)) return;
      if (!_consume(0x2c)) throw const FormatException();
    }
  }

  void _array() {
    _index++;
    _skipWhitespace();
    if (_consume(0x5d)) return;
    while (true) {
      _value();
      _skipWhitespace();
      if (_consume(0x5d)) return;
      if (!_consume(0x2c)) throw const FormatException();
    }
  }

  String _string() {
    if (!_consume(0x22)) throw const FormatException();
    final start = _index - 1;
    var escaped = false;
    while (_index < source.length) {
      final code = source.codeUnitAt(_index++);
      if (code == 0x22 && !escaped) {
        return jsonDecode(source.substring(start, _index)) as String;
      }
      if (code == 0x5c && !escaped) {
        escaped = true;
      } else {
        escaped = false;
      }
    }
    throw const FormatException();
  }

  bool _consume(int code) {
    if (_index < source.length && source.codeUnitAt(_index) == code) {
      _index++;
      return true;
    }
    return false;
  }

  void _skipWhitespace() {
    while (_index < source.length &&
        const {0x20, 0x09, 0x0a, 0x0d}.contains(source.codeUnitAt(_index))) {
      _index++;
    }
  }
}

class VeilResourcePolicy {
  const VeilResourcePolicy({
    this.maxDocumentBytes = VeilTrackCodec.maxDocumentBytes,
    this.maxNestingDepth = VeilTrackCodec.maxJsonDepth,
    this.maxItems = VeilTrackCodec.maxItems,
    this.maxStringBytes = VeilTrackCodec.maxStringBytes,
  });

  final int maxDocumentBytes;
  final int maxNestingDepth;
  final int maxItems;
  final int maxStringBytes;
}

class VeilParseResult {
  const VeilParseResult(this.status, {this.track, this.message});

  final VeilParseStatus status;
  final VeilTrack? track;
  final String? message;

  bool get accepted =>
      status == VeilParseStatus.accept ||
      status == VeilParseStatus.acceptPartial;
}

enum VeilMediaIdentityStatus { match, unknown, mismatch }

class _VeilLimitException implements Exception {
  const _VeilLimitException();
}

/// Encodes and decodes VEIL track JSON documents (mobile + desktop formats).
abstract final class VeilTrackCodec {
  // Finite bounds for untrusted declarative documents; no execution is attached to VEIL data.
  static const maxDocumentBytes = 2 * 1024 * 1024;
  static const maxJsonDepth = 32;
  static const maxItems = 10000;
  static const maxStringBytes = 256 * 1024;
  static const maxRetainedUnknownBytes = 512 * 1024;
  static const _unknownItemsKey = '__veilUnknownItems';
  static const _itemOrderKey = '__veilItemOrder';

  static const String mobileFormatId = 'veil.track';
  static const String desktopAppId = 'VEIL';
  static const String mobileExportAppVersion = 'VEIL Mobile 0.2.3';

  static const _uuid = Uuid();

  static const Set<String> _desktopTrackKnownKeys = {
    'version',
    'app',
    'appVersion',
    'exportedAt',
    'video',
    'globalOffsetSeconds',
    'trackMetadata',
    'items',
    'subtitleCover',
    'groups',
    'anchors',
  };

  static const Set<String> _desktopItemKnownKeys = {
    'id',
    'type',
    'enabled',
    'start',
    'end',
    'rect',
    'style',
    'source',
    'label',
    'notes',
  };

  static const Map<String, dynamic> _defaultSubtitleCover = {
    'mode': 'show',
    'regionRect': {
      'xPercent': 10,
      'yPercent': 78,
      'widthPercent': 80,
      'heightPercent': 18,
    },
  };

  /// Exports a desktop-compatible VEIL track document.
  static String encode(VeilTrack track) {
    final ids = <String>{};
    for (final segment in track.segments.where(
      (segment) => _isDesktopExportableType(segment.type),
    )) {
      if (segment.id.isEmpty || !ids.add(segment.id)) {
        throw const FormatException(
          'Canonical VEIL writers require nonempty, unique item IDs.',
        );
      }
    }
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(_toDesktopJson(track));
  }

  /// Encodes the legacy mobile storage format (backward compatibility).
  static String encodeMobile(VeilTrack track) {
    final map = {
      'format': mobileFormatId,
      'version': track.version,
      'id': track.id,
      'title': track.title,
      'createdAt': track.createdAt.toUtc().toIso8601String(),
      'updatedAt': track.updatedAt.toUtc().toIso8601String(),
      'segments': track.segments.map((s) => s.toJson()).toList(),
      if (track.app != null) 'app': track.app,
      if (track.appVersion != null) 'appVersion': track.appVersion,
      if (track.exportedAt != null)
        'exportedAt': track.exportedAt!.toUtc().toIso8601String(),
      if (track.videoName != null) 'videoName': track.videoName,
      if (track.videoDurationSeconds != null)
        'videoDurationSeconds': track.videoDurationSeconds,
      if (track.videoFileSize != null) 'videoFileSize': track.videoFileSize,
      if (track.videoWidth != null) 'videoWidth': track.videoWidth,
      if (track.videoHeight != null) 'videoHeight': track.videoHeight,
      if (track.globalOffsetSeconds != null)
        'globalOffsetSeconds': track.globalOffsetSeconds,
      if (track.subtitleCover != null) 'subtitleCover': track.subtitleCover,
      if (track.video != null) 'video': track.video,
      if (track.rawExtra != null && track.rawExtra!.isNotEmpty)
        'rawExtra': track.rawExtra,
    };
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(map);
  }

  static VeilTrack decode(String source) {
    final sourceBytes = utf8.encode(source).length;
    if (sourceBytes > maxDocumentBytes) {
      throw const FormatException(
        'LIMIT_EXCEEDED: VEIL resource limit exceeded.',
      );
    }
    if (_DuplicateMemberScanner.hasDuplicate(source)) {
      throw const FormatException(
        'REJECT_DOCUMENT: duplicate JSON object member.',
      );
    }
    final dynamic decoded;
    try {
      decoded = jsonDecode(source);
    } on Object {
      throw const FormatException('Invalid JSON.');
    }
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('VEIL track root must be a JSON object.');
    }
    try {
      _enforceResourcePolicy(decoded, policy: const VeilResourcePolicy());
    } on _VeilLimitException {
      throw const FormatException(
        'LIMIT_EXCEEDED: VEIL resource limit exceeded.',
      );
    }

    if (_isDesktopFormat(decoded)) {
      return _fromDesktopJson(decoded);
    }
    if (_isMobileFormat(decoded)) {
      return VeilTrack.fromMobileJson(decoded);
    }

    throw const FormatException('Unsupported VEIL track format.');
  }

  /// Canonical Profile 1.6.0 parser with the four Spec 0.1 outcomes.
  static VeilParseResult parseCanonical(
    String source, {
    VeilResourcePolicy policy = const VeilResourcePolicy(),
  }) {
    try {
      if (utf8.encode(source).length > policy.maxDocumentBytes) {
        throw const _VeilLimitException();
      }
      if (_DuplicateMemberScanner.hasDuplicate(source)) {
        return const VeilParseResult(
          VeilParseStatus.rejectDocument,
          message: 'Duplicate JSON object member.',
        );
      }
      final dynamic decoded = jsonDecode(source);
      if (decoded is! Map<String, dynamic>) {
        return const VeilParseResult(
          VeilParseStatus.rejectDocument,
          message: 'VEIL track root must be a JSON object.',
        );
      }
      _enforceResourcePolicy(decoded, policy: policy);
      if (!_isDesktopFormat(decoded)) {
        return const VeilParseResult(
          VeilParseStatus.rejectDocument,
          message: 'Unsupported canonical VEIL track format.',
        );
      }
      final track = _fromDesktopJson(decoded, maxItems: policy.maxItems);
      final unknown = track.rawExtra?[_unknownItemsKey] as List?;
      return VeilParseResult(
        unknown == null || unknown.isEmpty
            ? VeilParseStatus.accept
            : VeilParseStatus.acceptPartial,
        track: track,
      );
    } on _VeilLimitException {
      return const VeilParseResult(VeilParseStatus.limitExceeded);
    } on Object catch (error) {
      return VeilParseResult(
        VeilParseStatus.rejectDocument,
        message: error.toString(),
      );
    }
  }

  /// Returns `null` when [source] cannot be decoded as a VEIL track.
  static VeilTrack? tryDecode(String source) {
    try {
      return decode(source);
    } on Object {
      return null;
    }
  }

  static void _enforceResourcePolicy(
    dynamic value, {
    required VeilResourcePolicy policy,
    int depth = 0,
  }) {
    if (depth > policy.maxNestingDepth) throw const _VeilLimitException();
    if (value is String) {
      if (utf8.encode(value).length > policy.maxStringBytes) {
        throw const _VeilLimitException();
      }
    } else if (value is List) {
      for (final child in value) {
        _enforceResourcePolicy(child, policy: policy, depth: depth + 1);
      }
    } else if (value is Map) {
      for (final entry in value.entries) {
        _enforceResourcePolicy(entry.key, policy: policy, depth: depth + 1);
        _enforceResourcePolicy(entry.value, policy: policy, depth: depth + 1);
      }
    }
  }

  static bool _isDesktopFormat(Map<String, dynamic> json) {
    return json['app'] == desktopAppId && json.containsKey('items');
  }

  static bool _isMobileFormat(Map<String, dynamic> json) {
    return json['format'] == mobileFormatId;
  }

  static VeilTrack _fromDesktopJson(
    Map<String, dynamic> json, {
    int maxItems = VeilTrackCodec.maxItems,
  }) {
    _validateDesktopRoot(json, maxItems: maxItems);
    final version = json['version'] as String;
    if (!VeilTrack.supportedDesktopFormatVersions.contains(version)) {
      throw const FormatException('Unsupported VEIL desktop schema version.');
    }
    final items = json['items'] as List<dynamic>;
    final trackMetadata =
        json['trackMetadata'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final video = json['video'] as Map<String, dynamic>;
    final resolution = video['resolution'] as Map<String, dynamic>;

    final videoName = video['name'] as String?;
    final topLevelTitle = (json['title'] as String?)?.trim();
    final metadataTitle = (trackMetadata['title'] as String?)?.trim();
    final resolvedTitle = (topLevelTitle != null && topLevelTitle.isNotEmpty)
        ? topLevelTitle
        : ((metadataTitle != null && metadataTitle.isNotEmpty)
              ? metadataTitle
              : ((videoName != null && videoName.isNotEmpty)
                    ? videoName
                    : VeilTrack.defaultUntitledTitle));

    final createdAt =
        _parseDateTime(trackMetadata['createdAt']) ??
        _parseDateTime(json['exportedAt']) ??
        DateTime.now().toUtc();
    final updatedAt = _parseDateTime(trackMetadata['updatedAt']) ?? createdAt;

    return VeilTrack(
      id: json['id'] as String? ?? trackMetadata['id'] as String? ?? _uuid.v4(),
      title: resolvedTitle,
      version: version as String? ?? VeilTrack.desktopFormatVersion,
      createdAt: createdAt,
      updatedAt: updatedAt,
      segments: _segmentsFromDesktopItems(items),
      app: json['app'] as String?,
      appVersion: json['appVersion'] as String?,
      exportedAt: _parseDateTime(json['exportedAt']),
      videoName: videoName,
      videoDurationSeconds: (video['duration'] as num).toDouble(),
      videoFileSize: video['fileSize'] as num?,
      videoWidth: resolution['width'] as num,
      videoHeight: resolution['height'] as num,
      globalOffsetSeconds: (json['globalOffsetSeconds'] as num).toDouble(),
      subtitleCover: _cloneMap(json['subtitleCover']),
      video: _cloneMap(video),
      trackMetadata: Map<String, dynamic>.from(trackMetadata),
      rawExtra: _desktopRawExtra(json, items),
    );
  }

  static List<VeilSegment> _segmentsFromDesktopItems(List<dynamic> items) {
    final segments = <VeilSegment>[];
    for (final item in items) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('VEIL item must be an object.');
      }
      final type = item['type'];
      if (type is! String) {
        throw const FormatException('Segment type must be a string.');
      }
      if (VeilSegmentType.values.map((v) => v.toJson()).contains(type)) {
        segments.add(_segmentFromDesktopItem(item));
      }
    }
    return segments;
  }

  static VeilSegment _segmentFromDesktopItem(Map<String, dynamic> item) {
    final start = item['start'];
    if (start is! num || !start.isFinite || start < 0) {
      throw const FormatException('Invalid VEIL item start.');
    }
    final startSec = start.toDouble();
    final end = item['end'];
    final endSec = end == null
        ? startSec
        : (end is num && end.isFinite ? end.toDouble() : double.nan);
    if (endSec.isNaN || endSec < 0) {
      throw const FormatException('Invalid VEIL item end.');
    }
    final typeRaw = item['type'];
    if (typeRaw is! String) {
      throw const FormatException('Segment type must be a string.');
    }

    final knownTypes = VeilSegmentType.values
        .map((value) => value.toJson())
        .toSet();
    if (!knownTypes.contains(typeRaw)) {
      throw const FormatException('Unknown VEIL item type.');
    }
    final type = VeilSegmentType.fromJson(typeRaw);
    final isBookmark = type == VeilSegmentType.bookmark;
    if (!isBookmark && endSec <= startSec) {
      throw const FormatException('Timed VEIL items require end > start.');
    }
    final id = item['id'];
    if ((id != null && id is! String) ||
        (!isBookmark && (id is! String || id.isEmpty)) ||
        (item['enabled'] != null && item['enabled'] is! bool) ||
        (item['label'] != null && item['label'] is! String) ||
        (item['notes'] != null && item['notes'] is! String) ||
        (item['locked'] != null && item['locked'] is! bool)) {
      throw const FormatException('Malformed VEIL item field.');
    }
    if (type == VeilSegmentType.mask) _validateMask(item);

    return VeilSegment(
      id: id is String && id.isNotEmpty ? id : _uuid.v4(),
      type: type,
      startMs: (startSec * 1000).round(),
      endMs: isBookmark ? (startSec * 1000).round() : (endSec * 1000).round(),
      enabled: item['enabled'] as bool? ?? true,
      rect: _cloneMap(item['rect']),
      style: _cloneMap(item['style']),
      source: _cloneMap(item['source']),
      label: isBookmark
          ? (item['label'] as String? ?? 'Bookmark')
          : item['label'] as String?,
      notes: isBookmark
          ? (item['notes'] as String? ?? '')
          : item['notes'] as String?,
      rawExtra: _extractUnknownKeys(item, _desktopItemKnownKeys),
    );
  }

  static Map<String, dynamic>? _desktopRawExtra(
    Map<String, dynamic> json,
    List<dynamic> items,
  ) {
    final extra = <String, dynamic>{
      ...?_extractUnknownKeys(json, _desktopTrackKnownKeys),
      ...?_extractOptionalCollections(json, items),
    };
    final unknown = items
        .where((item) {
          return item is Map<String, dynamic> &&
              item['type'] is String &&
              !VeilSegmentType.values
                  .map((v) => v.toJson())
                  .contains(item['type']);
        })
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
    if (unknown.isNotEmpty) extra[_unknownItemsKey] = unknown;
    if (unknown.isNotEmpty) {
      var knownIndex = 0;
      extra[_itemOrderKey] = [
        for (final item in items)
          if (item is Map<String, dynamic> &&
              item['type'] is String &&
              VeilSegmentType.values
                  .map((value) => value.toJson())
                  .contains(item['type']))
            {'knownIndex': knownIndex++}
          else
            {'unknown': Map<String, dynamic>.from(item as Map)},
      ];
    }
    if (utf8.encode(jsonEncode(extra)).length > maxRetainedUnknownBytes) {
      throw const FormatException('VEIL resource limit exceeded.');
    }
    return extra.isEmpty ? null : extra;
  }

  static void _validateDesktopRoot(
    Map<String, dynamic> json, {
    required int maxItems,
  }) {
    const required = {
      'version',
      'app',
      'video',
      'globalOffsetSeconds',
      'items',
    };
    if (!required.every(json.containsKey) ||
        json['app'] != desktopAppId ||
        json['version'] is! String ||
        (json['appVersion'] != null && json['appVersion'] is! String) ||
        (json['exportedAt'] != null && json['exportedAt'] is! String) ||
        json['video'] is! Map<String, dynamic> ||
        (json['trackMetadata'] != null &&
            json['trackMetadata'] is! Map<String, dynamic>) ||
        json['items'] is! List) {
      throw const FormatException('Malformed VEIL desktop track.');
    }
    if ((json['items'] as List).length > maxItems) {
      throw const _VeilLimitException();
    }
    final offset = json['globalOffsetSeconds'];
    if (offset is! num || !offset.isFinite) {
      throw const FormatException('Invalid VEIL global offset.');
    }
    final video = json['video'] as Map<String, dynamic>;
    final metadata =
        json['trackMetadata'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final resolution = video['resolution'];
    final fingerprint = video['fingerprint'];
    final duration = video['duration'];
    if (video['name'] is! String ||
        ((video['name'] as String).trim().isEmpty &&
            video['binding'] != 'unbound') ||
        duration is! num ||
        !duration.isFinite ||
        duration < 0 ||
        !video.containsKey('fileSize') ||
        (video['fileSize'] != null &&
            (video['fileSize'] is! num ||
                !(video['fileSize'] as num).isFinite)) ||
        resolution is! Map<String, dynamic> ||
        resolution['width'] is! num ||
        resolution['height'] is! num ||
        !(resolution['width'] as num).isFinite ||
        !(resolution['height'] as num).isFinite ||
        resolution['width'] < 0 ||
        resolution['height'] < 0 ||
        (video['binding'] != null &&
            (video['binding'] is! String ||
                !{'metadata', 'unbound'}.contains(video['binding']))) ||
        metadata['downloads'] != null &&
            (metadata['downloads'] is! num ||
                !(metadata['downloads'] as num).isFinite ||
                (metadata['downloads'] as num) < 0) ||
        metadata['rating'] != null &&
            metadata['rating'] is! String &&
            metadata['rating'] is! num ||
        metadata['rating'] is num && !(metadata['rating'] as num).isFinite ||
        fingerprint is! Map<String, dynamic> ||
        fingerprint['method'] is! String ||
        fingerprint['value'] is! String ||
        (fingerprint['value'] as String).isEmpty ||
        !{'metadata-v1', 'manual-unbound'}.contains(fingerprint['method']) ||
        (fingerprint['method'] == 'manual-unbound' &&
            video['binding'] != 'unbound') ||
        (fingerprint['method'] == 'metadata-v1' &&
            video['binding'] == 'unbound')) {
      throw const FormatException('Malformed VEIL video metadata.');
    }
    _validateTrackMetadata(metadata);
    _validateOptionalCollections(json);
    _validateSubtitleCover(json['subtitleCover']);
  }

  static void _validateTrackMetadata(Map<String, dynamic> metadata) {
    for (final key in [
      'title',
      'description',
      'author',
      'language',
      'notes',
      'signature',
    ]) {
      if (metadata[key] != null && metadata[key] is! String) {
        throw const FormatException('Malformed VEIL track metadata.');
      }
    }
    final tags = metadata['tags'];
    if (tags != null &&
        (tags is! List || tags.any((value) => value is! String))) {
      throw const FormatException('Malformed VEIL track metadata.');
    }
  }

  static void _validateOptionalCollections(Map<String, dynamic> json) {
    final groups = json['groups'];
    if (groups != null) {
      if (groups is! List) {
        throw const FormatException('Malformed VEIL groups.');
      }
      for (final group in groups) {
        if (group is! Map<String, dynamic> ||
            group['id'] is! String ||
            (group['id'] as String).isEmpty ||
            group['label'] is! String ||
            (group['label'] as String).isEmpty ||
            group['itemIds'] is! List ||
            (group['itemIds'] as List).any(
              (value) => value is! String || value.isEmpty,
            ) ||
            (group['colorToken'] != null && group['colorToken'] is! String)) {
          throw const FormatException('Malformed VEIL group.');
        }
      }
    }

    final anchors = json['anchors'];
    if (anchors != null) {
      if (anchors is! List) {
        throw const FormatException('Malformed VEIL anchors.');
      }
      for (final anchor in anchors) {
        if (anchor is! Map<String, dynamic> ||
            anchor['id'] is! String ||
            (anchor['id'] as String).isEmpty ||
            (anchor['label'] != null && anchor['label'] is! String) ||
            (anchor['kind'] != null &&
                !{'manual', 'cue', 'bookmark'}.contains(anchor['kind']))) {
          throw const FormatException('Malformed VEIL anchor.');
        }
      }
    }
  }

  static void _validateSubtitleCover(dynamic value) {
    if (value == null) return;
    if (value is! Map<String, dynamic> ||
        !{'show', 'smartCover', 'regionCover'}.contains(value['mode'])) {
      throw const FormatException('Malformed VEIL subtitle cover.');
    }
    final rect = value['regionRect'];
    if (rect == null) return;
    if (rect is! Map<String, dynamic>) {
      throw const FormatException('Malformed VEIL subtitle cover.');
    }
    final x = rect['xPercent'];
    final y = rect['yPercent'];
    final width = rect['widthPercent'];
    final height = rect['heightPercent'];
    if (x is! num ||
        y is! num ||
        width is! num ||
        height is! num ||
        !x.isFinite ||
        !y.isFinite ||
        !width.isFinite ||
        !height.isFinite ||
        x < 0 ||
        y < 0 ||
        width < 1 ||
        height < 1 ||
        x + width > 100 ||
        y + height > 100) {
      throw const FormatException('Malformed VEIL subtitle cover.');
    }
  }

  static void _validateMask(Map<String, dynamic> item) {
    final rect = item['rect'];
    final style = item['style'];
    final source = item['source'];
    if (rect is! Map<String, dynamic> ||
        (style != null && style is! Map<String, dynamic>) ||
        (source != null &&
            (source is! Map<String, dynamic> ||
                !{'manual', 'srt'}.contains(source['kind'])))) {
      throw const FormatException('Malformed VEIL mask.');
    }
    final values = [
      'xPercent',
      'yPercent',
      'widthPercent',
      'heightPercent',
    ].map((key) => rect[key]).toList();
    var styleValid = true;
    if (style is Map<String, dynamic>) {
      final mode = style['mode'];
      final color = style['color'];
      final opacity = style['opacity'];
      styleValid =
          mode == 'solid' &&
          color is String &&
          color.isNotEmpty &&
          (opacity == null ||
              opacity is num &&
                  opacity.isFinite &&
                  opacity >= 0 &&
                  opacity <= 1);
    }
    if (values.any((v) => v is! num || !v.isFinite) ||
        values[0] < 0 ||
        values[1] < 0 ||
        values[2] < 1 ||
        values[3] < 1 ||
        values[0] + values[2] > 100 ||
        values[1] + values[3] > 100 ||
        !styleValid) {
      throw const FormatException('Invalid VEIL mask geometry or style.');
    }
    for (final key in ['fadeInMs', 'fadeOutMs']) {
      final value = item[key];
      if (value != null &&
          (value is! num || !value.isFinite || value < 0 || value > 5000)) {
        throw const FormatException('Invalid VEIL mask transition.');
      }
    }
  }

  static Map<String, dynamic> _toDesktopJson(VeilTrack track) {
    final now = DateTime.now().toUtc();
    final knownItems = [
      for (final segment in track.segments)
        if (_isDesktopExportableType(segment.type))
          _segmentToDesktopItem(segment),
    ];
    final map = <String, dynamic>{
      'version': VeilTrack.desktopFormatVersion,
      'app': desktopAppId,
      'appVersion': track.appVersion ?? mobileExportAppVersion,
      'exportedAt': now.toIso8601String(),
      'video': _buildVideoJson(track),
      'globalOffsetSeconds': _desktopNumber(track.globalOffsetSeconds ?? 0),
      'trackMetadata': _normalizedTrackMetadata(track),
      'items': _orderedDesktopItems(track, knownItems),
      'subtitleCover': Map<String, dynamic>.from(
        track.subtitleCover ?? _defaultSubtitleCover,
      ),
    };

    if (track.rawExtra != null) {
      for (final entry in track.rawExtra!.entries) {
        if (entry.key != _unknownItemsKey && entry.key != _itemOrderKey) {
          map.putIfAbsent(entry.key, () => entry.value);
        }
      }
    }

    return map;
  }

  static List<dynamic> _orderedDesktopItems(
    VeilTrack track,
    List<Map<String, dynamic>> knownItems,
  ) {
    final order = track.rawExtra?[_itemOrderKey];
    if (order is! List) {
      return [
        ...((track.rawExtra?[_unknownItemsKey] as List?) ?? const []),
        ...knownItems,
      ];
    }
    final output = <dynamic>[];
    final emittedKnown = <int>{};
    for (final slot in order.whereType<Map>()) {
      final knownIndex = slot['knownIndex'];
      if (knownIndex is int &&
          knownIndex >= 0 &&
          knownIndex < knownItems.length) {
        output.add(knownItems[knownIndex]);
        emittedKnown.add(knownIndex);
      } else if (slot['unknown'] is Map) {
        output.add(Map<String, dynamic>.from(slot['unknown'] as Map));
      }
    }
    for (var index = 0; index < knownItems.length; index++) {
      if (!emittedKnown.contains(index)) {
        output.add(knownItems[index]);
      }
    }
    return output;
  }

  static Map<String, dynamic> _normalizedTrackMetadata(VeilTrack track) {
    final metadata = <String, dynamic>{
      ...?track.trackMetadata,
      'createdAt': track.createdAt.toUtc().toIso8601String(),
      'updatedAt': track.updatedAt.toUtc().toIso8601String(),
    };
    final downloads = metadata['downloads'];
    if (downloads is num && downloads.isFinite && downloads >= 0) {
      metadata['downloads'] = downloads.floor();
    }
    final rating = metadata['rating'];
    if (rating == null || rating is String && rating.isEmpty) {
      metadata.remove('rating');
    }
    return metadata;
  }

  static Map<String, dynamic> _buildVideoJson(VeilTrack track) {
    final existingFingerprint = track.video?['fingerprint'];
    final isUnbound =
        track.video?['binding'] == 'unbound' ||
        existingFingerprint is Map &&
            existingFingerprint['method'] == 'manual-unbound';
    final name = isUnbound
        ? track.videoName ?? ''
        : (track.videoName?.trim().isNotEmpty ?? false)
        ? track.videoName!
        : 'Unknown video';
    final duration = track.videoDurationSeconds ?? 0.0;
    final fileSize = track.videoFileSize;
    final width = track.videoWidth ?? 0;
    final height = track.videoHeight ?? 0;

    final fingerprint = isUnbound
        ? <String, dynamic>{
            if (existingFingerprint is Map)
              ...Map<String, dynamic>.from(existingFingerprint),
            'method': 'manual-unbound',
            'value':
                existingFingerprint is Map &&
                    existingFingerprint['value'] is String &&
                    (existingFingerprint['value'] as String).isNotEmpty
                ? existingFingerprint['value']
                : 'manual-unbound',
          }
        : <String, dynamic>{
            if (existingFingerprint is Map)
              ...Map<String, dynamic>.from(existingFingerprint),
            ..._buildFingerprint(
              name: name,
              duration: duration,
              fileSize: fileSize,
              width: width,
              height: height,
            ),
          };

    final existingResolution = track.video?['resolution'];
    final resolution = <String, dynamic>{
      if (existingResolution is Map)
        ...Map<String, dynamic>.from(existingResolution),
      'width': width,
      'height': height,
    };

    final video = <String, dynamic>{
      'name': name,
      'duration': duration,
      'fileSize': fileSize,
      'resolution': resolution,
      'fingerprint': fingerprint,
      'binding': fingerprint['method'] == 'manual-unbound'
          ? 'unbound'
          : 'metadata',
    };

    if (track.video != null) {
      for (final entry in track.video!.entries) {
        video.putIfAbsent(entry.key, () => entry.value);
      }
      video['name'] = name;
      video['duration'] = duration;
      video['fileSize'] = fileSize;
      video['resolution'] = resolution;
      video['fingerprint'] = fingerprint;
      video['binding'] = fingerprint['method'] == 'manual-unbound'
          ? 'unbound'
          : 'metadata';
    }

    return video;
  }

  static Map<String, dynamic> _buildFingerprint({
    required String name,
    required double duration,
    required num? fileSize,
    required num width,
    required num height,
  }) {
    final hasMetadata = name.isNotEmpty && name != 'Unknown video';

    if (hasMetadata) {
      return {
        'method': 'metadata-v1',
        'value': _metadataFingerprintValue(
          name: name,
          fileSize: fileSize,
          duration: duration,
          width: width,
          height: height,
        ),
      };
    }

    return {'method': 'manual-unbound', 'value': name};
  }

  /// Returns true for an exact bound-media match, false for a mismatch, and
  /// null when the track is intentionally unbound or metadata is incomplete.
  static bool? mediaIdentityMatches({
    required VeilTrack track,
    required String fileName,
    required int fileSize,
    required double durationSeconds,
    required int width,
    required int height,
    String? loadedFingerprintValue,
  }) {
    final status = classifyMediaIdentity(
      track: track,
      fileName: fileName,
      fileSize: fileSize,
      durationSeconds: durationSeconds,
      width: width,
      height: height,
      loadedFingerprintValue: loadedFingerprintValue,
    );
    return switch (status) {
      VeilMediaIdentityStatus.match => true,
      VeilMediaIdentityStatus.mismatch => false,
      VeilMediaIdentityStatus.unknown => null,
    };
  }

  static VeilMediaIdentityStatus classifyMediaIdentity({
    required VeilTrack track,
    required String fileName,
    required num? fileSize,
    required double durationSeconds,
    required num width,
    required num height,
    String? loadedFingerprintValue,
  }) {
    final video = track.video;
    final fingerprint = video?['fingerprint'];
    if (fingerprint is! Map<String, dynamic> ||
        fingerprint['method'] == 'manual-unbound') {
      return VeilMediaIdentityStatus.unknown;
    }
    if (fingerprint['method'] != 'metadata-v1' ||
        fingerprint['value'] is! String ||
        (fingerprint['method'] == 'metadata-v1' &&
            (fingerprint['value'] as String).isEmpty) ||
        track.videoName == null ||
        track.videoDurationSeconds == null ||
        track.videoWidth == null ||
        track.videoHeight == null) {
      return VeilMediaIdentityStatus.unknown;
    }

    final trackName = track.videoName!;
    final selectedName = _fileNameOnly(fileName);
    final durationMatches =
        (track.videoDurationSeconds! - durationSeconds).abs() <= 0.5;
    final expected = _metadataFingerprintValue(
      name: trackName,
      fileSize: track.videoFileSize,
      duration: track.videoDurationSeconds!,
      width: track.videoWidth!,
      height: track.videoHeight!,
    );
    final actual = _metadataFingerprintValue(
      name: selectedName,
      fileSize: fileSize,
      duration: durationSeconds,
      width: width,
      height: height,
    );
    final matches =
        trackName == selectedName &&
        track.videoFileSize == fileSize &&
        durationMatches &&
        track.videoWidth == width &&
        track.videoHeight == height &&
        fingerprint['value'] == expected &&
        fingerprint['value'] == actual &&
        (loadedFingerprintValue == null ||
            loadedFingerprintValue == fingerprint['value']);
    return matches
        ? VeilMediaIdentityStatus.match
        : VeilMediaIdentityStatus.mismatch;
  }

  static String _metadataFingerprintValue({
    required String name,
    required num? fileSize,
    required double duration,
    required num width,
    required num height,
  }) {
    final milliseconds = (duration * 1000 + 0.5).floor();
    final seconds = milliseconds ~/ 1000;
    final millis = (milliseconds % 1000).toString().padLeft(3, '0');
    return '$name|${fileSize == null ? 'null' : _canonicalDecimal(fileSize)}|'
        '$seconds.$millis|${_canonicalDecimal(width)}|${_canonicalDecimal(height)}';
  }

  static String _canonicalDecimal(num value) {
    if (!value.isFinite) {
      throw const FormatException('Canonical decimal must be finite.');
    }
    if (value == 0) return '0';
    final raw = value.toString();
    final exponentIndex = raw.indexOf(RegExp('[eE]'));
    if (exponentIndex < 0) {
      if (!raw.contains('.')) return raw;
      return raw
          .replaceFirst(RegExp(r'\.0+$'), '')
          .replaceFirst(RegExp(r'(\.\d*?[1-9])0+$'), r'$1');
    }
    final negative = raw.startsWith('-');
    final unsigned = negative ? raw.substring(1) : raw;
    final parts = unsigned.split(RegExp('[eE]'));
    final exponent = int.parse(parts[1]);
    final mantissa = parts[0];
    final dot = mantissa.indexOf('.');
    final digits = mantissa.replaceAll('.', '');
    final decimalPosition = (dot < 0 ? digits.length : dot) + exponent;
    final expanded = decimalPosition <= 0
        ? '0.${List.filled(-decimalPosition, '0').join()}$digits'
        : decimalPosition >= digits.length
        ? '$digits${List.filled(decimalPosition - digits.length, '0').join()}'
        : '${digits.substring(0, decimalPosition)}.'
              '${digits.substring(decimalPosition)}';
    return negative ? '-$expanded' : expanded;
  }

  static String _fileNameOnly(String value) {
    final normalized = value.replaceAll('\\', '/');
    return normalized.substring(normalized.lastIndexOf('/') + 1);
  }

  static bool _isDesktopExportableType(VeilSegmentType type) {
    return switch (type) {
      VeilSegmentType.mask ||
      VeilSegmentType.mute ||
      VeilSegmentType.skip ||
      VeilSegmentType.bookmark => true,
      VeilSegmentType.marker => false,
    };
  }

  static Map<String, dynamic> _segmentToDesktopItem(VeilSegment segment) {
    final item = <String, dynamic>{
      'id': segment.id,
      'type': segment.type.toJson(),
      'enabled': segment.enabled,
      'start': _secondsFromMs(segment.startMs),
      'end': _secondsFromMs(segment.endMs),
    };

    if (segment.label != null && segment.label!.isNotEmpty) {
      item['label'] = segment.label;
    }
    if (segment.notes != null && segment.notes!.isNotEmpty) {
      item['notes'] = segment.notes;
    }
    if (segment.rawExtra != null) {
      for (final entry in segment.rawExtra!.entries) {
        item.putIfAbsent(entry.key, () => entry.value);
      }
    }

    return switch (segment.type) {
      VeilSegmentType.mask => {
        ...item,
        'rect': _desktopRect(segment.rect),
        'style': _desktopStyle(segment.style),
        'source': _desktopSource(segment.source),
      },
      VeilSegmentType.mute || VeilSegmentType.skip => item,
      VeilSegmentType.bookmark => item,
      VeilSegmentType.marker => throw StateError(
        'Marker segments are omitted from desktop export.',
      ),
    };
  }

  static Map<String, dynamic> _desktopRect(Map<String, dynamic>? rect) {
    final source = rect ?? VeilSegment.defaultRect;
    return {
      ...source,
      'xPercent': _rectPercent(
        source['xPercent'],
        VeilSegment.defaultRect['xPercent']!,
      ),
      'yPercent': _rectPercent(
        source['yPercent'],
        VeilSegment.defaultRect['yPercent']!,
      ),
      'widthPercent': _rectPercent(
        source['widthPercent'],
        VeilSegment.defaultRect['widthPercent']!,
      ),
      'heightPercent': _rectPercent(
        source['heightPercent'],
        VeilSegment.defaultRect['heightPercent']!,
      ),
    };
  }

  static Map<String, dynamic> _desktopSource(Map<String, dynamic>? source) {
    if (source != null && {'manual', 'srt'}.contains(source['kind'])) {
      return Map<String, dynamic>.from(source);
    }
    return const {'kind': 'manual'};
  }

  static Map<String, dynamic> _desktopStyle(Map<String, dynamic>? style) {
    final source = style ?? VeilSegment.defaultStyle;
    return {
      ...source,
      'mode': source['mode'] ?? VeilSegment.defaultStyle['mode'],
      'color': source['color'] ?? VeilSegment.defaultStyle['color'],
      'opacity': _desktopNumber(
        (source['opacity'] as num?) ?? VeilSegment.defaultStyle['opacity']!,
      ),
    };
  }

  static double _rectPercent(dynamic value, num fallback) {
    if (value is num) {
      return value.toDouble();
    }
    return fallback.toDouble();
  }

  static num _secondsFromMs(int ms) {
    final seconds = ms / 1000;
    if (seconds == seconds.roundToDouble()) {
      return seconds.round();
    }
    return double.parse(seconds.toStringAsFixed(3));
  }

  static num _desktopNumber(num value) {
    if (value is int) {
      return value;
    }
    if (value == value.roundToDouble()) {
      return value.round();
    }
    return value;
  }

  static Map<String, dynamic>? _extractOptionalCollections(
    Map<String, dynamic> source,
    List<dynamic> items,
  ) {
    final preserved = <String, dynamic>{};
    final validItemIds = items
        .whereType<Map<String, dynamic>>()
        .map((item) => item['id'])
        .whereType<String>()
        .where((id) => id.isNotEmpty)
        .toSet();
    final groups = source['groups'];
    if (groups is List && groups.isNotEmpty) {
      final seenItemIds = <String>{};
      preserved['groups'] = [
        for (final value in groups.whereType<Map<String, dynamic>>())
          <String, dynamic>{
            ...value,
            'label': (value['label'] as String).trim().isEmpty
                ? 'Group'
                : (value['label'] as String).trim(),
            'itemIds': [
              for (final id in (value['itemIds'] as List).whereType<String>())
                if (validItemIds.contains(id) && seenItemIds.add(id)) id,
            ],
          }..removeWhere(
            (key, value) =>
                key == 'colorToken' &&
                !{'g1', 'g2', 'g3', 'g4', 'g5', 'g6'}.contains(value),
          ),
      ];
    }
    final anchors = source['anchors'];
    if (anchors is List && anchors.isNotEmpty) {
      preserved['anchors'] = [
        for (final value in anchors.whereType<Map<String, dynamic>>())
          if (value['time'] is num &&
              (value['time'] as num).isFinite &&
              (value['time'] as num) >= 0)
            _normalizedAnchor(value),
      ];
    }
    return preserved.isEmpty ? null : preserved;
  }

  static Map<String, dynamic> _normalizedAnchor(Map<String, dynamic> source) {
    final anchor = <String, dynamic>{...source};
    final label = anchor['label'];
    if (label is String) {
      final trimmed = label.trim();
      if (trimmed.isEmpty) {
        anchor.remove('label');
      } else {
        anchor['label'] = trimmed;
      }
    }
    return anchor;
  }

  static Map<String, dynamic>? _extractUnknownKeys(
    Map<String, dynamic> source,
    Set<String> knownKeys,
  ) {
    final extra = <String, dynamic>{};
    for (final entry in source.entries) {
      if (!knownKeys.contains(entry.key)) {
        extra[entry.key] = entry.value;
      }
    }
    return extra.isEmpty ? null : extra;
  }

  static Map<String, dynamic>? _cloneMap(dynamic value) {
    if (value is! Map) {
      return null;
    }
    return Map<String, dynamic>.from(value);
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value is! String || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }
}
