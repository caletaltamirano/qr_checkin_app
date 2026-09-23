import 'package:flutter/animation.dart';

/// Motion tokens. Curves are strong custom variants because the built-in
/// ones are too weak to feel intentional; durations stay under 300ms since
/// the gatekeeper sees these animations hundreds of times per event.
abstract final class AppMotion {
  /// Strong ease-out for anything entering or exiting.
  static const easeOut = Cubic(0.23, 1, 0.32, 1);

  static const press = Duration(milliseconds: 120);
  static const fast = Duration(milliseconds: 180);
  static const enter = Duration(milliseconds: 260);
  static const exit = Duration(milliseconds: 200);

  /// Delay between items that enter together. Kept short so the cascade
  /// reads as one motion and never makes the screen feel slow.
  static const stagger = Duration(milliseconds: 40);
}
