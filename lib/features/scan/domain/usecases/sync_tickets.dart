import '../entities/sync_report.dart';
import '../repositories/ticket_repository.dart';

class SyncTickets {
  final TicketRepository repository;

  SyncTickets(this.repository);

  /// Throws [NoConnectionException] when the device is offline.
  Future<SyncReport> call(String eventId) => repository.syncTicketsForEvent(eventId);
}
