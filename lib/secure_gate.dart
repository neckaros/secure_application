import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:secure_window/secure_window_provider.dart';
import 'package:secure_window/secure_window_state.dart';

class SecureGate extends StatefulWidget {
  final Widget child;
  final Widget Function(
          BuildContext context, SecureWindowStateNotifier secureNotifier)
      lockedBuilder;
  final int blurr;

  const SecureGate({Key key, this.child, this.blurr = 20, this.lockedBuilder})
      : super(key: key);
  @override
  _SecureGateState createState() => _SecureGateState();
}

class _SecureGateState extends State<SecureGate>
    with SingleTickerProviderStateMixin {
  bool _lock = false;
  AnimationController _gateVisibility;
  SecureWindowStateNotifier secureNotifier;

  @override
  void initState() {
    _gateVisibility =
        AnimationController(vsync: this, duration: kThemeAnimationDuration * 2)
          ..addListener(_handleChange);

    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (secureNotifier == null) {
      secureNotifier = SecureWindowProvider.of(context);
      secureNotifier.addListener(_sercureNotified);
      _gateVisibility.value = secureNotifier.locked ? 1 : 0;
    }
    super.didChangeDependencies();
  }

  void _sercureNotified() {
    if (_lock == false && secureNotifier.locked == true) {
      _lock = true;
      _gateVisibility.value = 1;
    } else if (_lock == true && secureNotifier.locked == false) {
      _lock = false;
      _gateVisibility.animateBack(0).orCancel;
    }
  }

  void _handleChange() {
    setState(() {
      // The listenable's state is our build state, and it changed already.
    });
  }

  @override
  void dispose() {
    secureNotifier.removeListener(_sercureNotified);
    _gateVisibility.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                        .withOpacity(0.6 * _gateVisibility.value)),
              ),
            ),
          ),
        if (_lock && widget.lockedBuilder != null)
          widget.lockedBuilder(context, secureNotifier),
      ],
    );
  }
}
