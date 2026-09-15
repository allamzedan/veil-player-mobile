import 'dart:async';

import 'package:flutter/services.dart';

import 'open_intent_payload.dart';

const MethodChannel _methodChannel = MethodChannel('veil_mobile/open_intent');
const EventChannel _eventChannel = EventChannel(
  'veil_mobile/open_intent_events',
);

Future<OpenIntentPayload?> getInitialAndroidOpenIntent() async {
  try {
    final result = await _methodChannel.invokeMethod<Map<dynamic, dynamic>?>(
      'getInitialOpenIntent',
    );
    if (result == null || result['uri'] == null) {
      return null;
    }
    return OpenIntentPayload.fromMap(result);
  } on MissingPluginException {
    return null;
  } on PlatformException {
    return null;
  }
}

Stream<OpenIntentPayload> watchAndroidOpenIntents() {
  return _eventChannel
      .receiveBroadcastStream()
      .map((event) {
        if (event is Map) {
          return OpenIntentPayload.fromMap(event);
        }
        return const OpenIntentPayload(uri: '');
      })
      .where((payload) => payload.uri.isNotEmpty)
      .handleError((_) {});
}

Future<String?> resolveAndroidOpenablePath(String uri) async {
  try {
    return _methodChannel.invokeMethod<String?>('resolveOpenablePath', {
      'uri': uri,
    });
  } on MissingPluginException {
    return null;
  } on PlatformException {
    return null;
  }
}

Future<int?> queryAndroidOpenableSize(String uri) async {
  try {
    final size = await _methodChannel.invokeMethod<int?>('queryOpenableSize', {
      'uri': uri,
    });
    if (size == null || size <= 0) {
      return null;
    }
    return size;
  } on MissingPluginException {
    return null;
  } on PlatformException {
    return null;
  }
}
