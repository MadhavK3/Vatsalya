import 'package:hive_flutter/hive_flutter.dart';
import 'package:maternal_infant_care/core/constants/app_constants.dart';
import 'package:maternal_infant_care/data/models/pregnancy_model.dart';

class PregnancyRepository {
  late Box<PregnancyModel> _box;

  Future<void> init() async {
    try {
      _box = await Hive.openBox<PregnancyModel>(AppConstants.pregnancyBox);
    } catch (e) {
      print('Error opening pregnancy box: $e');
      // Try to delete and recreate the box
      await Hive.deleteBoxFromDisk(AppConstants.pregnancyBox);
      _box = await Hive.openBox<PregnancyModel>(AppConstants.pregnancyBox);
    }
  }

  Future<void> savePregnancy(PregnancyModel pregnancy) async {
    await _box.put(pregnancy.id, pregnancy);
  }

  PregnancyModel? getPregnancy() {
    if (_box.isEmpty) return null;
    try {
      return _box.values.first;
    } catch (e) {
      print('Error reading pregnancy data: $e');
      // Clear corrupted data
      _box.clear();
      return null;
    }
  }

  Future<void> deletePregnancy(String id) async {
    await _box.delete(id);
  }

  Future<void> clearAll() async {
    await _box.clear();
  }
}
