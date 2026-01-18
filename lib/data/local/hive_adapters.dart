import 'package:hive_flutter/hive_flutter.dart';
import 'package:maternal_infant_care/data/models/pregnancy_model.dart';
import 'package:maternal_infant_care/data/models/feeding_model.dart';
import 'package:maternal_infant_care/data/models/sleep_model.dart';
import 'package:maternal_infant_care/data/models/growth_model.dart';
import 'package:maternal_infant_care/data/models/vaccination_model.dart';
import 'package:maternal_infant_care/data/models/medical_record_model.dart';
import 'package:maternal_infant_care/data/models/reminder_model.dart';
import 'package:maternal_infant_care/data/models/diaper_model.dart';
import 'package:maternal_infant_care/data/models/dashboard_card_model.dart';
import 'package:maternal_infant_care/data/models/kick_log_model.dart';
import 'package:maternal_infant_care/data/models/contraction_model.dart';
import 'package:maternal_infant_care/data/models/milestone_model.dart';
import 'package:maternal_infant_care/data/models/chat_message_model.dart';
import 'package:maternal_infant_care/data/models/chat_session_model.dart';

class HiveAdapters {
  static Future<void> registerAdapters() async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(PregnancyModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(FeedingModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(SleepModelAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(GrowthModelAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(VaccinationModelAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(MedicalRecordModelAdapter());
    }
    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(ReminderModelAdapter());
    }
    if (!Hive.isAdapterRegistered(7)) {
      Hive.registerAdapter(DiaperModelAdapter());
    }
    if (!Hive.isAdapterRegistered(20)) {
      Hive.registerAdapter(DashboardCardModelAdapter());
    }
    if (!Hive.isAdapterRegistered(21)) {
      Hive.registerAdapter(KickLogModelAdapter());
    }
    if (!Hive.isAdapterRegistered(22)) {
      Hive.registerAdapter(ContractionModelAdapter());
    }
    if (!Hive.isAdapterRegistered(23)) {
      Hive.registerAdapter(MilestoneModelAdapter());
    }
    if (!Hive.isAdapterRegistered(30)) {
       Hive.registerAdapter(ChatMessageModelAdapter());
    }
    if (!Hive.isAdapterRegistered(31)) {
       Hive.registerAdapter(ChatSessionModelAdapter());
    }
  }
}
