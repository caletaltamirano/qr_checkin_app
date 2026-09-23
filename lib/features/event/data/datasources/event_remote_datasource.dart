import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/event_info_model.dart';

abstract class EventRemoteDataSource {
  Future<EventInfoModel?> getEventById(String eventId);
}

class EventRemoteDataSourceImpl implements EventRemoteDataSource {
  final FirebaseFirestore firestore;

  EventRemoteDataSourceImpl(this.firestore);

  @override
  Future<EventInfoModel?> getEventById(String eventId) async {
    final doc = await firestore.collection('events').doc(eventId).get();
    if (!doc.exists) return null;
    return EventInfoModel.fromJson(doc.data()!, doc.id);
  }
}
