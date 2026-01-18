import 'package:hive_flutter/hive_flutter.dart';
import 'package:maternal_infant_care/data/models/milestone_model.dart';

import 'package:maternal_infant_care/core/constants/app_constants.dart';

class MilestoneRepository {
  late Box<MilestoneModel> _box;

  MilestoneRepository();

  Future<void> init() async {
    _box = await Hive.openBox<MilestoneModel>(AppConstants.milestoneBox);
  }

  Future<void> initializeDefaults() async {
    if (_box.isNotEmpty) return;

    // Example milestones
    final defaults = [
      MilestoneModel(id: 'm1', title: 'Smiles at people', category: 'social', ageMonthsMin: 2, ageMonthsMax: 2, description: "Your baby starts to smile at people."),
      MilestoneModel(id: 'm2', title: 'Holds head steady', category: 'motor', ageMonthsMin: 2, ageMonthsMax: 2, description: "Holds head up without support."),
      MilestoneModel(id: 'm3', title: 'Babbles', category: 'language', ageMonthsMin: 4, ageMonthsMax: 4, description: "Makes sounds like 'ba-ba'."),
      MilestoneModel(id: 'm4', title: 'Rolls over', category: 'motor', ageMonthsMin: 4, ageMonthsMax: 6, description: "Rolls from tummy to back."),
      MilestoneModel(id: 'm5', title: 'Sits without support', category: 'motor', ageMonthsMin: 6, ageMonthsMax: 8, description: "Can sit alone for a while."),
      MilestoneModel(id: 'm6', title: 'Crawls', category: 'motor', ageMonthsMin: 7, ageMonthsMax: 10, description: "Moves around on hands and knees."),
    ];

    for (var m in defaults) {
      await _box.put(m.id, m);
    }
  }

  List<MilestoneModel> getAllMilestones() {
    final list = _box.values.toList();
    list.sort((a, b) => a.ageMonthsMin.compareTo(b.ageMonthsMin));
    return list;
  }

  Future<void> toggleCompletion(String id, bool completed) async {
    final milestone = _box.get(id);
    if (milestone != null) {
      milestone.isCompleted = completed;
      milestone.completedDate = completed ? DateTime.now() : null;
      await milestone.save();
    }
  }
}
