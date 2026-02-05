import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maternal_infant_care/data/models/reminder_model.dart';
import 'package:maternal_infant_care/domain/services/smart_reminder_engine.dart';
import 'package:maternal_infant_care/presentation/viewmodels/repository_providers.dart';
import 'package:maternal_infant_care/presentation/viewmodels/user_provider.dart';

final smartRemindersProvider = FutureProvider<List<ReminderModel>>((ref) async {
  final userProfile = ref.watch(userProfileProvider);
  if (userProfile == null) return [];

  // Wait for repositories to be ready
  final pregnancyRepo = await ref.watch(pregnancyRepositoryProvider.future);
  final feedingRepo = await ref.watch(feedingRepositoryProvider.future);
  final sleepRepo = await ref.watch(sleepRepositoryProvider.future);
  final vaccRepo = await ref.watch(vaccinationRepositoryProvider.future);

  final engine = SmartReminderEngine(
    pregnancyRepo: pregnancyRepo,
    feedingRepo: feedingRepo,
    sleepRepo: sleepRepo,
    vaccRepo: vaccRepo,
  );

  final generated = await engine.generateReminders(userProfile);

  // Filter out reminders that already exist (active or completed)
  try {
    final reminderRepo = await ref.watch(reminderRepositoryProvider.future);
    final existingReminders = reminderRepo.getAllReminders();
    final existingIds = existingReminders.map((r) => r.id).toSet();
    
    return generated.where((r) => !existingIds.contains(r.id)).toList();
  } catch (e) {
    // Fallback if repo not available
    return generated;
  }
});
