import 'package:hive_flutter/hive_flutter.dart';
import 'package:maternal_infant_care/core/constants/app_constants.dart';
import 'package:maternal_infant_care/data/models/medical_record_model.dart';

class MedicalRecordRepository {
  late Box<MedicalRecordModel> _box;

  Future<void> init() async {
    _box = await Hive.openBox<MedicalRecordModel>(AppConstants.medicalBox);
  }

  Future<void> saveRecord(MedicalRecordModel record) async {
    await _box.put(record.id, record);
  }

  List<MedicalRecordModel> getAllRecords() {
    return _box.values.toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  List<MedicalRecordModel> getRecordsByType(String type) {
    return _box.values
        .where((r) => r.type.toLowerCase() == type.toLowerCase())
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> deleteRecord(String id) async {
    await _box.delete(id);
  }

  Future<void> clearAll() async {
    await _box.clear();
  }
}
