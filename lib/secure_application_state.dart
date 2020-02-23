import 'package:flutter/foundation.dart';

/// state hold by the [SecureApplicationController]
@immutable
class SecureApplicationState {
  final bool locked;
  final bool secured;
  final bool paused;
  SecureApplicationState({
    this.locked = false,
    this.secured = false,
    this.paused = false,
  });

  SecureApplicationState copyWith({
    bool locked,
    bool secured,
    bool paused,
  }) {
    return SecureApplicationState(
      locked: locked ?? this.locked,
      secured: secured ?? this.secured,
      paused: paused ?? this.paused,
    );
  }
}
