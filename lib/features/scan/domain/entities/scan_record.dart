import 'package:equatable/equatable.dart';

import 'scan_result.dart';
import 'ticket.dart';

/// One entry in the scan history: what was scanned, when, and the outcome.
class ScanRecord extends Equatable {
  final String ticketId;
  final String eventId;
  final ScanResultType resultType;
  final DateTime scannedAt;
  final String? holderName;
  final TicketType? ticketType;

  const ScanRecord({
    required this.ticketId,
    required this.eventId,
    required this.resultType,
    required this.scannedAt,
    this.holderName,
    this.ticketType,
  });

  @override
  List<Object?> get props => [ticketId, eventId, resultType, scannedAt, holderName, ticketType];
}
