import 'package:connectivity_plus/connectivity_plus.dart';

import '../../domain/entities/scan_result.dart';
import '../../domain/entities/sync_report.dart';
import '../../domain/entities/ticket.dart';
import '../../domain/errors/no_connection_exception.dart';
import '../../domain/repositories/ticket_repository.dart';
import '../datasources/ticket_local_datasource.dart';
import '../datasources/ticket_remote_datasource.dart';
import '../models/ticket_model.dart';

class TicketRepositoryImpl implements TicketRepository {
  final TicketRemoteDataSource remoteDataSource;
  final TicketLocalDataSource localDataSource;
  final Connectivity connectivity;

  TicketRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectivity,
  });

  Future<bool> get _isOnline async {
    final result = await connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  @override
  Future<Ticket?> getTicketById(String ticketId) async {
    if (await _isOnline) {
      final ticket = await remoteDataSource.getTicketById(ticketId);
      if (ticket != null) return ticket;
    }
    return localDataSource.getCachedTicketById(ticketId);
  }

  @override
  Future<ScanResult> validateAndMarkTicket({
    required String ticketId,
    required String eventId,
    required String operatorId,
  }) async {
    final ticket = await getTicketById(ticketId);

    if (ticket == null) {
      return const ScanResult(
        type: ScanResultType.invalid,
        message: 'Ticket no encontrado',
      );
    }

    if (ticket.eventId != eventId) {
      return ScanResult(
        type: ScanResultType.wrongEvent,
        message: 'Este ticket es de otro evento',
        holderName: ticket.holderName,
        ticketType: ticket.type,
      );
    }

    if (ticket.status == TicketStatus.used) {
      return ScanResult(
        type: ScanResultType.alreadyUsed,
        message: 'Ticket ya utilizado',
        usedAt: ticket.usedAt,
        usedBy: ticket.usedBy,
        holderName: ticket.holderName,
        ticketType: ticket.type,
      );
    }

    final usedAt = DateTime.now();
    await markTicketAsUsed(ticketId: ticketId, operatorId: operatorId);

    return ScanResult(
      type: ScanResultType.valid,
      message: 'Ticket válido — ${ticket.holderName}',
      usedAt: usedAt,
      usedBy: operatorId,
      holderName: ticket.holderName,
      ticketType: ticket.type,
    );
  }

  @override
  Future<void> markTicketAsUsed({
    required String ticketId,
    required String operatorId,
  }) async {
    final usedAt = DateTime.now();

    if (await _isOnline) {
      await remoteDataSource.updateTicketStatus(
        ticketId: ticketId,
        status: 'used',
        operatorId: operatorId,
        usedAt: usedAt,
      );
    }

    await localDataSource.updateCachedTicketStatus(
      ticketId: ticketId,
      status: 'used',
      operatorId: operatorId,
      usedAt: usedAt,
    );
  }

  @override
  Future<List<Ticket>> getAllTicketsForEvent(String eventId) async {
    if (await _isOnline) {
      final tickets = await remoteDataSource.getAllTicketsForEvent(eventId);
      await localDataSource.cacheTickets(eventId, tickets);
      return tickets;
    }
    return localDataSource.getCachedTicketsForEvent(eventId);
  }

  @override
  Future<SyncReport> syncTicketsForEvent(String eventId) async {
    if (!await _isOnline) throw const NoConnectionException();

    final remoteTickets = await remoteDataSource.getAllTicketsForEvent(eventId);
    final cachedById = {
      for (final ticket in await localDataSource.getCachedTicketsForEvent(eventId)) ticket.id: ticket,
    };

    // A ticket marked as used offline only exists as "used" in the local
    // cache. Push it before overwriting the cache, otherwise the download
    // would silently undo that check-in.
    var uploaded = 0;
    final merged = <TicketModel>[];
    for (final remote in remoteTickets) {
      final cached = cachedById[remote.id];
      final pendingUpload = cached != null &&
          cached.status == TicketStatus.used &&
          remote.status == TicketStatus.valid &&
          cached.usedAt != null;

      if (pendingUpload) {
        await remoteDataSource.updateTicketStatus(
          ticketId: cached.id,
          status: TicketStatus.used.name,
          operatorId: cached.usedBy ?? '',
          usedAt: cached.usedAt!,
        );
        merged.add(cached);
        uploaded++;
      } else {
        merged.add(remote);
      }
    }

    await localDataSource.cacheTickets(eventId, merged);
    return SyncReport(downloaded: remoteTickets.length, uploaded: uploaded);
  }

  @override
  Future<int> getCachedTicketCount(String eventId) async {
    final cached = await localDataSource.getCachedTicketsForEvent(eventId);
    return cached.length;
  }
}
