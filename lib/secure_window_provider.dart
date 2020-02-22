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

  /// get the [SecureWindowController] of the context
  /// Use [listen] = false if you are outside of a widget builder (example in init state or in a bloc)
  static SecureWindowController of(BuildContext context, {bool listen = true}) {
    return listen
        ? context
            .dependOnInheritedWidgetOfExactType<SecureWindowProvider>()
            .secureData
        : context
            .getElementForInheritedWidgetOfExactType<SecureWindowProvider>();
  }

  @override
  bool updateShouldNotify(SecureWindowProvider old) =>
      old.secureData != secureData;
}
