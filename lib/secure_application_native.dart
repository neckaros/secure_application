import 'dart:async';

import 'package:flutter/services.dart';

class SecureApplicationNative {
  static const MethodChannel _channel =
      const MethodChannel('secure_application');

  static void registerForEvents(VoidCallback lock, VoidCallback unlock) {
    _channel.setMethodCallHandler(
        (call) => secureApplicationHandler(call, lock, unlock));
  }

  static Future<dynamic> secureApplicationHandler(
      MethodCall methodCall, lock, unlock) async {
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

  static Future opacity(double opacity) {
    return _channel.invokeMethod('opacity', {"opacity": opacity});
  }
}
