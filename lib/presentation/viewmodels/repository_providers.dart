import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maternal_infant_care/data/repositories/pregnancy_repository.dart';
import 'package:maternal_infant_care/data/repositories/feeding_repository.dart';
import 'package:maternal_infant_care/data/repositories/sleep_repository.dart';
import 'package:maternal_infant_care/data/repositories/growth_repository.dart';
import 'package:maternal_infant_care/data/repositories/vaccination_repository.dart';
import 'package:maternal_infant_care/data/repositories/medical_record_repository.dart';
import 'package:maternal_infant_care/data/repositories/reminder_repository.dart';
import 'package:maternal_infant_care/data/repositories/diaper_repository.dart';
import 'package:maternal_infant_care/data/repositories/dashboard_preferences_repository.dart';
import 'package:maternal_infant_care/data/repositories/kick_log_repository.dart';
import 'package:maternal_infant_care/data/repositories/contraction_repository.dart';
import 'package:maternal_infant_care/data/repositories/milestone_repository.dart';
import 'package:maternal_infant_care/data/repositories/chat_history_repository.dart';

final pregnancyRepositoryProvider = FutureProvider<PregnancyRepository>((ref) async {
  final repo = PregnancyRepository();
  await repo.init();
  return repo;
});

final feedingRepositoryProvider = FutureProvider<FeedingRepository>((ref) async {
  final repo = FeedingRepository();
  await repo.init();
  return repo;
});

final sleepRepositoryProvider = FutureProvider<SleepRepository>((ref) async {
  final repo = SleepRepository();
  await repo.init();
  return repo;
});

final growthRepositoryProvider = FutureProvider<GrowthRepository>((ref) async {
  final repo = GrowthRepository();
  await repo.init();
  return repo;
});

final vaccinationRepositoryProvider = FutureProvider<VaccinationRepository>((ref) async {
  final repo = VaccinationRepository();
  await repo.init();
  return repo;
});

final medicalRecordRepositoryProvider = FutureProvider<MedicalRecordRepository>((ref) async {
  final repo = MedicalRecordRepository();
  await repo.init();
  return repo;
});

final reminderRepositoryProvider = FutureProvider<ReminderRepository>((ref) async {
  final repo = ReminderRepository();
  await repo.init();
  return repo;
});

final diaperRepositoryProvider = FutureProvider<DiaperRepository>((ref) async {
  final repo = DiaperRepository();
  await repo.init();
  return repo;
});

final dashboardPreferencesProvider = FutureProvider<DashboardPreferencesRepository>((ref) async {
  final repo = DashboardPreferencesRepository();
  await repo.init();
  return repo;
});

final kickLogRepositoryProvider = FutureProvider<KickLogRepository>((ref) async {
  final repo = KickLogRepository();
  await repo.init();
  return repo;
});

final contractionRepositoryProvider = FutureProvider<ContractionRepository>((ref) async {
  final repo = ContractionRepository();
  await repo.init();
  return repo;
});

final milestoneRepositoryProvider = FutureProvider<MilestoneRepository>((ref) async {
  final repo = MilestoneRepository();
  await repo.init();
  await repo.initializeDefaults();
  await repo.initializeDefaults();
  return repo;
});

final chatHistoryRepositoryProvider = FutureProvider<ChatHistoryRepository>((ref) async {
  final repo = ChatHistoryRepository();
  await repo.init();
  return repo;
});

final chatSessionsProvider = FutureProvider((ref) async {
  final repo = await ref.watch(chatHistoryRepositoryProvider.future);
  return repo.getSessions();
});
