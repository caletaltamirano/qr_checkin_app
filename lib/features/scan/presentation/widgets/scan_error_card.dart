import 'package:flutter/material.dart';

import 'scan_card_body.dart';
import 'scan_sheet.dart';
import 'scan_status_style.dart';

/// Shown when validating a scan fails unexpectedly (e.g. no connection
/// and no local cache for the ticket). Stays a little longer than a normal
/// result because there's a message to read.
class ScanErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onDismissed;

  const ScanErrorCard({super.key, required this.message, required this.onDismissed});

  @override
  Widget build(BuildContext context) {
    return ScanSheet(
      autoDismissAfter: const Duration(seconds: 4),
      onDismissed: onDismissed,
      builder: (context, remaining) => ScanCardBody(
        style: ScanStatusStyle.error,
        title: message,
        remaining: remaining,
      ),
    );
  }
}
