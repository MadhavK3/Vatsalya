import 'package:hive/hive.dart';

part 'dashboard_card_model.g.dart';

@HiveType(typeId: 20)
class DashboardCardModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String widgetType;

  @HiveField(3)
  int order;

  @HiveField(4)
  bool isVisible;

  @HiveField(5)
  Map<dynamic, dynamic>? settings;

  DashboardCardModel({
    required this.id,
    required this.title,
    required this.widgetType,
    this.order = 0,
    this.isVisible = true,
    this.settings,
  });

  DashboardCardModel copyWith({
    String? id,
    String? title,
    String? widgetType,
    int? order,
    bool? isVisible,
    Map<dynamic, dynamic>? settings,
  }) {
    return DashboardCardModel(
      id: id ?? this.id,
      title: title ?? this.title,
      widgetType: widgetType ?? this.widgetType,
      order: order ?? this.order,
      isVisible: isVisible ?? this.isVisible,
      settings: settings ?? this.settings,
    );
  }
}
