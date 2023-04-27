import 'dart:async';

import 'package:flutter/services.dart';

class SecureApplicationNative {
  static const MethodChannel _channel =
      const MethodChannel('secure_application');

  /// Implemented only in windows
  static void registerForEvents(VoidCallback lock, VoidCallback unlock) {
    _channel.setMethodCallHandler(
        (call) => secureApplicationHandler(call, lock, unlock));
  }

  static Future<void> secureApplicationHandler(
    MethodCall methodCall,
    VoidCallback lock,
    VoidCallback unlock,
  ) async {
    switch (methodCall.method) {
      case 'lock':
        lock();
        break;
      case 'unlock':
        unlock();
        break;
      default:
        throw MissingPluginException('notImplemented');
    }
  }

  /// App will be secured and content will not be visible if user switch app
  ///
  /// on Android this will also prevent screenshot/screen recording
  static Future<void> secure() {
    return _channel.invokeMethod('secure');
  }

  /// App will no longer be secured and content will be visible if user switch app
  static Future<void> open() {
    return _channel.invokeMethod('open');
  }

  /// Temporary prevent the app from locking if use leave and come back to the app
  @Deprecated('It never did anything')
  static Future<void> lock() async {}

  /// Use when you want your user to see content
  @Deprecated('It never did anything')
  static Future<void> unlock() async {}

  /// Only work on ios
  static Future<void> opacity(double opacity) {
    return _channel.invokeMethod('opacity', {'opacity': opacity});
  }
}
