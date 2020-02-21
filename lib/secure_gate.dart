import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:secure_window/secure_window.dart';
import 'package:secure_window/secure_window_provider.dart';
import 'package:secure_window/secure_window_state.dart';

/// it will display a blurr over your content if locked
///
/// It will lock/unlock depending on the [SecureWindowController] provided by a [SecureWindow]
/// above this controller
/// play with [SecureGate.opacity] and [SecureGate.blurr] to controle amount of child visible when the gate is active
class SecureGate extends StatefulWidget {
  /// child to display if not locked
  final Widget child;

  /// builder to display a child above the blurr window to allow your user to authenticate and unlock
  /// use the provided [SecureWindowController] to unlock [SecureWindowController] when user is authenticated
  final Widget Function(
          BuildContext context, SecureWindowController secureWindowController)
      lockedBuilder;

  /// amount of blurr to allow more or less of the child be visible when locked
  /// default to 20
  final int blurr;

  /// opacity of the blurr gate
  /// default to 0.6
  final double opacity;

  const SecureGate({
    Key key,
    this.child,
    this.blurr = 20,
    this.opacity = 0.6,
    this.lockedBuilder,
  }) : super(key: key);
  @override
  _SecureGateState createState() => _SecureGateState();
}

class _SecureGateState extends State<SecureGate>
    with SingleTickerProviderStateMixin {
  bool _lock = false;
  AnimationController _gateVisibility;
  SecureWindowController _secureWindowController;
  bool _removeNativeOnNextFrame = false;

  @override
  void initState() {
    _gateVisibility =
        AnimationController(vsync: this, duration: kThemeAnimationDuration * 2)
          ..addListener(_handleChange);

    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_secureWindowController == null) {
      _secureWindowController = SecureWindowProvider.of(context);
      _secureWindowController.addListener(_sercureNotified);
      _gateVisibility.value = _secureWindowController.locked ? 1 : 0;
    }
    super.didChangeDependencies();
  }

  void _sercureNotified() {
    if (_lock == false && _secureWindowController.locked == true) {
      _lock = true;
      _gateVisibility.value = 1;
    } else if (_lock == true && _secureWindowController.locked == false) {
      _lock = false;
      _gateVisibility.animateBack(0).orCancel;
    }

    if (mounted) {
      setState(() => _removeNativeOnNextFrame = true);
    } else {
      _removeNativeOnNextFrame = true;
    }
  }

  void _handleChange() {
    setState(() {
      // The listenable's state is our build state, and it changed already.
    });
  }

  @override
  void dispose() {
    _secureWindowController.removeListener(_sercureNotified);
    _gateVisibility.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_removeNativeOnNextFrame) {
      Future.delayed(Duration(milliseconds: 500))
          .then((_) => SecureWindow.unlock());

      _removeNativeOnNextFrame = false;
    }
    return Stack(
      children: <Widget>[
        widget.child,
        if (_gateVisibility.value != 0)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                  sigmaX: widget.blurr * _gateVisibility.value,
                  sigmaY: widget.blurr * _gateVisibility.value),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.grey.shade200
                        .withOpacity(widget.opacity * _gateVisibility.value)),
              ),
            ),
          ),
        if (_lock && widget.lockedBuilder != null)
          widget.lockedBuilder(context, _secureWindowController),
      ],
    );
  }
}
