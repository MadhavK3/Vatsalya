import 'package:hive_flutter/hive_flutter.dart';
import 'package:maternal_infant_care/data/models/kick_log_model.dart';
import 'package:uuid/uuid.dart';

import 'package:maternal_infant_care/core/constants/app_constants.dart';

class KickLogRepository {
  late Box<KickLogModel> _box;

  KickLogRepository();

  Future<void> init() async {
    _box = await Hive.openBox<KickLogModel>(AppConstants.kickLogBox);
  }

  Future<void> saveSession(int count, Duration duration, {DateTime? startTime}) async {
    final start = startTime ?? DateTime.now().subtract(duration);
    final end = DateTime.now();
    
    final log = KickLogModel(
      id: const Uuid().v4(),
      sessionStart: start,
      sessionEnd: end,
      kickCount: count,
    );
    
    await _box.add(log);
  }

  List<KickLogModel> getHistory() {
    final list = _box.values.toList();
    list.sort((a, b) => b.sessionStart.compareTo(a.sessionStart)); // Newest first
    return list;
  }
}
