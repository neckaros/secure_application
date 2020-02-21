import 'package:flutter/foundation.dart';
import 'package:secure_window/secure_window.dart';

/// main controller for the library
///
/// secured mean that the application will lock if the user switch out of the app
/// on Android it will prevent user from taking screenshot/recordvideo in the app
/// on iOS/Android it will hide content in the app switcher
/// on iOS/Android it will lock [SecureWindowController.locked] = true when it become active again
/// when locked if a gate depends on this controller it will display the blurry gate to obfuscate content
class SecureWindowController extends ValueNotifier<SecureWindowState> {
  SecureWindowController(SecureWindowState value) : super(value);

  bool get locked => value.locked;
  bool get secured => value.secured;

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

  /// App will be secured and content will not be visible if user switch app
  void resumed() {
    notifyListeners();
  }

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
}

@immutable
class SecureWindowState {
  final bool locked;
  final bool secured;
  SecureWindowState({this.locked = false, this.secured = false});

  SecureWindowState copyWith({bool locked, bool secured}) {
    return SecureWindowState(
      locked: locked ?? this.locked,
      secured: secured ?? this.secured,
    );
  }
}
