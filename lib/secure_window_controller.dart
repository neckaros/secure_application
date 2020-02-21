import 'package:flutter/foundation.dart';
import 'package:secure_window/secure_window.dart';
import 'package:secure_window/secure_window_state.dart';

/// main controller for the library
///
/// secured mean that the application will lock if the user switch out of the app
/// on Android it will prevent user from taking screenshot/recordvideo in the app
/// on iOS/Android it will hide content in the app switcher
/// on iOS/Android it will lock [SecureWindowController.locked] = true when it become active again
/// when locked if a gate depends on this controller it will display the blurry gate to obfuscate content
class SecureWindowController extends ValueNotifier<SecureWindowState> {
  SecureWindowController(SecureWindowState value) : super(value);

  /// Is the application Locked
  /// if locked gates will hide their children content
  /// will be automatically set to yes when user switch back to app
  /// can be triggered with [lock()] manually to activates gates on your own volution
  bool get locked => value.locked;

  /// Is the application secured
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
}
