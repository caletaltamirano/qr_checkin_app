import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_scan_history.dart';
import 'scan_history_state.dart';

class ScanHistoryCubit extends Cubit<ScanHistoryState> {
  final GetScanHistory getScanHistory;
  final String eventId;

  ScanHistoryCubit({required this.getScanHistory, required this.eventId})
      : super(const ScanHistoryLoading());

  Future<void> load() async {
    try {
      emit(ScanHistoryLoaded(await getScanHistory(eventId)));
    } catch (_) {
      emit(const ScanHistoryError('No se pudo leer el historial.'));
    }
  }
}
