import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../../../../core/theme/app_motion.dart';
import '../../../../core/widgets/pressable.dart';

/// Bottom sheet that slides up from below, dismisses itself after
/// [autoDismissAfter], and can be closed early with a tap or a downward
/// swipe.
///
/// A single unbounded controller drives the position (0 = resting,
/// 1 = hidden one sheet-height below), so every animation — enter, drag,
/// snap back, dismiss — starts from wherever the sheet currently is and
/// can be interrupted at any moment without jumping.
class ScanSheet extends StatefulWidget {
  final Duration autoDismissAfter;
  final VoidCallback onDismissed;

  /// Receives the auto-dismiss countdown (1 → 0) so the content can show
  /// how long it will stay on screen.
  final Widget Function(BuildContext context, Animation<double> remaining) builder;

  const ScanSheet({
    super.key,
    required this.autoDismissAfter,
    required this.onDismissed,
    required this.builder,
  });

  @override
  State<ScanSheet> createState() => _ScanSheetState();
}

class _ScanSheetState extends State<ScanSheet> with TickerProviderStateMixin {
  /// Emil Kowalski's flick threshold: a quick swipe dismisses regardless
  /// of how far it travelled.
  static const _flickVelocity = 110.0; // px/s
  static const _dismissDistance = 0.35; // fraction of the sheet's height

  /// Critically damped (no overshoot) for dismissing; slightly under-damped
  /// for snapping back, since that one follows a gesture with momentum.
  /// Stiffness comes from Apple's `response` of 0.3s: (2π / 0.3)².
  static final _dismissSpring = SpringDescription.withDampingRatio(mass: 1, stiffness: 440, ratio: 1);
  static final _snapBackSpring = SpringDescription.withDampingRatio(mass: 1, stiffness: 440, ratio: 0.85);

  late final AnimationController _position = AnimationController.unbounded(vsync: this, value: 1);
  late final AnimationController _countdown = AnimationController(
    vsync: this,
    duration: widget.autoDismissAfter,
    value: 1,
  );

  final _sheetKey = GlobalKey();
  double _dragOffset = 0; // raw, before rubber-banding
  bool _dismissing = false;

  @override
  void initState() {
    super.initState();
    _position.animateTo(0, duration: AppMotion.enter, curve: AppMotion.easeOut);
    _countdown.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) _dismiss();
    });
    _countdown.reverse();
  }

  @override
  void dispose() {
    _position.dispose();
    _countdown.dispose();
    super.dispose();
  }

  double get _sheetHeight => _sheetKey.currentContext?.size?.height ?? 200;

  Future<void> _dismiss({double velocity = 0}) async {
    if (_dismissing) return;
    _dismissing = true;
    _countdown.stop();

    if (velocity > 0) {
      await _position.animateWith(SpringSimulation(_dismissSpring, _position.value, 1, velocity));
    } else {
      await _position.animateTo(1, duration: AppMotion.exit, curve: AppMotion.easeOut);
    }
    if (mounted) widget.onDismissed();
  }

  void _onDragStart(DragStartDetails _) {
    if (_dismissing) return;
    _position.stop();
    _countdown.stop();
    _dragOffset = _position.value;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_dismissing) return;
    _dragOffset += details.delta.dy / _sheetHeight;
    // Dragging up past the resting point meets increasing resistance
    // instead of a hard wall.
    _position.value = _dragOffset >= 0 ? _dragOffset : -_rubberBand(-_dragOffset);
  }

  void _onDragEnd(DragEndDetails details) {
    if (_dismissing) return;
    final velocity = details.velocity.pixelsPerSecond.dy;
    final relativeVelocity = velocity / _sheetHeight;

    if (velocity > _flickVelocity || _position.value > _dismissDistance) {
      _dismiss(velocity: relativeVelocity.clamp(0.5, double.infinity));
    } else {
      _position.animateWith(SpringSimulation(_snapBackSpring, _position.value, 0, relativeVelocity));
      _countdown.reverse();
    }
  }

  static double _rubberBand(double overshoot) {
    const constant = 0.55;
    return (overshoot * constant) / (1 + constant * overshoot);
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: AnimatedBuilder(
            animation: _position,
            builder: (context, child) {
              final value = _position.value;
              return Opacity(
                opacity: (1 - value).clamp(0.0, 1.0),
                child: FractionalTranslation(
                  translation: Offset(0, reduceMotion ? 0 : value),
                  child: child,
                ),
              );
            },
            child: GestureDetector(
              onVerticalDragStart: _onDragStart,
              onVerticalDragUpdate: _onDragUpdate,
              onVerticalDragEnd: _onDragEnd,
              child: Pressable(
                pressedScale: 0.98,
                onTap: _dismiss,
                child: KeyedSubtree(
                  key: _sheetKey,
                  child: widget.builder(context, _countdown),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
