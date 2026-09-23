import '../../domain/entities/event_info.dart';
import '../../domain/repositories/event_repository.dart';
import '../datasources/event_remote_datasource.dart';

class EventRepositoryImpl implements EventRepository {
  final EventRemoteDataSource remoteDataSource;

  EventRepositoryImpl({required this.remoteDataSource});

  @override
  Future<EventInfo?> getEventById(String eventId) => remoteDataSource.getEventById(eventId);
}
