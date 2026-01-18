import 'package:hive_flutter/hive_flutter.dart';
import 'package:maternal_infant_care/core/constants/app_constants.dart';
import 'package:maternal_infant_care/data/models/vaccination_model.dart';

class VaccinationRepository {
  late Box<VaccinationModel> _box;

  Future<void> init() async {
    _box = await Hive.openBox<VaccinationModel>(AppConstants.vaccinationBox);
  }

  Future<void> saveVaccination(VaccinationModel vaccination) async {
    await _box.put(vaccination.id, vaccination);
  }

  List<VaccinationModel> getAllVaccinations() {
    return _box.values.toList()..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
  }

  List<VaccinationModel> getUpcomingVaccinations() {
    final now = DateTime.now();
    return _box.values
        .where((v) => !v.isCompleted && v.scheduledDate.isAfter(now))
        .toList()
      ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
  }

  List<VaccinationModel> getCompletedVaccinations() {
    return _box.values.where((v) => v.isCompleted).toList()
      ..sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));
  }

  List<VaccinationModel> getVaccinationsDueSoon({int daysAhead = 7}) {
    final now = DateTime.now();
    final limit = now.add(Duration(days: daysAhead));
    return _box.values
        .where((v) =>
            !v.isCompleted &&
            v.scheduledDate.isAfter(now) &&
            v.scheduledDate.isBefore(limit))
        .toList()
      ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
  }

  Future<void> deleteVaccination(String id) async {
    await _box.delete(id);
  }

  Future<void> clearAll() async {
    await _box.clear();
  }
}
