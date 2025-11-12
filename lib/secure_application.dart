import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:secure_application/secure_application_controller.dart';
import 'package:secure_application/secure_application_native.dart';
import 'package:secure_application/secure_application_provider.dart';
import 'package:secure_application/secure_application_state.dart';

export './secure_application.dart';
export './secure_application_controller.dart';
export './secure_application_provider.dart';
export './secure_application_state.dart';
export './secure_gate.dart';

/// Widget that will manage Secure Gates and visibility protection for your app content
///
/// Should be above any [SecureGate]
/// provide to all it descendants a [SecureApplicationController] that can be used to secure/open and lock/unlock
class SecureApplication extends StatefulWidget {
  /// Child of the widget
  final Widget child;

  /// This will remove IOs glass effect from native automatically. To set to true (default) if you don't want to manage it
  /// you can play with the [nativeRemoveDelay] to avoid iOS unsecure flicker
  @Deprecated(
      'It is handled internally on ios getting the same behavior as on android. This flag will no longer have any effect')
  final bool autoUnlockNative;

  /// Method will be called when the user switch back to your application
  ///
  /// you can manage from here a global process for authorizing the user to see hidden content
  /// like maybe by using local_auth package
  final Future<SecureApplicationAuthenticationStatus?>? Function(
          SecureApplicationController? secureApplicationStateNotifier)?
      onNeedUnlock;

  /// will be called if authentication failed
  final VoidCallback? onAuthenticationFailed;

  /// will be called if authentication succeed
  final VoidCallback? onAuthenticationSucceed;

  /// will be called if user logout
  final VoidCallback? onLogout;

  /// the time in milliseconds we wait to remove the native protection screen
  /// usefull on iOS to let long app start
  final int nativeRemoveDelay;

  /// controller of the [SecureApplication]
  ///
  /// Can be set to provide your own controller to the application
  /// with your own starting values
  final SecureApplicationController? secureApplicationController;
  const SecureApplication({
    Key? key,
    required this.child,
    this.onNeedUnlock,
    this.secureApplicationController,
    this.autoUnlockNative = true,
    this.onAuthenticationFailed,
    this.onAuthenticationSucceed,
    this.onLogout,
    this.nativeRemoveDelay = 1000,
  }) : super(key: key);

  @override
  _SecureApplicationState createState() => _SecureApplicationState();
}

class _SecureApplicationState extends State<SecureApplication>
    with WidgetsBindingObserver {
  SecureApplicationController? _secureApplicationController;

  StreamSubscription? _authStreamSubscription;

  SecureApplicationController get secureApplicationController {
    if (widget.secureApplicationController != null) {
      return widget.secureApplicationController!;
    } else if (_secureApplicationController != null) {
      return _secureApplicationController!;
    }
    _secureApplicationController =
        SecureApplicationController(SecureApplicationState());
    return _secureApplicationController!;
  }

  @override
  void initState() {
    _authStreamSubscription =
        secureApplicationController.authenticationEvents.listen((s) {
      if (s == SecureApplicationAuthenticationStatus.FAILED) {
        if (widget.onAuthenticationFailed != null)
          widget.onAuthenticationFailed!();
      } else if (s == SecureApplicationAuthenticationStatus.SUCCESS) {
        if (widget.onAuthenticationSucceed != null)
          widget.onAuthenticationSucceed!();
      } else if (s == SecureApplicationAuthenticationStatus.LOGOUT) {
        if (widget.onLogout != null) widget.onLogout!();
      }
    });
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SecureApplicationNative.registerForEvents(
        secureApplicationController.lockIfSecured,
        secureApplicationController.unlock);
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
              final authStatus =
                  await widget.onNeedUnlock!(secureApplicationController);
              if (authStatus != null)
                secureApplicationController.sendAuthenticationEvent(authStatus);

              WidgetsBinding.instance.addPostFrameCallback((_) {
                secureApplicationController.unpause();
              });
            }
          }
          secureApplicationController.resumed();
        }
        break;
      case AppLifecycleState.paused:
        if (!secureApplicationController.paused) {
          if (secureApplicationController.secured) {
            secureApplicationController.lock();
          }
        }
        break;
      default:
        break;
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return SecureApplicationProvider(
      secureData: secureApplicationController,
      child: widget.child,
    );
  }
}
