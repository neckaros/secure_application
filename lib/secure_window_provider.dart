import 'package:flutter/widgets.dart';
import 'package:secure_window/secure_window_controller.dart';

/// [InheritedWidget] provider of a [SecureWindowController] for its children.
///
/// Used internally by [SecureApplication]
class SecureWindowProvider extends InheritedWidget {
  const SecureWindowProvider({
    Key key,
    this.secureData,
    @required Widget child,
  })  : assert(child != null),
        super(key: key, child: child);

  final SecureWindowController secureData;

  static SecureWindowController of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<SecureWindowProvider>()
        .secureData;
  }

  @override
  bool updateShouldNotify(SecureWindowProvider old) =>
      old.secureData != secureData;
}
