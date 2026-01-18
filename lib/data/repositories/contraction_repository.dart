import 'package:hive_flutter/hive_flutter.dart';
import 'package:maternal_infant_care/data/models/contraction_model.dart';

import 'package:maternal_infant_care/core/constants/app_constants.dart';

class ContractionRepository {
  late Box<ContractionModel> _box;

  ContractionRepository();

  Future<void> init() async {
    _box = await Hive.openBox<ContractionModel>(AppConstants.contractionBox);
  }

  Future<void> addContraction(ContractionModel contraction) async {
    await _box.add(contraction);
  }

  List<ContractionModel> getContractions() {
    final list = _box.values.toList();
    list.sort((a, b) => b.startTime.compareTo(a.startTime)); // Newest first
    return list;
  }
  
  Future<void> deleteContraction(int index) async {
    await _box.deleteAt(index);
  }
  
  Future<void> clearAll() async {
    await _box.clear();
  }
}
