import 'package:flutter/foundation.dart';

/// state hold by the [SecureWindowController]
@immutable
class SecureWindowState {
  final bool locked;
  final bool secured;
  final bool paused;
  SecureWindowState({
    this.locked = false,
    this.secured = false,
    this.paused = false,
  });

  SecureWindowState copyWith({
    bool locked,
    bool secured,
    bool paused,
  }) {
    return SecureWindowState(
      locked: locked ?? this.locked,
      secured: secured ?? this.secured,
      paused: paused ?? this.paused,
    );
  }
}
