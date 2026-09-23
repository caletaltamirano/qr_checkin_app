import '../entities/scan_record.dart';

abstract class ScanHistoryRepository {
  Future<void> saveRecord(ScanRecord record);

  /// Returns the event's records, newest first.
  Future<List<ScanRecord>> getRecordsForEvent(String eventId);
}
