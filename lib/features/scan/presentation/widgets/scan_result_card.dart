import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/time_format.dart';
import '../../domain/entities/scan_result.dart';
import '../../domain/entities/ticket.dart';
import 'scan_card_body.dart';
import 'scan_sheet.dart';
import 'scan_status_style.dart';
import 'ticket_type_chip.dart';

/// Shown after every scan. Closes by itself, or earlier with a tap or a
/// downward swipe.
class ScanResultCard extends StatelessWidget {
  static const autoDismissAfter = Duration(milliseconds: 3500);

  final ScanResult result;
  final VoidCallback onDismissed;

  const ScanResultCard({super.key, required this.result, required this.onDismissed});

  @override
  Widget build(BuildContext context) {
    final style = ScanStatusStyle.of(result.type);
    final ticketType = result.ticketType;
    final checkIn = _checkInLabel();

    return ScanSheet(
      autoDismissAfter: autoDismissAfter,
      onDismissed: onDismissed,
      builder: (context, remaining) => ScanCardBody(
        style: style,
        // The holder's name is what the gatekeeper checks against the
        // person in front of them, so it carries the most weight.
        title: result.holderName ?? result.message,
        remaining: remaining,
        details: ticketType == null && checkIn == null
            ? null
            : _Details(ticketType: ticketType, checkIn: checkIn),
      ),
    );
  }

  String? _checkInLabel() {
    final usedAt = result.usedAt;
    if (usedAt == null) return null;
    return switch (result.type) {
      ScanResultType.alreadyUsed => 'Ya ingresó a las ${formatTime(usedAt)}',
      _ => 'Ingresó a las ${formatTime(usedAt)}',
    };
  }
}

class _Details extends StatelessWidget {
  final TicketType? ticketType;
  final String? checkIn;

  const _Details({required this.ticketType, required this.checkIn});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (ticketType != null) TicketTypeChip(type: ticketType!),
        if (checkIn != null)
          Text(
            checkIn!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
      ],
    );
  }
}
