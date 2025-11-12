import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:secure_application/secure_application_native.dart';
import 'package:secure_application/secure_application_state.dart';

enum SecureApplicationAuthenticationStatus { SUCCESS, FAILED, LOGOUT, NONE }

/// main controller for the library
///
/// secured mean that the application will lock if the user switch out of the app
/// on Android it will prevent user from taking screenshot/recordvideo in the app
/// on iOS/Android it will hide content in the app switcher
/// on iOS/Android it will lock [SecureApplicationController.locked] = true when it become active again
/// when locked if a gate depends on this controller it will display the blurry gate to obfuscate content
class SecureApplicationController
    extends ValueNotifier<SecureApplicationState> {
  SecureApplicationController(SecureApplicationState value) : super(value);

  final BehaviorSubject<SecureApplicationAuthenticationStatus>
      _authenticationEventsController =
      BehaviorSubject<SecureApplicationAuthenticationStatus>.seeded(
          SecureApplicationAuthenticationStatus.NONE);

  /// Broadcast stream that you can use to react to succesffull or unsuccessfull event
  /// default to [SecureApplicationAuthenticationStatus.NONE]
  /// [BehaviorSubject] stream so it will always emit last sent value as soon as you listen
  /// will trigger with the result of [SecureApllication.onNeedUnlock]
  Stream<SecureApplicationAuthenticationStatus> get authenticationEvents =>
      _authenticationEventsController.stream;

  final BehaviorSubject<bool> _lockEventsController =
      BehaviorSubject<bool>.seeded(false);

  /// Broadcast stream that you can use to react to lock/unlock event
  /// default to [false]
  /// [BehaviorSubject] stream so it will always emit last sent value as soon as you listen
  Stream<bool> get lockEvents => _lockEventsController.stream;

  /// Is the application Locked
  /// if locked gates will hide their children content
  /// will be automatically set to yes when user switch back to app
  /// can be triggered with [lock()] manually to activates gates on your own volution
  bool get locked => value.locked;

  /// Is the application secured
  bool get secured => value.secured;

  /// if paused lock will not be set when they get back to the app
  /// could be usefull for example when you open an image or file picker
  bool get paused => value.paused;

  /// helper that hold las authentication status
  /// default to false
  /// allow you to hide or show content depending on authentication status
  bool get authenticated => value.authenticated;

  /// notify listener of the [SecureApplicationController.authenticationEvents] of a failure or success
  /// to allow them for example to clear sensitive data
  void sendAuthenticationEvent(SecureApplicationAuthenticationStatus status) {
    _authenticationEventsController.add(status);
  }

  void authFailed({bool unlock = false}) {
    value = value.copyWith(authenticated: false);
    _authenticationEventsController
        .add(SecureApplicationAuthenticationStatus.FAILED);
    if (unlock) {
      this.unlock();
    }
    notifyListeners();
  }

  void authSuccess({bool unlock = false}) {
    value = value.copyWith(authenticated: true);
    _authenticationEventsController
        .add(SecureApplicationAuthenticationStatus.SUCCESS);
    if (unlock) {
      this.unlock();
    }
    notifyListeners();
  }

  void authLogout({bool unlock = false}) {
    value = value.copyWith(authenticated: false);
    _authenticationEventsController
        .add(SecureApplicationAuthenticationStatus.LOGOUT);
    if (unlock) {
      this.unlock();
    }
    notifyListeners();
  }

  /// content under [SecureGate] will not be visible
  void lock() {
    if (!value.locked) {
      value = value.copyWith(locked: true);
      notifyListeners();
      _lockEventsController.add(true);
    }
  }

  void lockIfSecured() {
    if (value.secured) lock();
  }

  /// Use when you want your user to see content under [SecureGate]
  void unlock() {
    if (value.locked) {
      value = value.copyWith(locked: false);
      notifyListeners();
      _lockEventsController.add(false);
    }
  }

  /// temporary prevent the app from locking if use leave and come back to the app
  void pause() {
    if (!value.paused) {
      value = value.copyWith(paused: true);
      notifyListeners();
    }
  }

  /// app switching will again provoque a lock
  void unpause() {
    if (value.paused) {
      value = value.copyWith(paused: false);
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
  /// on Android this will also prevent screenshot/screen recording
  void secure() {
    SecureApplicationNative.secure();
    if (!value.secured) {
      value = value.copyWith(secured: true);
      notifyListeners();
    }
  }

  /// App will no longer be secured and content will be visible if user switch app
  void open() {
    SecureApplicationNative.open();
    if (value.secured) {
      value = value.copyWith(secured: false);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authenticationEventsController.close();
    _lockEventsController.close();
    super.dispose();
  }
}
