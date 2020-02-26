import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:secure_application/secure_application_native.dart';
import 'package:secure_application/secure_application_provider.dart';
import 'package:secure_application/secure_application_state.dart';
import 'package:secure_application/secure_application_controller.dart';

export './secure_application.dart';
export './secure_gate.dart';
export './secure_application_provider.dart';
export './secure_application_state.dart';
export './secure_application_controller.dart';

/// Widget that will manage Secure Gates and visibility protection for your app content
///
/// Should be above any [SecureGate]
/// provide to all it descendants a [SecureApplicationController] that can be used to secure/open and lock/unlock
class SecureApplication extends StatefulWidget {
  /// Child of the widget
  final Widget child;

  /// This will remove IOs glass effect from native automatically. To set to true if you don't have a gate in the application
  final bool autoUnlockNative;

  /// Method will be called when the user switch back to your application
  ///
  /// you can manage from here a global process for authorizing the user to see hidden content
  /// like maybe by using local_auth package
  final Future<SecureApplicationAuthenticationStatus> Function(
      SecureApplicationController SecureApplicationStateNotifier) onNeedUnlock;

  /// will be called if authentication failed
  final VoidCallback onAuthenticationFailed;

  /// will be called if authentication succeed
  final VoidCallback onAuthenticationSucceed;

  /// will be called if authentication succeed
  final VoidCallback onLogout;

  /// controller of the [SecureApplication]
  ///
  /// Can be set to provide your own controller to the application
  /// with your own starting values
  final SecureApplicationController secureApplicationController;
  const SecureApplication({
    Key key,
    @required this.child,
    this.onNeedUnlock,
    this.secureApplicationController,
    this.autoUnlockNative = false,
    this.onAuthenticationFailed,
    this.onAuthenticationSucceed,
    this.onLogout,
  }) : super(key: key);

  @override
  _SecureApplicationState createState() => _SecureApplicationState();
}

class _SecureApplicationState extends State<SecureApplication>
    with WidgetsBindingObserver {
  SecureApplicationController _secureApplicationController;

  StreamSubscription _authStreamSubscription;

  SecureApplicationController get secureApplicationController =>
      widget.secureApplicationController ?? _secureApplicationController;
  bool _removeNativeOnNextFrame = false;
  @override
  void initState() {
    if (secureApplicationController == null) {
      _secureApplicationController =
          SecureApplicationController(SecureApplicationState());
    }
    _authStreamSubscription =
        secureApplicationController.authenticationEvents.listen((s) {
      if (s == SecureApplicationAuthenticationStatus.FAILED) {
        if (widget.onAuthenticationFailed != null)
          widget.onAuthenticationFailed();
      } else if (s == SecureApplicationAuthenticationStatus.SUCCESS) {
        if (widget.onAuthenticationSucceed != null)
          widget.onAuthenticationSucceed();
      } else if (s == SecureApplicationAuthenticationStatus.LOGOUT) {
        if (widget.onLogout != null) widget.onLogout();
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
        if (!secureApplicationController.paused) {
          if (secureApplicationController.secured &&
              secureApplicationController.value.locked) {
            if (widget.onNeedUnlock != null) {
              secureApplicationController.pause();
              var authStatus =
                  await widget.onNeedUnlock(secureApplicationController);
              if (authStatus != null) {
                secureApplicationController.sendAuthenticationEvent(authStatus);
              }
              WidgetsBinding.instance.addPostFrameCallback((_) {
                secureApplicationController.unpause();
              });
            }
          }
          secureApplicationController.resumed();
        }
        if (mounted) {
          setState(() => _removeNativeOnNextFrame = true);
        } else {
          _removeNativeOnNextFrame = true;
        }
        super.didChangeAppLifecycleState(state);
        break;
      case AppLifecycleState.paused:
        if (!secureApplicationController.paused) {
          if (secureApplicationController.secured) {
            secureApplicationController.lock();
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
          .addPostFrameCallback((_) => SecureApplicationNative.unlock());
    }
    return SecureApplicationProvider(
      secureData: secureApplicationController,
      child: widget.child,
    );
  }
}
