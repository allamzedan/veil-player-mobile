import 'dart:async';

import 'package:flutter/material.dart';
import 'package:veil_mobile/shared/widgets/app_brand_mark.dart';

/// Holds the native splash visible for a minimum duration on cold start only.
class ColdStartSplashGate extends StatefulWidget {
  const ColdStartSplashGate({super.key, required this.child});

  static const Duration holdDuration = Duration(milliseconds: 900);

  final Widget child;

  @override
  State<ColdStartSplashGate> createState() => _ColdStartSplashGateState();
}

class _ColdStartSplashGateState extends State<ColdStartSplashGate> {
  static bool _coldStartHandled = false;

  bool _visible = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (!_coldStartHandled) {
      _coldStartHandled = true;
      _visible = true;
      _timer = Timer(ColdStartSplashGate.holdDuration, () {
        if (mounted) {
          setState(() => _visible = false);
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (_visible)
          const IgnorePointer(
            child: ColoredBox(
              color: Color(0xFF121212),
              child: Center(child: AppBrandMark(size: 72)),
            ),
          ),
      ],
    );
  }
}
