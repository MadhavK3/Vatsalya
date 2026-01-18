import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:maternal_infant_care/presentation/viewmodels/repository_providers.dart';
import 'package:maternal_infant_care/data/models/feeding_model.dart';
import 'package:maternal_infant_care/data/models/sleep_model.dart';
import 'package:maternal_infant_care/data/models/diaper_model.dart';

class DailySummaryPage extends ConsumerStatefulWidget {
  const DailySummaryPage({super.key});

  @override
  ConsumerState<DailySummaryPage> createState() => _DailySummaryPageState();
}

class _DailySummaryPageState extends ConsumerState<DailySummaryPage> {
  DateTime _selectedDate = DateTime.now();

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade300,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedingRepo = ref.watch(feedingRepositoryProvider);
    final sleepRepo = ref.watch(sleepRepositoryProvider);
    final diaperRepo = ref.watch(diaperRepositoryProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Daily Summary'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF455A64),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _pickDate(context),
          ),
        ],
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
                  Color(0xFFE3F2FD), // Light Blue
                  Color(0xFFF3E5F5), // Light Purple
                ],
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                _buildDateNavigator(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSummaryCards(feedingRepo, sleepRepo, diaperRepo),
                        const SizedBox(height: 24),
                        Text(
                          'Timeline',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey[800],
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildTimeline(feedingRepo, sleepRepo, diaperRepo),
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

  Widget _buildDateNavigator() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            onPressed: () => _changeDate(-1),
            color: Colors.blueGrey,
          ),
          Text(
            DateFormat('EEEE, MMM d, y').format(_selectedDate),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey[800],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 18),
            onPressed: _selectedDate.day == DateTime.now().day &&
                    _selectedDate.month == DateTime.now().month &&
                    _selectedDate.year == DateTime.now().year
                ? null
                : () => _changeDate(1),
            color: _selectedDate.day == DateTime.now().day ? Colors.grey.withOpacity(0.3) : Colors.blueGrey,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(
    AsyncValue<dynamic> feedingRepo,
    AsyncValue<dynamic> sleepRepo,
    AsyncValue<dynamic> diaperRepo,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: feedingRepo.when(
                data: (repo) {
                  final feedings = repo.getFeedingsByDate(_selectedDate);
                  final totalMl = feedings.fold(0.0, (sum, f) => sum + f.quantity);
                  return _StatCard(
                    title: 'Feeding',
                    value: '${feedings.length}',
                    subtitle: '${totalMl.toStringAsFixed(0)} ml',
                    icon: Icons.restaurant,
                    color: Colors.orange,
                  );
                },
                loading: () => const _LoadingCard(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: sleepRepo.when(
                data: (repo) {
                  final hours = repo.getTotalSleepHoursByDate(_selectedDate);
                  return _StatCard(
                    title: 'Sleep',
                    value: '${hours.toStringAsFixed(1)} h',
                    subtitle: 'Total sleep',
                    icon: Icons.bedtime,
                    color: Colors.indigo,
                  );
                },
                loading: () => const _LoadingCard(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: diaperRepo.when(
                data: (repo) {
                  final changes = repo.getDiapersByDate(_selectedDate);
                  return _StatCard(
                    title: 'Diaper',
                    value: '${changes.length}',
                    subtitle: 'Changes',
                    icon: Icons.layers,
                    color: Colors.teal,
                  );
                },
                loading: () => const _LoadingCard(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),
            const SizedBox(width: 12),
            // Placeholder for future metric or filler
            const Expanded(child: SizedBox.shrink()), 
          ],
        ),
      ],
    );
  }

  Widget _buildTimeline(
    AsyncValue<dynamic> feedingRepo,
    AsyncValue<dynamic> sleepRepo,
    AsyncValue<dynamic> diaperRepo,
  ) {
    List<_TimelineEvent> events = [];

    // Combine data
    if (feedingRepo.hasValue) {
      final feedings = feedingRepo.value!.getFeedingsByDate(_selectedDate) as List<FeedingModel>;
      events.addAll(feedings.map((f) => _TimelineEvent(
            time: f.timestamp,
            title: 'Feeding',
            description: '${f.quantity}ml ${f.type}',
            icon: Icons.restaurant,
            color: Colors.orange,
          )));
    }

    if (sleepRepo.hasValue) {
      final sleep = sleepRepo.value!.getSleepsByDate(_selectedDate) as List<SleepModel>;
      events.addAll(sleep.map((s) => _TimelineEvent(
            time: s.startTime,
            title: 'Sleep Started',
            description: 'Nap',
            icon: Icons.bedtime,
            color: Colors.indigo,
          )));
      events.addAll(sleep.where((s) => s.endTime != null).map((s) => _TimelineEvent(
            time: s.endTime!,
            title: 'Woke Up',
            description: 'Duration: ${s.hours.toStringAsFixed(1)}h',
            icon: Icons.sunny,
            color: Colors.amber,
          )));
    }

    if (diaperRepo.hasValue) {
      final diapers = diaperRepo.value!.getDiapersByDate(_selectedDate) as List<DiaperModel>;
      events.addAll(diapers.map((d) => _TimelineEvent(
            time: d.timestamp,
            title: 'Diaper Change',
            description: 'Status: ${d.status}',
            icon: Icons.layers,
            color: Colors.teal,
          )));
    }

    // Sort by time descending (newest first)
    events.sort((a, b) => b.time.compareTo(a.time));

    if (events.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(Icons.history, size: 48, color: Colors.blueGrey.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              'No activities logged for this day',
              style: TextStyle(color: Colors.blueGrey.withOpacity(0.6)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: event.color.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: event.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(event.icon, color: event.color, size: 20),
            ),
            title: Text(
              event.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            subtitle: Text(event.description),
            trailing: Text(
              DateFormat('h:mm a').format(event.time),
              style: TextStyle(
                color: Colors.blueGrey[400],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
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
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: Colors.blueGrey[600],
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey[900],
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.blueGrey[400],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}

class _TimelineEvent {
  final DateTime time;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  _TimelineEvent({
    required this.time,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
