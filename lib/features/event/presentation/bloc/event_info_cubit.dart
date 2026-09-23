import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_event_info.dart';
import 'event_info_state.dart';

class EventInfoCubit extends Cubit<EventInfoState> {
  final GetEventInfo getEventInfo;
  final String eventId;

  EventInfoCubit({required this.getEventInfo, required this.eventId}) : super(const EventInfoLoading());

  Future<void> load() async {
    emit(const EventInfoLoading());
    try {
      final event = await getEventInfo(eventId);
      emit(event == null ? const EventInfoNotFound() : EventInfoLoaded(event));
    } catch (_) {
      emit(const EventInfoError('No se pudo cargar el evento. Revisá tu conexión.'));
    }
  }
}
