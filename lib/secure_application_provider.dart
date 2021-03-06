import 'package:flutter/widgets.dart';
import 'package:secure_application/secure_application_controller.dart';

/// [InheritedWidget] provider of a [SecureApplicationController] for its children.
///
/// Used internally by [SecureApplication]
class SecureApplicationProvider extends InheritedWidget {
  const SecureApplicationProvider({
    Key? key,
    this.secureData,
    required Widget child,
  }) : super(key: key, child: child);

  final SecureApplicationController? secureData;

  /// get the [SecureApplicationController] of the context
  /// Use [listen] = false if you are outside of a widget builder (example in init state or in a bloc)
  static SecureApplicationController? of(BuildContext context,
      {bool listen = true}) {
    if (listen) {
      return context
          .dependOnInheritedWidgetOfExactType<SecureApplicationProvider>()!
          .secureData;
    } else {
      var widget = context
          .getElementForInheritedWidgetOfExactType<SecureApplicationProvider>()!
          .widget as SecureApplicationProvider;
      return widget.secureData;
    }
  }

  @override
  bool updateShouldNotify(SecureApplicationProvider old) =>
      old.secureData != secureData;
}
