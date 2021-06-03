import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:secure_application/secure_application_native.dart';
import 'package:secure_application/secure_application_provider.dart';
import 'package:secure_application/secure_application_controller.dart';

/// it will display a blurr over your content if locked
///
/// It will lock/unlock depending on the [SecureApplicationController] provided by a [SecureApplication]
/// above this controller
/// play with [SecureGate.opacity] and [SecureGate.blurr] to controle amount of child visible when the gate is active
class SecureGate extends StatefulWidget {
  /// child to display if not locked
  final Widget child;

  /// builder to display a child above the blurr window to allow your user to authenticate and unlock
  /// use the provided [SecureApplicationController] to unlock [SecureApplicationController] when user is authenticated
  final Widget Function(BuildContext context,
      SecureApplicationController? secureApplicationController)? lockedBuilder;

  /// amount of blurr to allow more or less of the child be visible when locked
  /// default to 20
  final double blurr;

  /// opacity of the blurr gate
  /// default to 0.6
  final double opacity;

  const SecureGate({
    Key? key,
    required this.child,
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
  late AnimationController _gateVisibility;
  SecureApplicationController? _secureApplicationController;

  @override
  void initState() {
    _gateVisibility =
        AnimationController(vsync: this, duration: kThemeAnimationDuration * 2)
          ..addListener(_handleChange);
    SecureApplicationNative.opacity(widget.opacity);

    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_secureApplicationController == null) {
      _secureApplicationController = SecureApplicationProvider.of(context);
      _secureApplicationController!.addListener(_sercureNotified);
      _sercureNotified();
    }
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(SecureGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.opacity != widget.opacity) {
      SecureApplicationNative.opacity(widget.opacity);
    }
  }

  void _sercureNotified() {
    if (_lock == false && _secureApplicationController!.locked == true) {
      _lock = true;
      _gateVisibility.value = 1;
    } else if (_lock == true && _secureApplicationController!.locked == false) {
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
    _secureApplicationController!.removeListener(_sercureNotified);
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
                        .withOpacity(widget.opacity * _gateVisibility.value)),
              ),
            ),
          ),
        if (_lock && widget.lockedBuilder != null)
          widget.lockedBuilder!(context, _secureApplicationController),
      ],
    );
  }
}
