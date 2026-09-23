import 'ticket.dart';

enum ScanResultType { valid, invalid, alreadyUsed, wrongEvent }

class ScanResult {
  final ScanResultType type;
  final String message;
  final DateTime? usedAt;
  final String? usedBy;

  /// Null when the scanned code doesn't match any known ticket.
  final String? holderName;
  final TicketType? ticketType;

  const ScanResult({
    required this.type,
    required this.message,
    this.usedAt,
    this.usedBy,
    this.holderName,
    this.ticketType,
  });

  bool get isValid => type == ScanResultType.valid;
}
