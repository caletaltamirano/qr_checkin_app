import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qr_checkin_app/features/scan/data/datasources/ticket_local_datasource.dart';
import 'package:qr_checkin_app/features/scan/data/datasources/ticket_remote_datasource.dart';
import 'package:qr_checkin_app/features/scan/data/models/ticket_model.dart';
import 'package:qr_checkin_app/features/scan/data/repositories/ticket_repository_impl.dart';
import 'package:qr_checkin_app/features/scan/domain/entities/scan_result.dart';
import 'package:qr_checkin_app/features/scan/domain/entities/ticket.dart';
import 'package:qr_checkin_app/features/scan/domain/errors/no_connection_exception.dart';

class MockTicketRemoteDataSource extends Mock implements TicketRemoteDataSource {}

class MockTicketLocalDataSource extends Mock implements TicketLocalDataSource {}

class MockConnectivity extends Mock implements Connectivity {}

void main() {
  late MockTicketRemoteDataSource remote;
  late MockTicketLocalDataSource local;
  late MockConnectivity connectivity;
  late TicketRepositoryImpl repository;

  final validTicket = TicketModel(
    id: 'ticket-1',
    eventId: 'event-1',
    holderName: 'Jane Doe',
    type: TicketType.general,
    status: TicketStatus.valid,
  );

  void goOnline() {
    when(() => connectivity.checkConnectivity())
        .thenAnswer((_) async => [ConnectivityResult.wifi]);
  }

  void goOffline() {
    when(() => connectivity.checkConnectivity())
        .thenAnswer((_) async => [ConnectivityResult.none]);
  }

  setUp(() {
    remote = MockTicketRemoteDataSource();
    local = MockTicketLocalDataSource();
    connectivity = MockConnectivity();
    repository = TicketRepositoryImpl(
      remoteDataSource: remote,
      localDataSource: local,
      connectivity: connectivity,
    );
  });

  group('getTicketById', () {
    test('online: returns the remote ticket without touching the local cache', () async {
      goOnline();
      when(() => remote.getTicketById('ticket-1')).thenAnswer((_) async => validTicket);

      final result = await repository.getTicketById('ticket-1');

      expect(result, validTicket);
      verifyNever(() => local.getCachedTicketById(any()));
    });

    test('online but not found remotely: falls back to the local cache', () async {
      goOnline();
      when(() => remote.getTicketById('ticket-1')).thenAnswer((_) async => null);
      when(() => local.getCachedTicketById('ticket-1')).thenAnswer((_) async => validTicket);

      final result = await repository.getTicketById('ticket-1');

      expect(result, validTicket);
    });

    test('offline: reads straight from the local cache', () async {
      goOffline();
      when(() => local.getCachedTicketById('ticket-1')).thenAnswer((_) async => validTicket);

      final result = await repository.getTicketById('ticket-1');

      expect(result, validTicket);
      verifyNever(() => remote.getTicketById(any()));
    });
  });

  group('validateAndMarkTicket', () {
    test('ticket not found -> invalid result', () async {
      goOffline();
      when(() => local.getCachedTicketById('missing')).thenAnswer((_) async => null);

      final result = await repository.validateAndMarkTicket(
        ticketId: 'missing',
        eventId: 'event-1',
        operatorId: 'operator-1',
      );

      expect(result.type, ScanResultType.invalid);
    });

    test('ticket belongs to another event -> wrongEvent result', () async {
      goOffline();
      when(() => local.getCachedTicketById('ticket-1')).thenAnswer((_) async => validTicket);

      final result = await repository.validateAndMarkTicket(
        ticketId: 'ticket-1',
        eventId: 'other-event',
        operatorId: 'operator-1',
      );

      expect(result.type, ScanResultType.wrongEvent);
    });

    test('ticket already used -> alreadyUsed result, ticket is not re-marked', () async {
      goOffline();
      final usedAt = DateTime(2026, 9, 20, 18, 30);
      final usedTicket = TicketModel(
        id: 'ticket-1',
        eventId: 'event-1',
        holderName: 'Jane Doe',
        type: TicketType.general,
        status: TicketStatus.used,
        usedAt: usedAt,
        usedBy: 'operator-0',
      );
      when(() => local.getCachedTicketById('ticket-1')).thenAnswer((_) async => usedTicket);

      final result = await repository.validateAndMarkTicket(
        ticketId: 'ticket-1',
        eventId: 'event-1',
        operatorId: 'operator-1',
      );

      expect(result.type, ScanResultType.alreadyUsed);
      expect(result.usedAt, usedAt);
      expect(result.usedBy, 'operator-0');
      expect(result.holderName, 'Jane Doe');
      expect(result.ticketType, TicketType.general);
      verifyNever(() => local.updateCachedTicketStatus(
            ticketId: any(named: 'ticketId'),
            status: any(named: 'status'),
            operatorId: any(named: 'operatorId'),
            usedAt: any(named: 'usedAt'),
          ));
    });

    test('valid ticket -> marks it as used and returns a valid result', () async {
      goOffline();
      when(() => local.getCachedTicketById('ticket-1')).thenAnswer((_) async => validTicket);
      when(() => local.updateCachedTicketStatus(
            ticketId: any(named: 'ticketId'),
            status: any(named: 'status'),
            operatorId: any(named: 'operatorId'),
            usedAt: any(named: 'usedAt'),
          )).thenAnswer((_) async {});

      final result = await repository.validateAndMarkTicket(
        ticketId: 'ticket-1',
        eventId: 'event-1',
        operatorId: 'operator-1',
      );

      expect(result.type, ScanResultType.valid);
      expect(result.holderName, 'Jane Doe');
      expect(result.ticketType, TicketType.general);
      verify(() => local.updateCachedTicketStatus(
            ticketId: 'ticket-1',
            status: 'used',
            operatorId: 'operator-1',
            usedAt: any(named: 'usedAt'),
          )).called(1);
    });
  });

  group('markTicketAsUsed', () {
    test('online: updates both remote and local', () async {
      goOnline();
      when(() => remote.updateTicketStatus(
            ticketId: any(named: 'ticketId'),
            status: any(named: 'status'),
            operatorId: any(named: 'operatorId'),
            usedAt: any(named: 'usedAt'),
          )).thenAnswer((_) async {});
      when(() => local.updateCachedTicketStatus(
            ticketId: any(named: 'ticketId'),
            status: any(named: 'status'),
            operatorId: any(named: 'operatorId'),
            usedAt: any(named: 'usedAt'),
          )).thenAnswer((_) async {});

      await repository.markTicketAsUsed(ticketId: 'ticket-1', operatorId: 'operator-1');

      verify(() => remote.updateTicketStatus(
            ticketId: 'ticket-1',
            status: 'used',
            operatorId: 'operator-1',
            usedAt: any(named: 'usedAt'),
          )).called(1);
      verify(() => local.updateCachedTicketStatus(
            ticketId: 'ticket-1',
            status: 'used',
            operatorId: 'operator-1',
            usedAt: any(named: 'usedAt'),
          )).called(1);
    });

    test('offline: only updates the local cache', () async {
      goOffline();
      when(() => local.updateCachedTicketStatus(
            ticketId: any(named: 'ticketId'),
            status: any(named: 'status'),
            operatorId: any(named: 'operatorId'),
            usedAt: any(named: 'usedAt'),
          )).thenAnswer((_) async {});

      await repository.markTicketAsUsed(ticketId: 'ticket-1', operatorId: 'operator-1');

      verifyNever(() => remote.updateTicketStatus(
            ticketId: any(named: 'ticketId'),
            status: any(named: 'status'),
            operatorId: any(named: 'operatorId'),
            usedAt: any(named: 'usedAt'),
          ));
    });
  });

  group('getAllTicketsForEvent', () {
    test('online: fetches from remote and caches locally', () async {
      goOnline();
      when(() => remote.getAllTicketsForEvent('event-1'))
          .thenAnswer((_) async => [validTicket]);
      when(() => local.cacheTickets('event-1', [validTicket])).thenAnswer((_) async {});

      final result = await repository.getAllTicketsForEvent('event-1');

      expect(result, [validTicket]);
      verify(() => local.cacheTickets('event-1', [validTicket])).called(1);
    });

    test('offline: reads straight from the local cache', () async {
      goOffline();
      when(() => local.getCachedTicketsForEvent('event-1'))
          .thenAnswer((_) async => [validTicket]);

      final result = await repository.getAllTicketsForEvent('event-1');

      expect(result, [validTicket]);
      verifyNever(() => remote.getAllTicketsForEvent(any()));
    });
  });

  group('syncTicketsForEvent', () {
    void stubCaching() {
      when(() => local.cacheTickets(any(), any())).thenAnswer((_) async {});
    }

    test('offline: throws NoConnectionException without touching anything', () async {
      goOffline();

      expect(
        () => repository.syncTicketsForEvent('event-1'),
        throwsA(isA<NoConnectionException>()),
      );
      verifyNever(() => remote.getAllTicketsForEvent(any()));
    });

    test('online: downloads and caches every ticket of the event', () async {
      goOnline();
      stubCaching();
      when(() => remote.getAllTicketsForEvent('event-1')).thenAnswer((_) async => [validTicket]);
      when(() => local.getCachedTicketsForEvent('event-1')).thenAnswer((_) async => []);

      final report = await repository.syncTicketsForEvent('event-1');

      expect(report.downloaded, 1);
      expect(report.uploaded, 0);
      verify(() => local.cacheTickets('event-1', [validTicket])).called(1);
    });

    test('pushes an offline check-in and keeps it used instead of overwriting it', () async {
      goOnline();
      stubCaching();
      final usedAt = DateTime(2026, 9, 20, 21, 5);
      final usedOffline = TicketModel(
        id: 'ticket-1',
        eventId: 'event-1',
        holderName: 'Jane Doe',
        type: TicketType.general,
        status: TicketStatus.used,
        usedAt: usedAt,
        usedBy: 'operator-1',
      );
      when(() => remote.getAllTicketsForEvent('event-1')).thenAnswer((_) async => [validTicket]);
      when(() => local.getCachedTicketsForEvent('event-1')).thenAnswer((_) async => [usedOffline]);
      when(() => remote.updateTicketStatus(
            ticketId: any(named: 'ticketId'),
            status: any(named: 'status'),
            operatorId: any(named: 'operatorId'),
            usedAt: any(named: 'usedAt'),
          )).thenAnswer((_) async {});

      final report = await repository.syncTicketsForEvent('event-1');

      expect(report.uploaded, 1);
      verify(() => remote.updateTicketStatus(
            ticketId: 'ticket-1',
            status: 'used',
            operatorId: 'operator-1',
            usedAt: usedAt,
          )).called(1);
      verify(() => local.cacheTickets('event-1', [usedOffline])).called(1);
    });
  });
}
