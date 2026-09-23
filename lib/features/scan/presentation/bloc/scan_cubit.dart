import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/scan_record.dart';
import '../../domain/usecases/save_scan_record.dart';
import '../../domain/usecases/validate_ticket.dart';
import 'scan_state.dart';

class ScanCubit extends Cubit<ScanState> {
  final ValidateTicket validateTicket;
  final SaveScanRecord saveScanRecord;
  final String eventId;
  final String operatorId;

  ScanCubit({
    required this.validateTicket,
    required this.saveScanRecord,
    required this.eventId,
    required this.operatorId,
  }) : super(const ScanIdle());

  /// Called every time the camera detects a QR code.
  Future<void> onQrDetected(String ticketId) async {
    // The camera keeps firing detections for the same code many times a
    // second, so only react while idle — otherwise a result that just
    // appeared gets immediately overwritten by the next detection.
    if (state is! ScanIdle) return;

    emit(const ScanLoading());

    try {
      final result = await validateTicket(
        ticketId: ticketId,
        eventId: eventId,
        operatorId: operatorId,
      );
      emit(ScanResultReady(result));

      // The check-in already happened; failing to log it must not turn
      // a valid entry into an error on screen.
      try {
        await saveScanRecord(ScanRecord(
          ticketId: ticketId,
          eventId: eventId,
          resultType: result.type,
          scannedAt: DateTime.now(),
          holderName: result.holderName,
          ticketType: result.ticketType,
        ));
      } catch (_) {}
    } catch (e) {
      emit(ScanError('Error al validar: $e'));
    }
  }

  /// Called after showing a result, to go back to scanning.
  void resetToIdle() {
    emit(const ScanIdle());
  }
}
