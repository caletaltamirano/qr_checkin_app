import '../entities/event_info.dart';
import '../repositories/event_repository.dart';

class GetEventInfo {
  final EventRepository repository;

  GetEventInfo(this.repository);

  Future<EventInfo?> call(String eventId) => repository.getEventById(eventId);
}
