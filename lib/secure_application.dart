import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:secure_window/secure_window_provider.dart';
import 'package:secure_window/secure_window_state.dart';
import 'package:secure_window/secure_window.dart';
import 'package:secure_window/secure_window_controller.dart';

/// Widget that will manage Secure Gates and visibility protection for your app content
///
/// Should be above any [SecureGate]
/// provide to all it descendants a [SecureWindowController] that can be used to secure/open and lock/unlock
class SecureApplication extends StatefulWidget {
  /// Child of the widget
  final Widget child;

  /// This will remove IOs glass effect from native automatically. To set to true if you don't have a gate in the application
  final bool autoUnlockNative;

  /// Method will be called when the user switch back to your application
  ///
  /// you can manage from here a global process for authorizing the user to see hidden content
  /// like maybe by using local_auth package
  final Future<SecureWindowAuthenticationStatus> Function(
      SecureWindowController secureWindowStateNotifier) onNeedUnlock;

  /// will be called if authentication failed
  final VoidCallback onAuthenticationFailed;

  /// will be called if authentication succeed
  final VoidCallback onAuthenticationSucceed;

  /// controller of the [SecureApplication]
  ///
  /// Can be set to provide your own controller to the application
  /// with your own starting values
  final SecureWindowController secureWindowController;
  const SecureApplication({
    Key key,
    @required this.child,
    this.onNeedUnlock,
    this.secureWindowController,
    this.autoUnlockNative = false,
    this.onAuthenticationFailed,
    this.onAuthenticationSucceed,
  }) : super(key: key);

  @override
  _SecureApplicationState createState() => _SecureApplicationState();
}

class _SecureApplicationState extends State<SecureApplication>
    with WidgetsBindingObserver {
  SecureWindowController _secureWindowController;

  StreamSubscription _authStreamSubscription;

  SecureWindowController get secureWindowController =>
      widget.secureWindowController ?? _secureWindowController;
  bool _removeNativeOnNextFrame = false;
  @override
  void initState() {
    if (secureWindowController == null) {
      _secureWindowController = SecureWindowController(SecureWindowState());
    }
    _authStreamSubscription =
        secureWindowController.authenticationEvents.listen((s) {
      if (s == SecureWindowAuthenticationStatus.FAILED) {
        widget.onAuthenticationFailed();
      } else if (s == SecureWindowAuthenticationStatus.SUCCESS) {
        widget.onAuthenticationSucceed();
      }
    });
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _authStreamSubscription?.cancel();
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        if (!secureWindowController.paused) {
          if (secureWindowController.secured &&
              !secureWindowController.value.locked) {
            secureWindowController.lock();
          }
          if (secureWindowController.secured &&
              secureWindowController.value.locked) {
            if (widget.onNeedUnlock != null) {
              var authStatus =
                  await widget.onNeedUnlock(secureWindowController);
              if (authStatus != null) {
                secureWindowController.sendAuthenticationEvent(authStatus);
              }
            }
          }
          secureWindowController.resumed();
        }
        if (mounted) {
          setState(() => _removeNativeOnNextFrame = true);
        } else {
          _removeNativeOnNextFrame = true;
        }
        super.didChangeAppLifecycleState(state);
        break;
      case AppLifecycleState.paused:
        if (!secureWindowController.paused) {
          if (secureWindowController.secured) {
            secureWindowController.lock();
          }
        }
        super.didChangeAppLifecycleState(state);
        break;
      default:
        super.didChangeAppLifecycleState(state);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_removeNativeOnNextFrame && widget.autoUnlockNative) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => SecureWindow.unlock());
    }
    return SecureWindowProvider(
      secureData: secureWindowController,
      child: widget.child,
    );
  }
}
