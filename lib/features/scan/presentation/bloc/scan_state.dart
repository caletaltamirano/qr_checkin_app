import 'package:equatable/equatable.dart';

import '../../domain/entities/scan_result.dart';

abstract class ScanState extends Equatable {
  const ScanState();

  @override
  List<Object?> get props => [];
}

/// Initial state, camera is ready and waiting for a QR code.
class ScanIdle extends ScanState {
  const ScanIdle();
}

/// A QR code was detected and is being validated.
class ScanLoading extends ScanState {
  const ScanLoading();
}

/// Validation finished, holding the result to show on screen.
class ScanResultReady extends ScanState {
  final ScanResult result;

  const ScanResultReady(this.result);

  @override
  List<Object?> get props => [result];
}

/// Something went wrong (e.g. no connection and no local cache).
class ScanError extends ScanState {
  final String message;

  const ScanError(this.message);

  @override
  List<Object?> get props => [message];
}