import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/scan_result.dart';

/// Color, icon and label for each scan outcome, shared by the result card
/// and the history list so both read the same way.
class ScanStatusStyle {
  final Color color;
  final IconData icon;
  final String label;

  const ScanStatusStyle({required this.color, required this.icon, required this.label});

  static const error = ScanStatusStyle(
    color: AppColors.danger,
    icon: Icons.wifi_off_rounded,
    label: 'ERROR AL VALIDAR',
  );

  factory ScanStatusStyle.of(ScanResultType type) => switch (type) {
        ScanResultType.valid => const ScanStatusStyle(
            color: AppColors.success,
            icon: Icons.check_rounded,
            label: 'ENTRADA VÁLIDA',
          ),
        ScanResultType.alreadyUsed => const ScanStatusStyle(
            color: AppColors.warning,
            icon: Icons.replay_rounded,
            label: 'YA FUE UTILIZADA',
          ),
        ScanResultType.invalid => const ScanStatusStyle(
            color: AppColors.danger,
            icon: Icons.close_rounded,
            label: 'ENTRADA NO VÁLIDA',
          ),
        ScanResultType.wrongEvent => const ScanStatusStyle(
            color: AppColors.danger,
            icon: Icons.block_rounded,
            label: 'EVENTO INCORRECTO',
          ),
      };
}
