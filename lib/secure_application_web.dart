import 'dart:async';
// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html show window, document, Event;

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

/// A web implementation of the SecureApplication plugin.
class SecureApplicationWeb {
  bool secured = false;
  StreamSubscription<html.Event>? onVC;
  final MethodChannel _channel;
  SecureApplicationWeb(this._channel);

  void secureApplication() {
    onVC?.cancel();
    onVC = html.document.onVisibilityChange.listen(visibilityEvent);
    secured = true;
  }

  void visibilityEvent(html.Event e) {
    if (html.document.visibilityState == 'hidden')
      _channel.invokeMethod('lock', 'web');
  }

  void unsecureApplication() {
    onVC?.cancel();
    secured = false;
  }

  static void registerWith(Registrar registrar) {
    final MethodChannel channel = MethodChannel(
      'secure_application',
      const StandardMethodCodec(),
      registrar,
    );

    final pluginInstance = SecureApplicationWeb(channel);
    channel.setMethodCallHandler(pluginInstance.handleMethodCall);
  }

  /// Handles method calls over the MethodChannel of this plugin.
  /// Note: Check the "federated" architecture for a new way of doing this:
  /// https://flutter.dev/go/federated-plugins
  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'secure':
        secureApplication();
        return true;
      case 'open':
        unsecureApplication();
        return true;
      default:
        return true;
      // throw PlatformException(
      //   code: 'Unimplemented',
      //   details: 'secure_application for web doesn\'t implement \'${call.method}\'',
      // );
    }
  }

  /// Returns a [String] containing the version of the platform.
  Future<String> getPlatformVersion() {
    final version = html.window.navigator.userAgent;
    return Future.value(version);
  }
}
