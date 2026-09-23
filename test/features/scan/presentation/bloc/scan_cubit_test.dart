import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qr_checkin_app/features/scan/domain/entities/scan_record.dart';
import 'package:qr_checkin_app/features/scan/domain/entities/scan_result.dart';
import 'package:qr_checkin_app/features/scan/domain/entities/ticket.dart';
import 'package:qr_checkin_app/features/scan/domain/usecases/save_scan_record.dart';
import 'package:qr_checkin_app/features/scan/domain/usecases/validate_ticket.dart';
import 'package:qr_checkin_app/features/scan/presentation/bloc/scan_cubit.dart';
import 'package:qr_checkin_app/features/scan/presentation/bloc/scan_state.dart';

class MockValidateTicket extends Mock implements ValidateTicket {}

class MockSaveScanRecord extends Mock implements SaveScanRecord {}

void main() {
  late MockValidateTicket validateTicket;
  late MockSaveScanRecord saveScanRecord;

  setUpAll(() {
    registerFallbackValue(ScanRecord(
      ticketId: 'fallback',
      eventId: 'fallback',
      resultType: ScanResultType.invalid,
      scannedAt: DateTime(2026),
    ));
  });

  setUp(() {
    validateTicket = MockValidateTicket();
    saveScanRecord = MockSaveScanRecord();
    when(() => saveScanRecord(any())).thenAnswer((_) async {});
  });

  ScanCubit buildCubit() => ScanCubit(
        validateTicket: validateTicket,
        saveScanRecord: saveScanRecord,
        eventId: 'event-1',
        operatorId: 'operator-1',
      );

  blocTest<ScanCubit, ScanState>(
    'emits [ScanLoading, ScanResultReady] when validation succeeds',
    setUp: () {
      when(
        () => validateTicket(
          ticketId: 'ticket-1',
          eventId: 'event-1',
          operatorId: 'operator-1',
        ),
      ).thenAnswer(
        (_) async => const ScanResult(type: ScanResultType.valid, message: 'Ticket válido'),
      );
    },
    build: buildCubit,
    act: (cubit) => cubit.onQrDetected('ticket-1'),
    expect: () => [
      const ScanLoading(),
      const ScanResultReady(ScanResult(type: ScanResultType.valid, message: 'Ticket válido')),
    ],
  );

  blocTest<ScanCubit, ScanState>(
    'emits [ScanLoading, ScanError] when validation throws',
    setUp: () {
      when(
        () => validateTicket(
          ticketId: 'ticket-1',
          eventId: 'event-1',
          operatorId: 'operator-1',
        ),
      ).thenThrow(Exception('network down'));
    },
    build: buildCubit,
    act: (cubit) => cubit.onQrDetected('ticket-1'),
    expect: () => [const ScanLoading(), isA<ScanError>()],
  );

  blocTest<ScanCubit, ScanState>(
    'ignores a new scan while one is already loading',
    setUp: () {
      when(
        () => validateTicket(
          ticketId: any(named: 'ticketId'),
          eventId: any(named: 'eventId'),
          operatorId: any(named: 'operatorId'),
        ),
      ).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return const ScanResult(type: ScanResultType.valid, message: 'ok');
      });
    },
    build: buildCubit,
    act: (cubit) async {
      unawaited(cubit.onQrDetected('ticket-1'));
      await cubit.onQrDetected('ticket-2');
    },
    wait: const Duration(milliseconds: 100),
    expect: () => [const ScanLoading(), isA<ScanResultReady>()],
    verify: (_) {
      verify(
        () => validateTicket(
          ticketId: any(named: 'ticketId'),
          eventId: any(named: 'eventId'),
          operatorId: any(named: 'operatorId'),
        ),
      ).called(1);
    },
  );

  blocTest<ScanCubit, ScanState>(
    'ignores repeated camera detections while a result is already on screen '
    '(regression test for the flicker bug)',
    seed: () => const ScanResultReady(
      ScanResult(type: ScanResultType.valid, message: 'Ticket válido'),
    ),
    build: buildCubit,
    act: (cubit) => cubit.onQrDetected('ticket-1'),
    expect: () => <ScanState>[],
    verify: (_) {
      verifyNever(
        () => validateTicket(
          ticketId: any(named: 'ticketId'),
          eventId: any(named: 'eventId'),
          operatorId: any(named: 'operatorId'),
        ),
      );
    },
  );

  blocTest<ScanCubit, ScanState>(
    'resetToIdle emits ScanIdle',
    build: buildCubit,
    seed: () => const ScanError('boom'),
    act: (cubit) => cubit.resetToIdle(),
    expect: () => [const ScanIdle()],
  );

  blocTest<ScanCubit, ScanState>(
    'saves every scan to the history with the ticket details',
    setUp: () {
      when(
        () => validateTicket(
          ticketId: 'ticket-1',
          eventId: 'event-1',
          operatorId: 'operator-1',
        ),
      ).thenAnswer(
        (_) async => const ScanResult(
          type: ScanResultType.valid,
          message: 'Ticket válido',
          holderName: 'Jane Doe',
          ticketType: TicketType.vip,
        ),
      );
    },
    build: buildCubit,
    act: (cubit) => cubit.onQrDetected('ticket-1'),
    verify: (_) {
      final record = verify(() => saveScanRecord(captureAny())).captured.single as ScanRecord;
      expect(record.ticketId, 'ticket-1');
      expect(record.eventId, 'event-1');
      expect(record.resultType, ScanResultType.valid);
      expect(record.holderName, 'Jane Doe');
      expect(record.ticketType, TicketType.vip);
    },
  );

  blocTest<ScanCubit, ScanState>(
    'still shows the result when saving the history fails',
    setUp: () {
      when(
        () => validateTicket(
          ticketId: 'ticket-1',
          eventId: 'event-1',
          operatorId: 'operator-1',
        ),
      ).thenAnswer(
        (_) async => const ScanResult(type: ScanResultType.valid, message: 'Ticket válido'),
      );
      when(() => saveScanRecord(any())).thenThrow(Exception('disk full'));
    },
    build: buildCubit,
    act: (cubit) => cubit.onQrDetected('ticket-1'),
    expect: () => [const ScanLoading(), isA<ScanResultReady>()],
  );
}
