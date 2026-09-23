import '../repositories/ticket_repository.dart';

class MarkTicketAsUsed {
  final TicketRepository repository;

  MarkTicketAsUsed(this.repository);

  /// Marks a ticket as used directly, without re-validating it.
  /// Used for the manual entry flow (when the operator types the ID
  /// instead of scanning, after already confirming the ticket is valid).
  Future<void> call({
    required String ticketId,
    required String operatorId,
  }) {
    return repository.markTicketAsUsed(
      ticketId: ticketId,
      operatorId: operatorId,
    );
  }
}