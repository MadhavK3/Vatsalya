import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maternal_infant_care/data/models/pregnancy_model.dart';

class PregnancyTimelineWidget extends StatelessWidget {
  final PregnancyModel pregnancy;

  const PregnancyTimelineWidget({super.key, required this.pregnancy});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: 9,
      itemBuilder: (context, index) {
        final month = index + 1;
        final isCurrentMonth = month == pregnancy.currentMonth;
        final isCompleted = month < pregnancy.currentMonth;
        final isUpcoming = month > pregnancy.currentMonth;

        return _TimelineItem(
          month: month,
          isCompleted: isCompleted,
          isCurrent: isCurrentMonth,
          isUpcoming: isUpcoming,
          pregnancy: pregnancy,
        );
      },
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final int month;
  final bool isCompleted;
  final bool isCurrent;
  final bool isUpcoming;
  final PregnancyModel pregnancy;

  const _TimelineItem({
    required this.month,
    required this.isCompleted,
    required this.isCurrent,
    required this.isUpcoming,
    required this.pregnancy,
  });

  @override
  Widget build(BuildContext context) {
    final color = isCompleted
        ? Colors.green
        : isCurrent
            ? Theme.of(context).colorScheme.primary
            : Colors.grey;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : Text(
                        '$month',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            if (month < 9)
              Container(
                width: 2,
                height: 60,
                color: isCompleted ? Colors.green : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Card(
            color: isCurrent ? Theme.of(context).colorScheme.primaryContainer : null,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Month $month',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isCurrent ? Theme.of(context).colorScheme.onPrimaryContainer : null,
                        ),
                  ),
                  if (isCurrent) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Current Month',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
