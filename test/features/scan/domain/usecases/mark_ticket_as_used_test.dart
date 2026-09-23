import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qr_checkin_app/features/scan/domain/repositories/ticket_repository.dart';
import 'package:qr_checkin_app/features/scan/domain/usecases/mark_ticket_as_used.dart';

class MockTicketRepository extends Mock implements TicketRepository {}

void main() {
  late MockTicketRepository repository;
  late MarkTicketAsUsed usecase;

  setUp(() {
    repository = MockTicketRepository();
    usecase = MarkTicketAsUsed(repository);
  });

  test('forwards the call to repository.markTicketAsUsed with the same arguments', () async {
    when(
      () => repository.markTicketAsUsed(ticketId: 'ticket-1', operatorId: 'operator-1'),
    ).thenAnswer((_) async {});

    await usecase(ticketId: 'ticket-1', operatorId: 'operator-1');

    verify(
      () => repository.markTicketAsUsed(ticketId: 'ticket-1', operatorId: 'operator-1'),
    ).called(1);
  });
}
