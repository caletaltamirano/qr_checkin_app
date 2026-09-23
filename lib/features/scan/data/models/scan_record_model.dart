import '../../domain/entities/scan_record.dart';
import '../../domain/entities/scan_result.dart';
import '../../domain/entities/ticket.dart';

class ScanRecordModel extends ScanRecord {
  const ScanRecordModel({
    required super.ticketId,
    required super.eventId,
    required super.resultType,
    required super.scannedAt,
    super.holderName,
    super.ticketType,
  });

  factory ScanRecordModel.fromEntity(ScanRecord record) {
    return ScanRecordModel(
      ticketId: record.ticketId,
      eventId: record.eventId,
      resultType: record.resultType,
      scannedAt: record.scannedAt,
      holderName: record.holderName,
      ticketType: record.ticketType,
    );
  }

  factory ScanRecordModel.fromJson(Map<String, dynamic> json) {
    return ScanRecordModel(
      ticketId: json['ticketId'] as String,
      eventId: json['eventId'] as String,
      resultType: ScanResultType.values.firstWhere(
        (e) => e.name == json['resultType'],
        orElse: () => ScanResultType.invalid,
      ),
      scannedAt: DateTime.parse(json['scannedAt'] as String),
      holderName: json['holderName'] as String?,
      ticketType: TicketType.values.where((e) => e.name == json['ticketType']).firstOrNull,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ticketId': ticketId,
      'eventId': eventId,
      'resultType': resultType.name,
      'scannedAt': scannedAt.toIso8601String(),
      'holderName': holderName,
      'ticketType': ticketType?.name,
    };
  }
}
