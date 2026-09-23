import 'dart:convert';

import 'package:hive/hive.dart';

import '../models/ticket_model.dart';

abstract class TicketLocalDataSource {
  /// Saves the full ticket list for an event, replacing any previous cache.
  Future<void> cacheTickets(String eventId, List<TicketModel> tickets);

  /// Reads a single ticket from the local cache.
  Future<TicketModel?> getCachedTicketById(String ticketId);

  /// Reads all cached tickets for an event.
  Future<List<TicketModel>> getCachedTicketsForEvent(String eventId);

  /// Updates the status of a single cached ticket (used while offline).
  Future<void> updateCachedTicketStatus({
    required String ticketId,
    required String status,
    required String operatorId,
    required DateTime usedAt,
  });
}

class TicketLocalDataSourceImpl implements TicketLocalDataSource {
  static const String boxName = 'tickets_box';

  Box<String> get _box => Hive.box<String>(boxName);

  @override
  Future<void> cacheTickets(String eventId, List<TicketModel> tickets) async {
    for (final ticket in tickets) {
      await _box.put(ticket.id, jsonEncode(ticket.toJson()));
    }
  }

  @override
  Future<TicketModel?> getCachedTicketById(String ticketId) async {
    final raw = _box.get(ticketId);
    if (raw == null) return null;
    return TicketModel.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
      ticketId,
    );
  }

   @override
  Future<List<TicketModel>> getCachedTicketsForEvent(String eventId) async {
    final result = <TicketModel>[];
    for (final key in _box.keys) {
      final raw = _box.get(key);
      if (raw == null) continue;
      final json = jsonDecode(raw) as Map<String, dynamic>;
      if (json['eventId'] == eventId) {
        result.add(TicketModel.fromJson(json, key as String));
      }
    }
    return result;
  }

  @override
  Future<void> updateCachedTicketStatus({
    required String ticketId,
    required String status,
    required String operatorId,
    required DateTime usedAt,
  }) async {
    final existing = await getCachedTicketById(ticketId);
    if (existing == null) return;

    final updatedJson = existing.toJson();
    updatedJson['status'] = status;
    updatedJson['usedBy'] = operatorId;
    updatedJson['usedAt'] = usedAt.toIso8601String();

    await _box.put(ticketId, jsonEncode(updatedJson));
  }
}