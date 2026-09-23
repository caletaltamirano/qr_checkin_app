import 'package:flutter_test/flutter_test.dart';
import 'package:qr_checkin_app/features/scan/data/models/ticket_model.dart';
import 'package:qr_checkin_app/features/scan/domain/entities/ticket.dart';

void main() {
  group('TicketModel.fromJson', () {
    test('parses a full Firestore document', () {
      final model = TicketModel.fromJson({
        'eventId': 'event-1',
        'holderName': 'Jane Doe',
        'type': 'vip',
        'status': 'used',
        'usedAt': '2026-09-20T18:30:00.000Z',
        'usedBy': 'operator-1',
      }, 'ticket-1');

      expect(model.id, 'ticket-1');
      expect(model.eventId, 'event-1');
      expect(model.holderName, 'Jane Doe');
      expect(model.type, TicketType.vip);
      expect(model.status, TicketStatus.used);
      expect(model.usedAt, DateTime.parse('2026-09-20T18:30:00.000Z'));
      expect(model.usedBy, 'operator-1');
    });

    test('defaults to general/valid for unknown type or status values', () {
      final model = TicketModel.fromJson({
        'eventId': 'event-1',
        'holderName': 'Jane Doe',
        'type': 'unknown-type',
        'status': 'unknown-status',
        'usedAt': null,
        'usedBy': null,
      }, 'ticket-1');

      expect(model.type, TicketType.general);
      expect(model.status, TicketStatus.valid);
      expect(model.usedAt, isNull);
      expect(model.usedBy, isNull);
    });
  });

  test('toJson/fromJson round trip preserves all fields', () {
    final original = TicketModel(
      id: 'ticket-1',
      eventId: 'event-1',
      holderName: 'Jane Doe',
      type: TicketType.staff,
      status: TicketStatus.used,
      usedAt: DateTime.parse('2026-09-20T18:30:00.000Z'),
      usedBy: 'operator-1',
    );

    final roundTripped = TicketModel.fromJson(original.toJson(), original.id);

    expect(roundTripped, original);
  });
}
