import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:secure_window/secure_window.dart';
import 'package:secure_window/secure_window_provider.dart';
import 'package:secure_window/secure_window_state.dart';

/// Show a barrier above your content when the Lock is active
/// 
/// This widget must have a [SecureWindow] in its ancestors
class SecureGate extends StatefulWidget {
  /// Body shown when the barrier is not active
  final Widget child;
  /// Builder for the child that will be displayed atop the barrier
  final Widget Function(
          BuildContext context, SecureWindowStateNotifier secureNotifier)
      lockedBuilder;
  /// Amount of Blurr
  final int blurr;
  /// Opacity of the lock barrier
  final double opacity;

  const SecureGate({Key key, this.child, this.blurr = 20, this.opacity = 0.6, this.lockedBuilder})
      : super(key: key);
  @override
  _SecureGateState createState() => _SecureGateState();
}

class _SecureGateState extends State<SecureGate>
    with SingleTickerProviderStateMixin {
  bool _lock = false;
  AnimationController _gateVisibility;
  SecureWindowStateNotifier secureNotifier;
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
    secureNotifier.removeListener(_sercureNotified);
    _gateVisibility.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_removeNativeOnNextFrame) {
      Future.delayed(Duration(milliseconds: 500)).then((_) =>  SecureWindow.unlock());
      
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
          widget.lockedBuilder(context, secureNotifier),
      ],
    );
  }
}
