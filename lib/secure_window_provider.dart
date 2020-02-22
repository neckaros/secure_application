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
    if (listen) {
      context
          .dependOnInheritedWidgetOfExactType<SecureWindowProvider>()
          .secureData;
    } else {
      var widget = context
          .getElementForInheritedWidgetOfExactType<SecureWindowProvider>()
          .widget as SecureWindowProvider;
      if (widget == null) {
        throw 'Unable to get SecureWindowController';
      }
      return widget.secureData;
    }
  }

  @override
  bool updateShouldNotify(SecureWindowProvider old) =>
      old.secureData != secureData;
}
