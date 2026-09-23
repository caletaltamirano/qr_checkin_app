import '../entities/scan_record.dart';
import '../repositories/scan_history_repository.dart';

class SaveScanRecord {
  final ScanHistoryRepository repository;

  SaveScanRecord(this.repository);

  Future<void> call(ScanRecord record) => repository.saveRecord(record);
}
