import 'package:equatable/equatable.dart';

import '../../domain/entities/scan_record.dart';

sealed class ScanHistoryState extends Equatable {
  const ScanHistoryState();

  @override
  List<Object?> get props => [];
}

class ScanHistoryLoading extends ScanHistoryState {
  const ScanHistoryLoading();
}

class ScanHistoryLoaded extends ScanHistoryState {
  final List<ScanRecord> records;

  const ScanHistoryLoaded(this.records);

  @override
  List<Object?> get props => [records];
}

class ScanHistoryError extends ScanHistoryState {
  final String message;

  const ScanHistoryError(this.message);

  @override
  List<Object?> get props => [message];
}
