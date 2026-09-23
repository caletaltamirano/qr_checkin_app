import '../entities/scan_result.dart';
import '../repositories/ticket_repository.dart';

class ValidateTicket {
  final TicketRepository repository;

  ValidateTicket(this.repository);

  /// Validates a scanned ticket and marks it as used if it's valid.
  Future<ScanResult> call({
    required String ticketId,
    required String eventId,
    required String operatorId,
  }) {
    return repository.validateAndMarkTicket(
      ticketId: ticketId,
      eventId: eventId,
      operatorId: operatorId,
    );
  }
}