import '../../domain/entities/ticket.dart';

class TicketModel extends Ticket {
  const TicketModel({
    required super.id,
    required super.eventId,
    required super.holderName,
    required super.type,
    required super.status,
    super.usedAt,
    super.usedBy,
  });

  /// Creates a TicketModel from a Firestore document map.
  factory TicketModel.fromJson(Map<String, dynamic> json, String id) {
    return TicketModel(
      id: id,
      eventId: json['eventId'] as String,
      holderName: json['holderName'] as String,
      type: TicketType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TicketType.general,
      ),
      status: TicketStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TicketStatus.valid,
      ),
      usedAt: json['usedAt'] != null
          ? DateTime.tryParse(json['usedAt'] as String)
          : null,
      usedBy: json['usedBy'] as String?,
    );
  }

  /// Converts this model to a Firestore-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'holderName': holderName,
      'type': type.name,
      'status': status.name,
      'usedAt': usedAt?.toIso8601String(),
      'usedBy': usedBy,
    };
  }
}