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
    // Normalize to start of today to include vaccinations due today
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    return _box.values
        .where((v) {
          if (v.isCompleted) return false;
          // Normalize scheduled date to compare just the date part
          final scheduledDay = DateTime(v.scheduledDate.year, v.scheduledDate.month, v.scheduledDate.day);
          return !scheduledDay.isBefore(today); // Include today and future
        })
        .toList()
      ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
  }

  List<VaccinationModel> getCompletedVaccinations() {
    return _box.values.where((v) => v.isCompleted).toList()
      ..sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));
  }

  List<VaccinationModel> getVaccinationsDueSoon({int daysAhead = 7}) {
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final limit = today.add(Duration(days: daysAhead));
    return _box.values
        .where((v) {
          if (v.isCompleted) return false;
          final scheduledDay = DateTime(v.scheduledDate.year, v.scheduledDate.month, v.scheduledDate.day);
          return !scheduledDay.isBefore(today) && scheduledDay.isBefore(limit);
        })
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
