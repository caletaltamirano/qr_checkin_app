import '../entities/scan_record.dart';
import '../repositories/scan_history_repository.dart';

class GetScanHistory {
  final ScanHistoryRepository repository;

  GetScanHistory(this.repository);

  Future<List<ScanRecord>> call(String eventId) => repository.getRecordsForEvent(eventId);
}
