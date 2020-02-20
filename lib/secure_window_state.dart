import 'package:flutter/foundation.dart';
import 'package:secure_window/secure_window.dart';

class SecureWindowStateNotifier extends ValueNotifier<SecureWindowState> {
  SecureWindowStateNotifier(SecureWindowState value) : super(value);

  bool get locked => value.locked;
  bool get secured => value.secured;

  void lock() {
    SecureWindow.lock();
    if (!value.locked) {
      value = value.copyWith(locked: true);
      notifyListeners();
    }
  }

  void unlock() {
    SecureWindow.unlock();
    if (value.locked) {
      value = value.copyWith(locked: false);
      notifyListeners();
    }
  }

  void secure() {
    SecureWindow.secure();
    if (!value.secured) {
      value = value.copyWith(secured: true);
      notifyListeners();
    }
  }

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
