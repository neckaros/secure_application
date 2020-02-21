import 'package:flutter/widgets.dart';
import 'package:secure_window/secure_window_provider.dart';
import 'package:secure_window/secure_window_state.dart';
import 'package:secure_window/secure_window.dart';

/// Widget to put near the root of your application
/// 
/// It will monitor app to lock it if it gets backgrounded
/// and provide a [SecureWindoStateNotifier] to its children
class SecureApplication extends StatefulWidget {
  /// Child of the widget
  final Widget child;
  /// This will remove IOs glass effect from native automatically. To set to true if you don't have a gate in the application
  final bool autoUnlockNative;
  final void Function(SecureWindowStateNotifier secureWindowStateNotifier)
      onNeedUnlock;
  const SecureApplication({Key key, this.child, this.onNeedUnlock, this.autoUnlockNative = false})
      : super(key: key);

  @override
  _SecureApplicationState createState() => _SecureApplicationState();
}

class _SecureApplicationState extends State<SecureApplication>
    with WidgetsBindingObserver {
  SecureWindowStateNotifier secureWindowStateNotifier;
  bool _removeNativeOnNextFrame = false;
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
        if (secureWindowStateNotifier.secured &&
            secureWindowStateNotifier.value.locked) {
          if (widget.onNeedUnlock != null) {
            widget.onNeedUnlock(secureWindowStateNotifier);
          }
        }
        secureWindowStateNotifier.resumed();
        if (mounted) {
          setState(() => _removeNativeOnNextFrame = true);
        } else {
          _removeNativeOnNextFrame = true;
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
    if (_removeNativeOnNextFrame && widget.autoUnlockNative) {
      WidgetsBinding.instance.addPostFrameCallback((_) => SecureWindow.unlock());
    }
    return SecureWindowProvider(
      secureData: secureWindowStateNotifier,
      child: widget.child,
    );
  }
}
