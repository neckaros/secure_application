import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:secure_window/secure_window.dart';
import 'package:secure_window/secure_window_state.dart';

enum SecureWindowAuthenticationStatus { SUCCESS, FAILED, NONE }

/// main controller for the library
///
/// secured mean that the application will lock if the user switch out of the app
/// on Android it will prevent user from taking screenshot/recordvideo in the app
/// on iOS/Android it will hide content in the app switcher
/// on iOS/Android it will lock [SecureWindowController.locked] = true when it become active again
/// when locked if a gate depends on this controller it will display the blurry gate to obfuscate content
class SecureWindowController extends ValueNotifier<SecureWindowState> {
  SecureWindowController(SecureWindowState value) : super(value);

  final StreamController<SecureWindowAuthenticationStatus>
      _authenticationEventsController =
      StreamController<SecureWindowAuthenticationStatus>.broadcast();

  /// Broadcast stream that you can use to trigger succesffull or unsuccessfull event
  ///
  /// will trigger with the result of [SecureApllication.onNeedUnlock]
  /// ```dart
  /// secureWindowContrller.authentificationEvents.
  Stream<SecureWindowAuthenticationStatus> get authenticationEvents =>
      _authenticationEventsController.stream;

  /// Is the application Locked
  /// if locked gates will hide their children content
  /// will be automatically set to yes when user switch back to app
  /// can be triggered with [lock()] manually to activates gates on your own volution
  bool get locked => value.locked;

  /// Is the application secured
  bool get secured => value.secured;

  /// notify listener of the [SecureWindowController.authenticationEvents] of a failure or success
  /// to allow them for example to clear sensitive data
  void sendAuthenticationEvent(SecureWindowAuthenticationStatus status) {
    _authenticationEventsController.add(status);
  }

  void authFailed({bool unlock = false}) {
    _authenticationEventsController
        .add(SecureWindowAuthenticationStatus.FAILED);
    if (unlock) {
      this.unlock();
    }
  }

  void authSuccess({bool unlock = false}) {
    _authenticationEventsController
        .add(SecureWindowAuthenticationStatus.SUCCESS);
    if (unlock) {
      this.unlock();
    }
  }

  /// content under [SecureGate] will not be visible
  void lock() {
    SecureWindow.lock();
    if (!value.locked) {
      value = value.copyWith(locked: true);
      notifyListeners();
    }
  }

  /// Use when you want your user to see content under [SecureGate]
  void unlock() {
    SecureWindow
        .unlock(); //lock from native is removed when resumed but why not!
    if (value.locked) {
      value = value.copyWith(locked: false);
      notifyListeners();
    }
  }

  /// Use to warn gates that the app resumed
  /// used internally only
  void resumed() {
    notifyListeners();
  }

  /// App will be secured and content will not be visible if user switch app
  ///
  /// on Android this will also prevent scrensshot/screen recording
  void secure() {
    SecureWindow.secure();
    if (!value.secured) {
      value = value.copyWith(secured: true);
      notifyListeners();
    }
  }

  /// App will no longer be secured and content will be visible if user switch app
  void open() {
    SecureWindow.open();
    if (value.secured) {
      value = value.copyWith(secured: false);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authenticationEventsController.close();
    super.dispose();
  }
}
