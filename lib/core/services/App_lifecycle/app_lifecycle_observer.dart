import 'package:flutter/material.dart';

class AppLifecycleObserver with WidgetsBindingObserver {
  bool _isForeground = true;

  bool get isForeground => _isForeground;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _isForeground = state == AppLifecycleState.resumed;
  }
}
