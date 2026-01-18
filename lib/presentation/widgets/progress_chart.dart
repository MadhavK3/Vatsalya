import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ProgressChart extends StatelessWidget {
  final List<FlSpot> spots;
  final String title;
  final String yAxisLabel;

  const ProgressChart({
    super.key,
    required this.spots,
    required this.title,
    required this.yAxisLabel,
  });

  @override
  Widget build(BuildContext context) {
    // If spots is empty, we still render the chart structure
    // if (spots.isEmpty) { ... } removed to show graph with no values

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              fontSize: 10,
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toStringAsFixed(1),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              fontSize: 10,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                    ),
                  ),
                  minX: 0,
                  maxX: spots.isNotEmpty ? spots.map((e) => e.x).reduce((a, b) => a > b ? a : b) : 1,
                  minY: 0,
                  maxY: spots.isNotEmpty ? spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) * 1.2 : 1,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      ),
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
}
