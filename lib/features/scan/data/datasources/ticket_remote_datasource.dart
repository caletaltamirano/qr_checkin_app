import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/ticket_model.dart';

abstract class TicketRemoteDataSource {
  Future<TicketModel?> getTicketById(String ticketId);

  Future<void> updateTicketStatus({
    required String ticketId,
    required String status,
    required String operatorId,
    required DateTime usedAt,
  });

  Future<List<TicketModel>> getAllTicketsForEvent(String eventId);
}

class TicketRemoteDataSourceImpl implements TicketRemoteDataSource {
  final FirebaseFirestore firestore;

  TicketRemoteDataSourceImpl(this.firestore);

  CollectionReference<Map<String, dynamic>> get _ticketsRef =>
      firestore.collection('tickets');

  @override
  Future<TicketModel?> getTicketById(String ticketId) async {
    final doc = await _ticketsRef.doc(ticketId).get();
    if (!doc.exists) return null;
    return TicketModel.fromJson(doc.data()!, doc.id);
  }

  @override
  Future<void> updateTicketStatus({
    required String ticketId,
    required String status,
    required String operatorId,
    required DateTime usedAt,
  }) {
    return _ticketsRef.doc(ticketId).update({
      'status': status,
      'usedBy': operatorId,
      'usedAt': usedAt.toIso8601String(),
    });
  }

  @override
  Future<List<TicketModel>> getAllTicketsForEvent(String eventId) async {
    final snapshot =
        await _ticketsRef.where('eventId', isEqualTo: eventId).get();
    return snapshot.docs
        .map((doc) => TicketModel.fromJson(doc.data(), doc.id))
        .toList();
  }
}