import 'package:equatable/equatable.dart';

/// Outcome of syncing an event's tickets with the server.
class SyncReport extends Equatable {
  /// Tickets downloaded and now available offline.
  final int downloaded;

  /// Check-ins made offline that were pushed to the server.
  final int uploaded;

  const SyncReport({required this.downloaded, required this.uploaded});

  @override
  List<Object?> get props => [downloaded, uploaded];
}
