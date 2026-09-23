import 'package:flutter/material.dart';

import '../theme/app_motion.dart';

/// Fades its child in while lifting it a few pixels, after [index] stagger
/// steps. Used for content entering a page. With reduced motion enabled it
/// only fades.
class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final int index;

  const FadeSlideIn({super.key, required this.child, this.index = 0});

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn> with SingleTickerProviderStateMixin {
  // Past a handful of items the cascade stops adding anything but waiting.
  static const _maxStaggeredItems = 8;
  static const _offset = 8.0;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.enter,
  );
  late final Animation<double> _animation = CurvedAnimation(parent: _controller, curve: AppMotion.easeOut);

  @override
  void initState() {
    super.initState();
    final steps = widget.index.clamp(0, _maxStaggeredItems);
    Future.delayed(AppMotion.stagger * steps, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Opacity(
        opacity: _animation.value,
        child: Transform.translate(
          offset: Offset(0, reduceMotion ? 0 : (1 - _animation.value) * _offset),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}
