import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/ticket.dart';

class TicketTypeChip extends StatelessWidget {
  final TicketType type;

  const TicketTypeChip({super.key, required this.type});

  String get _label => switch (type) {
        TicketType.general => 'General',
        TicketType.vip => 'VIP',
        TicketType.staff => 'Staff',
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        _label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      ),
    );
  }
}
