import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import 'pressable.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;

  /// Null disables the button.
  final VoidCallback? onPressed;

  const PrimaryButton({super.key, required this.label, required this.onPressed, this.icon});

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Pressable(
      onTap: onPressed,
      child: AnimatedOpacity(
        opacity: enabled ? 1 : 0.5,
        duration: AppMotion.fast,
        curve: Curves.ease,
        child: Container(
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: AppColors.background),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.1,
                  color: AppColors.background,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
