import 'package:flutter/widgets.dart';
import 'package:secure_window/secure_window_state.dart';

class SecureWindowProvider extends InheritedWidget {
  const SecureWindowProvider({
    Key key,
    this.secureData,
    @required Widget child,
  })  : assert(child != null),
        super(key: key, child: child);

  final SecureWindowStateNotifier secureData;

  static SecureWindowStateNotifier of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<SecureWindowProvider>()
        .secureData;
  }

  @override
  bool updateShouldNotify(SecureWindowProvider old) =>
      old.secureData != secureData;
}
