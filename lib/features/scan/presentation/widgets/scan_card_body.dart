import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'scan_status_style.dart';

/// Visual shell shared by the result and error cards: status header,
/// a prominent title, an optional detail row, and a countdown bar along
/// the bottom edge showing when the card will close by itself.
class ScanCardBody extends StatelessWidget {
  final ScanStatusStyle style;
  final String title;
  final Widget? details;
  final Animation<double> remaining;

  const ScanCardBody({
    super.key,
    required this.style,
    required this.title,
    required this.remaining,
    this.details,
  });

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(28));

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 40, offset: const Offset(0, 16)),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surfaceRaised,
            borderRadius: radius,
            border: Border.all(color: AppColors.border),
            // A faint wash of the status color from the top, so the result
            // reads at a glance even from the corner of the eye.
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [style.color.withValues(alpha: 0.16), style.color.withValues(alpha: 0)],
              stops: const [0, 0.7],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(color: style.color, shape: BoxShape.circle),
                          child: Icon(style.icon, color: AppColors.background, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          style.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.9,
                            color: style.color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    if (details != null) ...[
                      const SizedBox(height: 14),
                      details!,
                    ],
                  ],
                ),
              ),
              _CountdownBar(remaining: remaining, color: style.color),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountdownBar extends StatelessWidget {
  final Animation<double> remaining;
  final Color color;

  const _CountdownBar({required this.remaining, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 3,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: remaining,
        // Scaling instead of resizing keeps this on the compositor.
        builder: (context, child) => Transform.scale(
          scaleX: remaining.value,
          alignment: Alignment.centerLeft,
          child: child,
        ),
        child: ColoredBox(color: color.withValues(alpha: 0.7)),
      ),
    );
  }
}
