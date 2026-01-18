import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:maternal_infant_care/presentation/viewmodels/repository_providers.dart';

class WeeklyStatsPage extends ConsumerStatefulWidget {
  const WeeklyStatsPage({super.key});

  @override
  ConsumerState<WeeklyStatsPage> createState() => _WeeklyStatsPageState();
}

class _WeeklyStatsPageState extends ConsumerState<WeeklyStatsPage> {
  DateTime _weekStart = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));

  void _changeWeek(int weeks) {
    setState(() {
      _weekStart = _weekStart.add(Duration(days: 7 * weeks));
    });
  }

  @override
  Widget build(BuildContext context) {
    final feedingRepo = ref.watch(feedingRepositoryProvider);
    final sleepRepo = ref.watch(sleepRepositoryProvider);
    final diaperRepo = ref.watch(diaperRepositoryProvider);

    final weekEnd = _weekStart.add(const Duration(days: 6));
    final dateRangeText = '${DateFormat('MMM d').format(_weekStart)} - ${DateFormat('MMM d, y').format(weekEnd)}';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Weekly Insights'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF455A64),
      ),
      body: Stack(
        children: [
          // Glassy Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFE8F5E9), // Light Green
                  Color(0xFFE3F2FD), // Light Blue
                ],
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Week Navigator
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withOpacity(0.8)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, size: 18),
                        onPressed: () => _changeWeek(-1),
                        color: Colors.blueGrey,
                      ),
                      Text(
                        dateRangeText,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey[800],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios, size: 18),
                        onPressed: weekEnd.isAfter(DateTime.now().subtract(const Duration(days: 1))) 
                            ? null 
                            : () => _changeWeek(1),
                        color: weekEnd.isAfter(DateTime.now().subtract(const Duration(days: 1))) 
                            ? Colors.grey.withOpacity(0.3) 
                            : Colors.blueGrey,
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        feedingRepo.when(
                          data: (repo) => _buildChartCard(
                            'Feeding (ml)',
                            Colors.orange,
                            _getFeedingData(repo, _weekStart),
                          ),
                          loading: () => const _LoadingChart(),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                        const SizedBox(height: 16),
                        sleepRepo.when(
                          data: (repo) => _buildChartCard(
                            'Sleep (hours)',
                            Colors.indigo,
                            _getSleepData(repo, _weekStart),
                          ),
                          loading: () => const _LoadingChart(),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                        const SizedBox(height: 16),
                        diaperRepo.when(
                          data: (repo) => _buildChartCard(
                            'Diapers',
                            Colors.teal,
                            _getDiaperData(repo, _weekStart),
                          ),
                          loading: () => const _LoadingChart(),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<double> _getFeedingData(dynamic repo, DateTime start) {
    List<double> data = [];
    for (int i = 0; i < 7; i++) {
      final date = start.add(Duration(days: i));
      final feedings = repo.getFeedingsByDate(date);
      final total = feedings.fold(0.0, (sum, item) => sum + (item.quantity as double));
      data.add(total);
    }
    return data;
  }

  List<double> _getSleepData(dynamic repo, DateTime start) {
    List<double> data = [];
    for (int i = 0; i < 7; i++) {
        final date = start.add(Duration(days: i));
        data.add(repo.getTotalSleepHoursByDate(date));
    }
    return data;
  }

  List<double> _getDiaperData(dynamic repo, DateTime start) {
    List<double> data = [];
    for (int i = 0; i < 7; i++) {
        final date = start.add(Duration(days: i));
        data.add(repo.getDiapersByDate(date).length.toDouble());
    }
    return data;
  }

  Widget _buildChartCard(String title, Color color, List<double> weeklyData) {
    final maxY = weeklyData.reduce((curr, next) => curr > next ? curr : next);
    // Add some buffer to top of chart
    final targetY = maxY == 0 ? 10.0 : maxY * 1.2;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.9)),
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
                child: Icon(Icons.bar_chart, color: color, size: 18),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[800],
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
                    tooltipBgColor: Colors.blueGrey,
                    tooltipPadding: const EdgeInsets.all(8),
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        rod.toY.toStringAsFixed(1),
                        const TextStyle(
                          color: Colors.white,
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
                               style: TextStyle(
                                 color: Colors.blueGrey[400],
                                 fontSize: 10,
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
                           style: TextStyle(
                             color: Colors.blueGrey[300], 
                             fontSize: 10,
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
                    color: Colors.blueGrey.withOpacity(0.1),
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
                        color: color.withOpacity(0.7),
                        width: 14,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: targetY,
                          color: color.withOpacity(0.05),
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
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
