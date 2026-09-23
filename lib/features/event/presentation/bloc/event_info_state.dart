import 'package:equatable/equatable.dart';

import '../../domain/entities/event_info.dart';

sealed class EventInfoState extends Equatable {
  const EventInfoState();

  @override
  List<Object?> get props => [];
}

class EventInfoLoading extends EventInfoState {
  const EventInfoLoading();
}

class EventInfoLoaded extends EventInfoState {
  final EventInfo event;

  const EventInfoLoaded(this.event);

  @override
  List<Object?> get props => [event];
}

class EventInfoNotFound extends EventInfoState {
  const EventInfoNotFound();
}

class EventInfoError extends EventInfoState {
  final String message;

  const EventInfoError(this.message);

  @override
  List<Object?> get props => [message];
}
