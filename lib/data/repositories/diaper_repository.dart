import 'package:hive_flutter/hive_flutter.dart';
import 'package:maternal_infant_care/data/models/diaper_model.dart';

class DiaperRepository {
  static const String boxName = 'diapers';

  Future<void> init() async {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox<DiaperModel>(boxName);
    }
  }

  Future<void> addDiaper(DiaperModel diaper) async {
    final box = Hive.box<DiaperModel>(boxName);
    await box.put(diaper.id, diaper);
  }

  List<DiaperModel> getAllDiapers() {
    final box = Hive.box<DiaperModel>(boxName);
    final diapers = box.values.toList();
    diapers.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return diapers;
  }

  List<DiaperModel> getDiapersByDate(DateTime date) {
    final box = Hive.box<DiaperModel>(boxName);
    return box.values.where((d) => 
      d.timestamp.year == date.year && 
      d.timestamp.month == date.month && 
      d.timestamp.day == date.day
    ).toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<void> deleteDiaper(String id) async {
    final box = Hive.box<DiaperModel>(boxName);
    await box.delete(id);
  }

  Future<void> clearAll() async {
    final box = Hive.box<DiaperModel>(boxName);
    await box.clear();
  }
}
