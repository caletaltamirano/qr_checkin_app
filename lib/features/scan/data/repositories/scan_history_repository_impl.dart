import '../../domain/entities/scan_record.dart';
import '../../domain/repositories/scan_history_repository.dart';
import '../datasources/scan_history_local_datasource.dart';
import '../models/scan_record_model.dart';

class ScanHistoryRepositoryImpl implements ScanHistoryRepository {
  final ScanHistoryLocalDataSource localDataSource;

  ScanHistoryRepositoryImpl({required this.localDataSource});

  @override
  Future<void> saveRecord(ScanRecord record) {
    return localDataSource.addRecord(ScanRecordModel.fromEntity(record));
  }

  @override
  Future<List<ScanRecord>> getRecordsForEvent(String eventId) async {
    final records = await localDataSource.getRecordsForEvent(eventId);
    records.sort((a, b) => b.scannedAt.compareTo(a.scannedAt));
    return records;
  }
}
