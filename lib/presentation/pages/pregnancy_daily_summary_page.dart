import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:maternal_infant_care/presentation/viewmodels/repository_providers.dart';
import 'package:maternal_infant_care/data/models/kick_log_model.dart';
import 'package:maternal_infant_care/data/models/contraction_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PregnancyDailySummaryPage extends ConsumerStatefulWidget {
  const PregnancyDailySummaryPage({super.key});

  @override
  ConsumerState<PregnancyDailySummaryPage> createState() => _PregnancyDailySummaryPageState();
}

class _PregnancyDailySummaryPageState extends ConsumerState<PregnancyDailySummaryPage> {
  DateTime _selectedDate = DateTime.now();
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

  List<Map<String, dynamic>> _getSymptomsByDate(DateTime date) {
    return _symptomLogs.where((log) {
      final logDate = DateTime.parse(log['timestamp']);
      return logDate.year == date.year &&
             logDate.month == date.month &&
             logDate.day == date.day;
    }).toList();
  }

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
              primary: Colors.pink.shade300,
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
    final kickLogRepo = ref.watch(kickLogRepositoryProvider);
    final contractionRepo = ref.watch(contractionRepositoryProvider);

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
          Container(
             color: Theme.of(context).scaffoldBackgroundColor,
          ),
          
          SafeArea(
            child: Column(
              children: [
                _buildDateNavigator(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSummaryCards(context, kickLogRepo, contractionRepo),
                        const SizedBox(height: 24),
                        Text(
                          'Timeline',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildTimeline(context, kickLogRepo, contractionRepo),
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

  Widget _buildDateNavigator(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Theme.of(context).colorScheme.secondary.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 18),
            onPressed: () => _changeDate(-1),
            color: Theme.of(context).colorScheme.primary,
          ),
          Text(
            DateFormat('EEEE, MMM d, y').format(_selectedDate),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 18),
            onPressed: _selectedDate.day == DateTime.now().day &&
                    _selectedDate.month == DateTime.now().month &&
                    _selectedDate.year == DateTime.now().year
                ? null
                : () => _changeDate(1),
            color: _selectedDate.day == DateTime.now().day 
              ? Theme.of(context).disabledColor 
              : Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(
    BuildContext context,
    AsyncValue<dynamic> kickLogRepo,
    AsyncValue<dynamic> contractionRepo,
  ) {
    final theme = Theme.of(context);
    final symptomsToday = _getSymptomsByDate(_selectedDate);
    
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: kickLogRepo.when(
                data: (repo) {
                  final kickLogs = (repo.getHistory() as List<KickLogModel>).where((k) =>
                    k.sessionStart.year == _selectedDate.year &&
                    k.sessionStart.month == _selectedDate.month &&
                    k.sessionStart.day == _selectedDate.day
                  ).toList();
                  final totalKicks = kickLogs.fold(0, (sum, k) => sum + k.kickCount);
                  return _StatCard(
                    title: 'Baby Kicks',
                    value: '$totalKicks',
                    subtitle: '${kickLogs.length} sessions',
                    icon: Icons.child_care,
                    color: theme.colorScheme.primary,
                  );
                },
                loading: () => const _LoadingCard(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: contractionRepo.when(
                data: (repo) {
                  final contractions = (repo.getContractions() as List<ContractionModel>).where((c) =>
                    c.startTime.year == _selectedDate.year &&
                    c.startTime.month == _selectedDate.month &&
                    c.startTime.day == _selectedDate.day
                  ).toList();
                  final avgDuration = contractions.isEmpty ? 0 : 
                    contractions.fold(0, (sum, c) => sum + c.durationSeconds) ~/ contractions.length;
                  return _StatCard(
                    title: 'Contractions',
                    value: '${contractions.length}',
                    subtitle: avgDuration > 0 ? 'Avg: ${avgDuration}s' : 'None recorded',
                    icon: Icons.timer,
                    color: theme.colorScheme.tertiary,
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
              child: _StatCard(
                title: 'Symptoms',
                value: '${symptomsToday.length}',
                subtitle: symptomsToday.isEmpty ? 'Feeling good!' : 'Logged today',
                icon: Icons.healing,
                color: theme.colorScheme.secondary,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(child: SizedBox.shrink()), 
          ],
        ),
      ],
    );
  }

  Widget _buildTimeline(
    BuildContext context,
    AsyncValue<dynamic> kickLogRepo,
    AsyncValue<dynamic> contractionRepo,
  ) {
    List<_TimelineEvent> events = [];
    final theme = Theme.of(context);

    // Add kick log events
    if (kickLogRepo.hasValue) {
      final kickLogs = (kickLogRepo.value!.getHistory() as List<KickLogModel>).where((k) =>
        k.sessionStart.year == _selectedDate.year &&
        k.sessionStart.month == _selectedDate.month &&
        k.sessionStart.day == _selectedDate.day
      ).toList();
      events.addAll(kickLogs.map((k) => _TimelineEvent(
            time: k.sessionStart,
            title: 'Kick Count Session',
            description: '${k.kickCount} kicks in ${_formatDuration(k.sessionEnd.difference(k.sessionStart))}',
            icon: Icons.child_care,
            color: theme.colorScheme.primary,
          )));
    }

    // Add contraction events
    if (contractionRepo.hasValue) {
      final contractions = (contractionRepo.value!.getContractions() as List<ContractionModel>).where((c) =>
        c.startTime.year == _selectedDate.year &&
        c.startTime.month == _selectedDate.month &&
        c.startTime.day == _selectedDate.day
      ).toList();
      events.addAll(contractions.map((c) => _TimelineEvent(
            time: c.startTime,
            title: 'Contraction',
            description: 'Duration: ${c.durationSeconds}s',
            icon: Icons.timer,
            color: theme.colorScheme.tertiary,
          )));
    }

    // Add symptom events
    final symptoms = _getSymptomsByDate(_selectedDate);
    events.addAll(symptoms.map((s) => _TimelineEvent(
          time: DateTime.parse(s['timestamp']),
          title: s['name'],
          description: 'Severity: ${s['severity']}/5',
          icon: Icons.healing,
          color: theme.colorScheme.secondary,
        )));

    // Sort by time descending (newest first)
    events.sort((a, b) => b.time.compareTo(a.time));

    if (events.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.colorScheme.secondary.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(Icons.spa_outlined, size: 48, color: theme.colorScheme.onSurface.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              'No activities logged for this day',
              style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
            ),
            const SizedBox(height: 8),
            Text(
              'Track your kicks, contractions, or symptoms!',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.4),
                fontSize: 12,
              ),
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
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: event.color.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: event.color.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
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
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 15
              ),
            ),
            subtitle: Text(event.description),
            trailing: Text(
              DateFormat('h:mm a').format(event.time),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
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
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
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
              Flexible(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                    fontWeight: FontWeight.bold
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
