import 'dart:ui';

import 'package:flutter/material.dart';

/// Translucent, blurred layer for chrome that floats over the camera feed.
/// It keeps the controls legible without hiding what's underneath.
class GlassSurface extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;

  const GlassSurface({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(999)),
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.35),
            borderRadius: borderRadius,
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
