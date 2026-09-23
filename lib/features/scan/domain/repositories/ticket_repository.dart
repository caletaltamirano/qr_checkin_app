import '../entities/scan_result.dart';
import '../entities/sync_report.dart';
import '../entities/ticket.dart';

abstract class TicketRepository {
  /// Fetches a ticket by its QR code content (id).
  Future<Ticket?> getTicketById(String ticketId);

  /// Validates a ticket and marks it as used if valid.
  /// Returns the result of the scan (valid, invalid, already used, etc).
  Future<ScanResult> validateAndMarkTicket({
    required String ticketId,
    required String eventId,
    required String operatorId,
  });

  /// Marks a ticket as used directly, without re-validating it.
  Future<void> markTicketAsUsed({
    required String ticketId,
    required String operatorId,
  });

  /// Downloads all tickets for an event, for offline caching.
  Future<List<Ticket>> getAllTicketsForEvent(String eventId);

  /// Pushes check-ins made offline to the server, then downloads and
  /// caches every ticket of the event. Throws [NoConnectionException]
  /// when the device is offline.
  Future<SyncReport> syncTicketsForEvent(String eventId);

  /// How many of the event's tickets are available offline.
  Future<int> getCachedTicketCount(String eventId);
}
