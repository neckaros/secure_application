import 'package:flutter/widgets.dart';
import 'package:secure_window/secure_window_provider.dart';
import 'package:secure_window/secure_window_state.dart';
import 'package:secure_window/secure_window.dart';

class SecureApplication extends StatefulWidget {
  final Widget child;
  final void Function(SecureWindowStateNotifier secureWindowStateNotifier)
      onNeedUnlock;
  const SecureApplication({Key key, this.child, this.onNeedUnlock})
      : super(key: key);

  @override
  _SecureApplicationState createState() => _SecureApplicationState();
}

class _SecureApplicationState extends State<SecureApplication>
    with WidgetsBindingObserver {
  SecureWindowStateNotifier secureWindowStateNotifier;
  @override
  void initState() {
    secureWindowStateNotifier = SecureWindowStateNotifier(SecureWindowState());
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
        if (secureWindowStateNotifier.secured &&
            !secureWindowStateNotifier.value.locked) {
          secureWindowStateNotifier.lock();
        }
        Future.delayed(Duration(milliseconds: 500)).then((_) => SecureWindow.unlock());
        if (secureWindowStateNotifier.secured &&
            secureWindowStateNotifier.value.locked) {
          if (widget.onNeedUnlock != null) {
            widget.onNeedUnlock(secureWindowStateNotifier);
          }
        }
        super.didChangeAppLifecycleState(state);
        break;
      case AppLifecycleState.paused:
        if (secureWindowStateNotifier.secured) {
          secureWindowStateNotifier.lock();
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
      secureData: secureWindowStateNotifier,
      child: widget.child,
    );
  }
}
