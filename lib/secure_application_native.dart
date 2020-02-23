import 'dart:async';

import 'package:flutter/services.dart';

class SecureApplicationNative {
  static const MethodChannel _channel =
      const MethodChannel('secure_application');

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
