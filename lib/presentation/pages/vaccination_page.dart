import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:maternal_infant_care/data/models/vaccination_model.dart';
import 'package:maternal_infant_care/presentation/viewmodels/repository_providers.dart';
import 'package:maternal_infant_care/core/utils/vaccination_schedule.dart';
import 'package:maternal_infant_care/core/utils/reminder_service.dart';

class VaccinationPage extends ConsumerStatefulWidget {
  const VaccinationPage({super.key});

  @override
  ConsumerState<VaccinationPage> createState() => _VaccinationPageState();
}

class _VaccinationPageState extends ConsumerState<VaccinationPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vaccinationRepo = ref.watch(vaccinationRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vaccinations'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Completed'),
            Tab(text: 'Schedule'),
          ],
        ),
      ),
      body: vaccinationRepo.when(
        data: (repo) {
          final upcoming = repo.getUpcomingVaccinations();
          final completed = repo.getCompletedVaccinations();

          return TabBarView(
            controller: _tabController,
            children: [
              _UpcomingTab(vaccinations: upcoming, repo: repo),
              _CompletedTab(vaccinations: completed),
              _ScheduleTab(repo: repo),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: ${error.toString()}')),
      ),
    );
  }
}

class _UpcomingTab extends StatelessWidget {
  final List<VaccinationModel> vaccinations;
  final dynamic repo;

  const _UpcomingTab({required this.vaccinations, required this.repo});

  @override
  Widget build(BuildContext context) {
    if (vaccinations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No upcoming vaccinations',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: vaccinations.length,
      itemBuilder: (context, index) {
        final vaccination = vaccinations[index];
        return _VaccinationCard(vaccination: vaccination, repo: repo, isUpcoming: true);
      },
    );
  }
}

class _CompletedTab extends StatelessWidget {
  final List<VaccinationModel> vaccinations;

  const _CompletedTab({required this.vaccinations});

  @override
  Widget build(BuildContext context) {
    if (vaccinations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.vaccines_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No completed vaccinations',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: vaccinations.length,
      itemBuilder: (context, index) {
        final vaccination = vaccinations[index];
        return _VaccinationCard(vaccination: vaccination, repo: null, isUpcoming: false);
      },
    );
  }
}

class _ScheduleTab extends ConsumerWidget {
  final dynamic repo;

  const _ScheduleTab({required this.repo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedule = VaccinationSchedule.getIndianSchedule();

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: schedule.length,
      itemBuilder: (context, index) {
        final item = schedule[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.vaccines,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            title: Text(item['name'] as String),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Age: ${item['age']}'),
                if (item['description'] != null)
                  Text(item['description'] as String),
              ],
            ),
            trailing: ElevatedButton(
              onPressed: () async {
                try {
                  final ageInDays = _parseAgeToDays(item['age'] as String);
                  final scheduledDate = DateTime.now().add(Duration(days: ageInDays));
                  
                  final vaccination = VaccinationModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: item['name'] as String,
                    scheduledDate: scheduledDate,
                    ageInDays: ageInDays,
                  );
                  await repo.saveVaccination(vaccination);
                  await ReminderService.scheduleVaccinationReminder(vaccination);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vaccination scheduled')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  }
                }
              },
              child: const Text('Schedule'),
            ),
          ),
        );
      },
    );
  }

  int _parseAgeToDays(String age) {
    if (age.contains('At birth')) return 0;
    if (age.contains('weeks')) {
      final weeks = int.tryParse(age.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      return weeks * 7;
    }
    if (age.contains('months')) {
      final months = int.tryParse(age.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      return months * 30;
    }
    if (age.contains('year')) {
      final years = int.tryParse(age.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      return years * 365;
    }
    return 0;
  }
}

class _VaccinationCard extends StatelessWidget {
  final VaccinationModel vaccination;
  final dynamic repo;
  final bool isUpcoming;

  const _VaccinationCard({
    required this.vaccination,
    required this.repo,
    required this.isUpcoming,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isUpcoming && vaccination.daysUntilDue <= 7
          ? Theme.of(context).colorScheme.errorContainer
          : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: vaccination.isCompleted
              ? Colors.green.withOpacity(0.2)
              : Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            vaccination.isCompleted ? Icons.check_circle : Icons.vaccines,
            color: vaccination.isCompleted ? Colors.green : Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(vaccination.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!vaccination.isCompleted)
              Text('Due: ${DateFormat('MMM dd, yyyy').format(vaccination.scheduledDate)}'),
            if (vaccination.isCompleted && vaccination.administeredDate != null)
              Text('Administered: ${DateFormat('MMM dd, yyyy').format(vaccination.administeredDate!)}'),
            if (isUpcoming)
              Text(
                '${vaccination.daysUntilDue} days left',
                style: TextStyle(
                  color: vaccination.daysUntilDue <= 7
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (vaccination.batchNumber != null)
              Text('Batch: ${vaccination.batchNumber}'),
            if (vaccination.doctorName != null)
              Text('Doctor: ${vaccination.doctorName}'),
          ],
        ),
        trailing: isUpcoming
            ? IconButton(
                icon: const Icon(Icons.check_circle),
                onPressed: () async {
                  final updated = vaccination.copyWith(
                    isCompleted: true,
                    administeredDate: DateTime.now(),
                  );
                  await repo.saveVaccination(updated);
                },
              )
            : null,
      ),
    );
  }
}
