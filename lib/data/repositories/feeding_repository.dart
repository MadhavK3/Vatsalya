import 'package:hive_flutter/hive_flutter.dart';
import 'package:maternal_infant_care/core/constants/app_constants.dart';
import 'package:maternal_infant_care/data/models/feeding_model.dart';

class FeedingRepository {
  late Box<FeedingModel> _box;

  Future<void> init() async {
    _box = await Hive.openBox<FeedingModel>(AppConstants.feedingBox);
  }

  Future<void> saveFeeding(FeedingModel feeding) async {
    await _box.put(feeding.id, feeding);
  }

  List<FeedingModel> getAllFeedings() {
    return _box.values.toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  List<FeedingModel> getFeedingsByDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return _box.values.where((feeding) {
      return feeding.timestamp.isAfter(startOfDay) &&
          feeding.timestamp.isBefore(endOfDay);
    }).toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  List<FeedingModel> getFeedingsByDateRange(DateTime start, DateTime end) {
    return _box.values.where((feeding) {
      return feeding.timestamp.isAfter(start) && feeding.timestamp.isBefore(end);
    }).toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<void> deleteFeeding(String id) async {
    await _box.delete(id);
  }

  Future<void> clearAll() async {
    await _box.clear();
  }

  double getTotalQuantityByDate(DateTime date, String type) {
    final feedings = getFeedingsByDate(date)
        .where((f) => f.type.toLowerCase().contains(type.toLowerCase()))
        .toList();
    return feedings.fold(0.0, (sum, f) => sum + f.quantity);
  }
}
