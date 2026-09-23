import 'package:equatable/equatable.dart';

import '../../domain/entities/sync_report.dart';

sealed class SyncState extends Equatable {
  /// Tickets currently available offline; null until it's been read.
  final int? cachedCount;

  const SyncState({this.cachedCount});

  @override
  List<Object?> get props => [cachedCount];
}

class SyncIdle extends SyncState {
  const SyncIdle({super.cachedCount});
}

class SyncInProgress extends SyncState {
  const SyncInProgress({super.cachedCount});
}

class SyncSuccess extends SyncState {
  final SyncReport report;
  final DateTime syncedAt;

  const SyncSuccess({required this.report, required this.syncedAt, super.cachedCount});

  @override
  List<Object?> get props => [report, syncedAt, cachedCount];
}

class SyncFailure extends SyncState {
  final String message;

  const SyncFailure(this.message, {super.cachedCount});

  @override
  List<Object?> get props => [message, cachedCount];
}
