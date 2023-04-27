import 'package:flutter/foundation.dart';

/// state hold by the [SecureApplicationController]
@immutable
class SecureApplicationState {
  final bool locked;
  final bool secured;
  final bool paused;
  final bool authenticated;

  SecureApplicationState({
    this.locked = false,
    this.secured = false,
    this.paused = false,
    this.authenticated = false,
  });

  SecureApplicationState copyWith({
    bool? locked,
    bool? secured,
    bool? paused,
    bool? authenticated,
  }) {
    return SecureApplicationState(
      locked: locked ?? this.locked,
      secured: secured ?? this.secured,
      paused: paused ?? this.paused,
      authenticated: authenticated ?? this.authenticated,
    );
  }
}
