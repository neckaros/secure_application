import 'dart:async';
export './secure_application.dart';
export './secure_gate.dart';
export './secure_window_provider.dart';
export './secure_window_state.dart';

import 'package:flutter/services.dart';

class SecureWindow {
  static const MethodChannel _channel = const MethodChannel('secure_window');

  static Future secure() {
    return _channel.invokeMethod('secure');
  }

  static Future open() {
    return _channel.invokeMethod('open');
  }

  static Future lock() {
    return _channel.invokeMethod('lock');
  }

  static Future unlock() {
    return _channel.invokeMethod('unlock');
  }
}
