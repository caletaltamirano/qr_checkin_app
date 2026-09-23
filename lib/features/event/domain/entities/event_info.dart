import 'package:equatable/equatable.dart';

class EventInfo extends Equatable {
  final String id;
  final String name;
  final DateTime? date;
  final int? capacity;

  const EventInfo({required this.id, required this.name, this.date, this.capacity});

  @override
  List<Object?> get props => [id, name, date, capacity];
}
