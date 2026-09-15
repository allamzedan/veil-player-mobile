import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veil_mobile/app/open_intent_handler.dart';

/// Initializes Android open-intent handling without affecting normal launch.
class OpenIntentBootstrap extends ConsumerStatefulWidget {
  const OpenIntentBootstrap({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<OpenIntentBootstrap> createState() =>
      _OpenIntentBootstrapState();
}

class _OpenIntentBootstrapState extends ConsumerState<OpenIntentBootstrap> {
  OpenIntentHandler? _handler;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _handler = ref.read(openIntentHandlerProvider);
      unawaited(_handler!.initialize(context));
    });
  }

  @override
  void dispose() {
    _handler?.dispose();
    _handler = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
