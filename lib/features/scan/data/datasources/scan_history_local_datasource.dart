import 'dart:convert';

import 'package:hive/hive.dart';

import '../models/scan_record_model.dart';

abstract class ScanHistoryLocalDataSource {
  Future<void> addRecord(ScanRecordModel record);

  Future<List<ScanRecordModel>> getRecordsForEvent(String eventId);
}

class ScanHistoryLocalDataSourceImpl implements ScanHistoryLocalDataSource {
  static const String boxName = 'scan_history_box';

  Box<String> get _box => Hive.box<String>(boxName);

  @override
  Future<void> addRecord(ScanRecordModel record) async {
    await _box.add(jsonEncode(record.toJson()));
  }

  @override
  Future<List<ScanRecordModel>> getRecordsForEvent(String eventId) async {
    return _box.values
        .map((raw) => ScanRecordModel.fromJson(jsonDecode(raw) as Map<String, dynamic>))
        .where((record) => record.eventId == eventId)
        .toList();
  }
}
