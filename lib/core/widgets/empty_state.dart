import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'fade_slide_in.dart';

/// Centered icon + title + message, for screens with nothing to show yet
/// or that failed to load.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Color iconColor;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.iconColor = AppColors.textSecondary,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FadeSlideIn(
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 30),
              ),
            ),
            const SizedBox(height: 20),
            FadeSlideIn(
              index: 1,
              child: Text(title, style: textTheme.titleMedium, textAlign: TextAlign.center),
            ),
            const SizedBox(height: 8),
            FadeSlideIn(
              index: 2,
              child: Text(message, style: textTheme.bodyMedium, textAlign: TextAlign.center),
            ),
            if (action != null) ...[
              const SizedBox(height: 28),
              FadeSlideIn(index: 3, child: action!),
            ],
          ],
        ),
      ),
    );
  }
}
