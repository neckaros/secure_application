import 'package:flutter/widgets.dart';
import 'package:secure_window/secure_window_provider.dart';
import 'package:secure_window/secure_window_state.dart';
import 'package:secure_window/secure_window.dart';

/// Widget that will manage Secure Gates and visibility protection for your app content
///
/// Should be above any [SecureGate]
/// provide to all it descendants a [SecureWindowController] that can be used to secure/open and lock/unlock
class SecureApplication extends StatefulWidget {
  final Widget child;
  final SecureWindowController secureWindowController;
  final void Function(SecureWindowController secureWindowController)
      onNeedUnlock;
  const SecureApplication(
      {Key key,
      @required this.child,
      this.onNeedUnlock,
      this.secureWindowController})
      : super(key: key);

  @override
  _SecureApplicationState createState() => _SecureApplicationState();
}

class _SecureApplicationState extends State<SecureApplication>
    with WidgetsBindingObserver {
  SecureWindowController _secureWindowController;

  SecureWindowController get secureWindowController =>
      widget.secureWindowController ?? _secureWindowController;

  @override
  void initState() {
    if (secureWindowController == null) {
      _secureWindowController = SecureWindowController(SecureWindowState());
    }
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (secureWindowController.secured &&
            !secureWindowController.value.locked) {
          secureWindowController.lock();
        }
        Future.delayed(Duration(milliseconds: 500))
            .then((_) => SecureWindow.unlock());
        if (secureWindowController.secured &&
            secureWindowController.value.locked) {
          if (widget.onNeedUnlock != null) {
            widget.onNeedUnlock(secureWindowController);
          }
        }
        super.didChangeAppLifecycleState(state);
        break;
      case AppLifecycleState.paused:
        if (secureWindowController.secured) {
          secureWindowController.lock();
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
    return SecureWindowProvider(
      secureData: secureWindowController,
      child: widget.child,
    );
  }
}
