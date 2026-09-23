import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/errors/no_connection_exception.dart';
import '../../domain/usecases/get_cached_ticket_count.dart';
import '../../domain/usecases/sync_tickets.dart';
import 'sync_state.dart';

class SyncCubit extends Cubit<SyncState> {
  final SyncTickets syncTickets;
  final GetCachedTicketCount getCachedTicketCount;
  final String eventId;

  SyncCubit({
    required this.syncTickets,
    required this.getCachedTicketCount,
    required this.eventId,
  }) : super(const SyncIdle());

  Future<void> loadCachedCount() async {
    emit(SyncIdle(cachedCount: await getCachedTicketCount(eventId)));
  }

  Future<void> sync() async {
    if (state is SyncInProgress) return;
    final previousCount = state.cachedCount;
    emit(SyncInProgress(cachedCount: previousCount));

    try {
      final report = await syncTickets(eventId);
      emit(SyncSuccess(
        report: report,
        syncedAt: DateTime.now(),
        cachedCount: await getCachedTicketCount(eventId),
      ));
    } on NoConnectionException {
      emit(SyncFailure('Sin conexión. Conectate a internet para sincronizar.', cachedCount: previousCount));
    } catch (_) {
      emit(SyncFailure('No se pudo sincronizar. Intentá de nuevo.', cachedCount: previousCount));
    }
  }
}
