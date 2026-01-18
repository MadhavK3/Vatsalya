import 'package:hive_flutter/hive_flutter.dart';
import 'package:maternal_infant_care/core/constants/app_constants.dart';
import 'package:maternal_infant_care/data/models/sleep_model.dart';

class SleepRepository {
  late Box<SleepModel> _box;

  Future<void> init() async {
    _box = await Hive.openBox<SleepModel>(AppConstants.sleepBox);
  }

  Future<void> saveSleep(SleepModel sleep) async {
    await _box.put(sleep.id, sleep);
  }

  List<SleepModel> getAllSleeps() {
    return _box.values.toList()..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  List<SleepModel> getSleepsByDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return _box.values.where((sleep) {
      return sleep.startTime.isAfter(startOfDay) &&
          sleep.startTime.isBefore(endOfDay);
    }).toList()..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  List<SleepModel> getActiveSleeps() {
    return _box.values.where((sleep) => sleep.isActive).toList();
  }

  SleepModel? getCurrentActiveSleep() {
    final active = getActiveSleeps();
    if (active.isEmpty) return null;
    return active.first;
  }

  Future<void> deleteSleep(String id) async {
    await _box.delete(id);
  }

  Future<void> clearAll() async {
    await _box.clear();
  }

  double getTotalSleepHoursByDate(DateTime date) {
    final sleeps = getSleepsByDate(date);
    double totalHours = 0;
    for (var sleep in sleeps) {
      totalHours += sleep.hours;
    }
    return totalHours;
  }
}
