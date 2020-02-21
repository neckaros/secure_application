import 'package:flutter/foundation.dart';

/// state hold by the [SecureWindowController]
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
