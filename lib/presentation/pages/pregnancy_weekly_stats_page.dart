import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:maternal_infant_care/presentation/viewmodels/repository_providers.dart';
import 'package:maternal_infant_care/data/models/kick_log_model.dart';
import 'package:maternal_infant_care/data/models/contraction_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PregnancyWeeklyStatsPage extends ConsumerStatefulWidget {
  const PregnancyWeeklyStatsPage({super.key});

  @override
  ConsumerState<PregnancyWeeklyStatsPage> createState() => _PregnancyWeeklyStatsPageState();
}

class _PregnancyWeeklyStatsPageState extends ConsumerState<PregnancyWeeklyStatsPage> {
  DateTime _weekStart = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
  List<Map<String, dynamic>> _symptomLogs = [];

  @override
  void initState() {
    super.initState();
    _loadSymptomLogs();
  }

  Future<void> _loadSymptomLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedData = prefs.getString('symptom_logs');
    if (savedData != null) {
      final List<dynamic> decoded = jsonDecode(savedData);
      setState(() {
        _symptomLogs = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      });
    }
  }

  void _changeWeek(int weeks) {
    setState(() {
      _weekStart = _weekStart.add(Duration(days: 7 * weeks));
    });
  }

  List<double> _getKickData(dynamic repo, DateTime start) {
    List<double> data = [];
    final kickLogs = repo.getHistory() as List<KickLogModel>;
    
    for (int i = 0; i < 7; i++) {
      final date = start.add(Duration(days: i));
      final dayKicks = kickLogs.where((k) =>
        k.sessionStart.year == date.year &&
        k.sessionStart.month == date.month &&
        k.sessionStart.day == date.day
      ).toList();
      final total = dayKicks.fold(0, (sum, k) => sum + k.kickCount);
      data.add(total.toDouble());
    }
    return data;
  }

  List<double> _getContractionData(dynamic repo, DateTime start) {
    List<double> data = [];
    final contractions = repo.getContractions() as List<ContractionModel>;
    
    for (int i = 0; i < 7; i++) {
      final date = start.add(Duration(days: i));
      final dayContractions = contractions.where((c) =>
        c.startTime.year == date.year &&
        c.startTime.month == date.month &&
        c.startTime.day == date.day
      ).length;
      data.add(dayContractions.toDouble());
    }
    return data;
  }

  List<double> _getSymptomData(DateTime start) {
    List<double> data = [];
    
    for (int i = 0; i < 7; i++) {
      final date = start.add(Duration(days: i));
      final daySymptoms = _symptomLogs.where((s) {
        final logDate = DateTime.parse(s['timestamp']);
        return logDate.year == date.year &&
               logDate.month == date.month &&
               logDate.day == date.day;
      }).length;
      data.add(daySymptoms.toDouble());
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    final kickLogRepo = ref.watch(kickLogRepositoryProvider);
    final contractionRepo = ref.watch(contractionRepositoryProvider);

    final weekEnd = _weekStart.add(const Duration(days: 6));
    final dateRangeText = '${DateFormat('MMM d').format(_weekStart)} - ${DateFormat('MMM d, y').format(weekEnd)}';
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Insights'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Week Navigator
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, size: 18),
                    onPressed: () => _changeWeek(-1),
                    color: theme.colorScheme.primary,
                  ),
                  Text(
                    dateRangeText,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, size: 18),
                    onPressed: weekEnd.isAfter(DateTime.now().subtract(const Duration(days: 1))) 
                        ? null 
                        : () => _changeWeek(1),
                    color: weekEnd.isAfter(DateTime.now().subtract(const Duration(days: 1))) 
                        ? theme.disabledColor
                        : theme.colorScheme.primary,
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    kickLogRepo.when(
                      data: (repo) => _buildChartCard(
                        'Baby Kicks',
                        Icons.child_care,
                        theme.colorScheme.primary,
                        _getKickData(repo, _weekStart),
                        theme,
                      ),
                      loading: () => const _LoadingChart(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 16),
                    contractionRepo.when(
                      data: (repo) => _buildChartCard(
                        'Contractions',
                        Icons.timer,
                        theme.colorScheme.tertiary,
                        _getContractionData(repo, _weekStart),
                        theme,
                      ),
                      loading: () => const _LoadingChart(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 16),
                    _buildChartCard(
                      'Symptoms Logged',
                      Icons.healing,
                      theme.colorScheme.secondary,
                      _getSymptomData(_weekStart),
                      theme,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(String title, IconData icon, Color color, List<double> weeklyData, ThemeData theme) {
    final maxY = weeklyData.isEmpty ? 10.0 : weeklyData.reduce((curr, next) => curr > next ? curr : next);
    // Add some buffer to top of chart
    final targetY = maxY == 0 ? 10.0 : maxY * 1.2;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.secondary.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: targetY,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: theme.colorScheme.surfaceVariant,
                    tooltipPadding: const EdgeInsets.all(8),
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        rod.toY.toStringAsFixed(0),
                        TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        if (value.toInt() >= 0 && value.toInt() < days.length) {
                           return Padding(
                             padding: const EdgeInsets.only(top: 8.0),
                             child: Text(
                               days[value.toInt()],
                               style: theme.textTheme.labelSmall?.copyWith(
                                 color: theme.colorScheme.onSurface.withOpacity(0.7),
                                 fontWeight: FontWeight.bold,
                               ),
                             ),
                           );
                        }
                        return const SizedBox.shrink();
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                         if (value == 0) return const SizedBox.shrink();
                         return Text(
                           value.toInt().toString(),
                           style: theme.textTheme.labelSmall?.copyWith(
                             color: theme.colorScheme.onSurface.withOpacity(0.6),
                           ),
                         );
                      },
                      reservedSize: 30,
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: targetY / 5,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: theme.dividerColor.withOpacity(0.1),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: weeklyData.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value,
                        color: color.withOpacity(0.8),
                        width: 14,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: targetY,
                          color: color.withOpacity(0.1),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingChart extends StatelessWidget {
  const _LoadingChart();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        height: 250,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      ),
    );
  }
}
