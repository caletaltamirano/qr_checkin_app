import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/event_info.dart';

class EventInfoModel extends EventInfo {
  const EventInfoModel({required super.id, required super.name, super.date, super.capacity});

  /// Creates an EventInfoModel from a Firestore `events/{eventId}` document.
  /// `date` may be stored as a Firestore Timestamp or an ISO-8601 string.
  factory EventInfoModel.fromJson(Map<String, dynamic> json, String id) {
    final rawDate = json['date'];
    return EventInfoModel(
      id: id,
      name: json['name'] as String? ?? id,
      date: switch (rawDate) {
        Timestamp() => rawDate.toDate(),
        String() => DateTime.tryParse(rawDate),
        _ => null,
      },
      capacity: (json['capacity'] as num?)?.toInt(),
    );
  }
}
