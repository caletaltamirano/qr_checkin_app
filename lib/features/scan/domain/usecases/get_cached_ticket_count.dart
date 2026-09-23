import '../repositories/ticket_repository.dart';

class GetCachedTicketCount {
  final TicketRepository repository;

  GetCachedTicketCount(this.repository);

  Future<int> call(String eventId) => repository.getCachedTicketCount(eventId);
}
