import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Android immersive fullscreen: landscape + hidden system bars.
abstract final class PlayerFullscreenMode {
  static bool get isSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static const List<DeviceOrientation> _landscapeOrientations = [
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ];

  static const List<DeviceOrientation> _restoredOrientations = [
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ];

  static Future<void> enter() async {
    if (!isSupported) {
      return;
    }
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    await SystemChrome.setPreferredOrientations(_landscapeOrientations);
  }

  static Future<void> exit() async {
    if (!isSupported) {
      return;
    }
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await SystemChrome.setPreferredOrientations(_restoredOrientations);
  }
}
