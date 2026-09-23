import 'package:equatable/equatable.dart';

enum TicketType { general, vip, staff }

enum TicketStatus { valid, used, cancelled }

class Ticket extends Equatable {
  final String id;
  final String eventId;
  final String holderName;
  final TicketType type;
  final TicketStatus status;
  final DateTime? usedAt;
  final String? usedBy;

  const Ticket({
    required this.id,
    required this.eventId,
    required this.holderName,
    required this.type,
    required this.status,
    this.usedAt,
    this.usedBy,
  });

  @override
  List<Object?> get props => [
        id,
        eventId,
        holderName,
        type,
        status,
        usedAt,
        usedBy,
      ];
}