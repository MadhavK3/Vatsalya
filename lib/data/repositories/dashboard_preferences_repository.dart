import 'package:hive_flutter/hive_flutter.dart';
import 'package:maternal_infant_care/data/models/dashboard_card_model.dart';
import 'package:maternal_infant_care/presentation/viewmodels/user_provider.dart';

import 'package:maternal_infant_care/core/constants/app_constants.dart';

class DashboardPreferencesRepository {
  late Box<DashboardCardModel> _box;
  // Separate defaults for different user types
  static const String _pregnantPrefix = 'pregnant_';
  static const String _toddlerPrefix = 'toddler_';

  DashboardPreferencesRepository();

  Future<void> init() async {
    _box = await Hive.openBox<DashboardCardModel>(AppConstants.dashboardBox);
  }

  // Get cards for a specific user type
  List<DashboardCardModel> getCards(UserProfileType type) {
    final prefix = type == UserProfileType.pregnant ? _pregnantPrefix : _toddlerPrefix;
    final cards = _box.values.where((card) => card.id.startsWith(prefix)).toList();
    
    if (cards.isEmpty) {
      return _initializeDefaults(type);
    }
    
    cards.sort((a, b) => a.order.compareTo(b.order));
    return cards;
  }

  // Update card order
  Future<void> updateCardOrder(UserProfileType type, List<DashboardCardModel> orderedCards) async {
    for (int i = 0; i < orderedCards.length; i++) {
      final card = orderedCards[i];
      card.order = i;
      await card.save();
    }
  }

  // Toggle visibility
  Future<void> toggleCardVisibility(String cardId, bool visible) async {
    final card = _box.values.firstWhere((c) => c.id == cardId);
    card.isVisible = visible;
    await card.save();
  }

  // Initialize default cards if none exist
  List<DashboardCardModel> _initializeDefaults(UserProfileType type) {
    List<DashboardCardModel> defaults = [];
    final prefix = type == UserProfileType.pregnant ? _pregnantPrefix : _toddlerPrefix;

    if (type == UserProfileType.pregnant) {
      defaults = [
        DashboardCardModel(id: '${prefix}daily_summary', title: 'Daily Summary', widgetType: 'daily_summary', order: 0),
        DashboardCardModel(id: '${prefix}weekly_stats', title: 'Weekly Insights', widgetType: 'weekly_stats', order: 1),
        DashboardCardModel(id: '${prefix}hospital_bag', title: 'Hospital Bag', widgetType: 'hospital_bag', order: 2),
        DashboardCardModel(id: '${prefix}symptoms', title: 'Symptom Tracker', widgetType: 'symptom_tracker', order: 3),
        DashboardCardModel(id: '${prefix}kick_counter', title: 'Kick Counter', widgetType: 'kick_counter', order: 4),
        DashboardCardModel(id: '${prefix}tips', title: 'Daily Tips', widgetType: 'daily_tips', order: 5),
      ];
    } else {
      defaults = [
        DashboardCardModel(id: '${prefix}tracker_hub', title: 'Daily Trackers', widgetType: 'tracker_hub', order: 0),
        DashboardCardModel(id: '${prefix}daily_summary', title: 'Daily Summary', widgetType: 'daily_summary', order: 1),
        DashboardCardModel(id: '${prefix}weekly_stats', title: 'Weekly Insights', widgetType: 'weekly_stats', order: 2),
        DashboardCardModel(id: '${prefix}milestones', title: 'Milestones', widgetType: 'milestones', order: 3),
        DashboardCardModel(id: '${prefix}vaccinations', title: 'Vaccinations', widgetType: 'vaccinations', order: 4),
        DashboardCardModel(id: '${prefix}growth', title: 'Growth Chart', widgetType: 'growth_chart', order: 5),
        DashboardCardModel(id: '${prefix}activity', title: 'Activity Ideas', widgetType: 'activity_suggestions', order: 6),
        DashboardCardModel(id: '${prefix}tips', title: 'Parenting Tips', widgetType: 'daily_tips', order: 7),
      ];
    }

    _box.putAll({for (var c in defaults) c.id: c});
    return defaults;
  }
}
