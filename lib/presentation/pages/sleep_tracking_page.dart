import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:maternal_infant_care/data/models/sleep_model.dart';
import 'package:maternal_infant_care/presentation/viewmodels/repository_providers.dart';

class SleepTrackingPage extends ConsumerStatefulWidget {
  const SleepTrackingPage({super.key});

  @override
  ConsumerState<SleepTrackingPage> createState() => _SleepTrackingPageState();
}

class _SleepTrackingPageState extends ConsumerState<SleepTrackingPage> {
  @override
  Widget build(BuildContext context) {
    final sleepRepo = ref.watch(sleepRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sleep Tracker'),
      ),
      body: sleepRepo.when(
        data: (repo) {
          final today = DateTime.now();
          final todaySleeps = repo.getSleepsByDate(today);
          final totalHours = repo.getTotalSleepHoursByDate(today);
          final allSleeps = repo.getAllSleeps();
          final activeSleep = repo.getCurrentActiveSleep();

          return Column(
            children: [
              _TodaySummaryCard(
                totalHours: totalHours,
                sessionCount: todaySleeps.length,
              ),
              if (activeSleep != null) _ActiveSleepCard(sleep: activeSleep, repo: repo),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: allSleeps.length,
                  itemBuilder: (context, index) {
                    final sleep = allSleeps[index];
                    return _SleepItemCard(sleep: sleep, repo: repo);
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: ${error.toString()}')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _toggleSleep(context),
        icon: const Icon(Icons.bedtime),
        label: const Text('Start Sleep'),
      ),
    );
  }

  Future<void> _toggleSleep(BuildContext context) async {
    try {
      final repo = await ref.read(sleepRepositoryProvider.future);
      final activeSleep = repo.getCurrentActiveSleep();

      if (activeSleep != null) {
        final updated = activeSleep.copyWith(
          endTime: DateTime.now(),
          isActive: false,
        );
        await repo.saveSleep(updated);
      } else {
        final sleep = SleepModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          startTime: DateTime.now(),
          isActive: true,
        );
        await repo.saveSleep(sleep);
      }

      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }
}

class _TodaySummaryCard extends StatelessWidget {
  final double totalHours;
  final int sessionCount;

  const _TodaySummaryCard({
    required this.totalHours,
    required this.sessionCount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: Theme.of(context).cardTheme.shape,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.tertiary,
              Theme.of(context).colorScheme.primary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatColumn(
              label: 'Total Sleep',
              value: '${totalHours.toStringAsFixed(1)}h',
              color: Theme.of(context).colorScheme.onTertiary,
            ),
            Container(width: 1, height: 40, color: Theme.of(context).colorScheme.onTertiary.withOpacity(0.3)),
            _StatColumn(
              label: 'Sessions',
              value: '$sessionCount',
              color: Theme.of(context).colorScheme.onTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatColumn({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color.withOpacity(0.9),
              ),
        ),
      ],
    );
  }
}

class _ActiveSleepCard extends ConsumerWidget {
  final SleepModel sleep;
  final dynamic repo;

  const _ActiveSleepCard({required this.sleep, required this.repo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final duration = DateTime.now().difference(sleep.startTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.bedtime,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sleep in Progress',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Duration: ${hours}h ${minutes}m',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.stop_circle, color: Theme.of(context).colorScheme.error),
            onPressed: () async {
              final updated = sleep.copyWith(
                endTime: DateTime.now(),
                isActive: false,
              );
              await repo.saveSleep(updated);
            },
          ),
        ],
      ),
    );
  }
}

class _SleepItemCard extends StatelessWidget {
  final SleepModel sleep;
  final dynamic repo;

  const _SleepItemCard({required this.sleep, required this.repo});

  @override
  Widget build(BuildContext context) {
    final hours = sleep.hours;
    final durationText = hours >= 1
        ? '${hours.toStringAsFixed(1)}h'
        : '${(hours * 60).toInt()}m';
        
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: theme.cardTheme.shape,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.tertiary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.bedtime, color: theme.colorScheme.tertiary, size: 28),
        ),
        title: Text(
          durationText,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Started at ${DateFormat('hh:mm a').format(sleep.startTime)}',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)),
            ),
            if (sleep.endTime != null)
              Text(
                'Ended at ${DateFormat('hh:mm a').format(sleep.endTime!)}',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)),
              ),
            if (sleep.notes != null) ...[
              const SizedBox(height: 4),
              Text(
                sleep.notes!,
                style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete_outline, color: theme.colorScheme.error.withOpacity(0.6)),
          onPressed: () async {
            try {
              await repo.deleteSleep(sleep.id);
            } catch (e) {}
          },
        ),
      ),
    );
  }
}
