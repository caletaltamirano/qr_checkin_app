import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';

import 'features/event/data/datasources/event_remote_datasource.dart';
import 'features/event/data/repositories/event_repository_impl.dart';
import 'features/event/domain/repositories/event_repository.dart';
import 'features/event/domain/usecases/get_event_info.dart';
import 'features/scan/data/datasources/scan_history_local_datasource.dart';
import 'features/scan/data/datasources/ticket_local_datasource.dart';
import 'features/scan/data/datasources/ticket_remote_datasource.dart';
import 'features/scan/data/repositories/scan_history_repository_impl.dart';
import 'features/scan/data/repositories/ticket_repository_impl.dart';
import 'features/scan/domain/repositories/scan_history_repository.dart';
import 'features/scan/domain/repositories/ticket_repository.dart';
import 'features/scan/domain/usecases/get_cached_ticket_count.dart';
import 'features/scan/domain/usecases/get_scan_history.dart';
import 'features/scan/domain/usecases/mark_ticket_as_used.dart';
import 'features/scan/domain/usecases/save_scan_record.dart';
import 'features/scan/domain/usecases/sync_tickets.dart';
import 'features/scan/domain/usecases/validate_ticket.dart';

final sl = GetIt.instance;

/// Registers every dependency used across the app.
/// Call this once in main() before runApp().
Future<void> initDependencies() async {
  // External packages
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => Connectivity());

  // Data sources
  sl.registerLazySingleton<TicketRemoteDataSource>(
    () => TicketRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<TicketLocalDataSource>(
    () => TicketLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<ScanHistoryLocalDataSource>(
    () => ScanHistoryLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<EventRemoteDataSource>(
    () => EventRemoteDataSourceImpl(sl()),
  );

  // Repositories
  sl.registerLazySingleton<TicketRepository>(
    () => TicketRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      connectivity: sl(),
    ),
  );
  sl.registerLazySingleton<ScanHistoryRepository>(
    () => ScanHistoryRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<EventRepository>(
    () => EventRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => ValidateTicket(sl()));
  sl.registerLazySingleton(() => MarkTicketAsUsed(sl()));
  sl.registerLazySingleton(() => SyncTickets(sl()));
  sl.registerLazySingleton(() => GetCachedTicketCount(sl()));
  sl.registerLazySingleton(() => SaveScanRecord(sl()));
  sl.registerLazySingleton(() => GetScanHistory(sl()));
  sl.registerLazySingleton(() => GetEventInfo(sl()));
}
