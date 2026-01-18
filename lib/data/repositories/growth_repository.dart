import 'package:hive_flutter/hive_flutter.dart';
import 'package:maternal_infant_care/core/constants/app_constants.dart';
import 'package:maternal_infant_care/data/models/growth_model.dart';

class GrowthRepository {
  late Box<GrowthModel> _box;

  Future<void> init() async {
    _box = await Hive.openBox<GrowthModel>(AppConstants.growthBox);
  }

  Future<void> saveGrowth(GrowthModel growth) async {
    await _box.put(growth.id, growth);
  }

  List<GrowthModel> getAllGrowths() {
    return _box.values.toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  GrowthModel? getLatestGrowth() {
    if (_box.isEmpty) return null;
    return getAllGrowths().first;
  }

  GrowthModel? getGrowthByAge(int ageInDays) {
    final growths = getAllGrowths();
    for (var growth in growths) {
      if (growth.ageInDays == ageInDays) {
        return growth;
      }
    }
    return null;
  }

  Future<void> deleteGrowth(String id) async {
    await _box.delete(id);
  }

  Future<void> clearAll() async {
    await _box.clear();
  }
}
