import 'package:flutter/material.dart';

import '../theme/app_motion.dart';

/// Scales its child down slightly while pressed. Feedback starts on
/// pointer-down, not on release, so the UI feels like it heard the touch
/// immediately. [AnimatedScale] retargets from the current value, so fast
/// repeated taps never jump.
class Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;

  const Pressable({
    super.key,
    required this.child,
    required this.onTap,
    this.pressedScale = 0.97,
  });

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return Listener(
      onPointerDown: enabled ? (_) => _setPressed(true) : null,
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onTapCancel: () => _setPressed(false),
        child: AnimatedScale(
          scale: _pressed ? widget.pressedScale : 1,
          duration: AppMotion.press,
          curve: AppMotion.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}
