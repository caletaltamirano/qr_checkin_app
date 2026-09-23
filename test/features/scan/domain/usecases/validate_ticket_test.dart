import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qr_checkin_app/features/scan/domain/entities/scan_result.dart';
import 'package:qr_checkin_app/features/scan/domain/repositories/ticket_repository.dart';
import 'package:qr_checkin_app/features/scan/domain/usecases/validate_ticket.dart';

class MockTicketRepository extends Mock implements TicketRepository {}

void main() {
  late MockTicketRepository repository;
  late ValidateTicket usecase;

  setUp(() {
    repository = MockTicketRepository();
    usecase = ValidateTicket(repository);
  });

  test('forwards the call to repository.validateAndMarkTicket with the same arguments', () async {
    const expected = ScanResult(type: ScanResultType.valid, message: 'Ticket válido — Jane Doe');
    when(
      () => repository.validateAndMarkTicket(
        ticketId: 'ticket-1',
        eventId: 'event-1',
        operatorId: 'operator-1',
      ),
    ).thenAnswer((_) async => expected);

    final result = await usecase(
      ticketId: 'ticket-1',
      eventId: 'event-1',
      operatorId: 'operator-1',
    );

    expect(result, expected);
    verify(
      () => repository.validateAndMarkTicket(
        ticketId: 'ticket-1',
        eventId: 'event-1',
        operatorId: 'operator-1',
      ),
    ).called(1);
  });
}
