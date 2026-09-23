import '../entities/event_info.dart';

abstract class EventRepository {
  /// Returns null when the event doesn't exist.
  Future<EventInfo?> getEventById(String eventId);
}
