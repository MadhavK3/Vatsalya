import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:maternal_infant_care/core/constants/app_constants.dart';
import 'package:maternal_infant_care/data/models/pregnancy_model.dart';
import 'package:maternal_infant_care/presentation/viewmodels/repository_providers.dart';
import 'package:maternal_infant_care/presentation/widgets/pregnancy_timeline_widget.dart';
import 'package:maternal_infant_care/presentation/widgets/pregnancy_checklist_widget.dart';

class PregnancyTrackingPage extends ConsumerStatefulWidget {
  const PregnancyTrackingPage({super.key});

  @override
  ConsumerState<PregnancyTrackingPage> createState() => _PregnancyTrackingPageState();
}

class _PregnancyTrackingPageState extends ConsumerState<PregnancyTrackingPage>
    with SingleTickerProviderStateMixin {
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
    final pregnancyRepo = ref.watch(pregnancyRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pregnancy Tracking'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Timeline'),
            Tab(text: 'Checklist'),
          ],
        ),
      ),
      body: pregnancyRepo.when(
        data: (repo) {
          final pregnancy = repo.getPregnancy();
          if (pregnancy == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.pregnant_woman,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No pregnancy data found',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _OverviewTab(pregnancy: pregnancy),
              PregnancyTimelineWidget(pregnancy: pregnancy),
              PregnancyChecklistWidget(pregnancy: pregnancy),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: ${error.toString()}'),
        ),
      ),
    );
  }
}

class _OverviewTab extends StatefulWidget {
  final PregnancyModel pregnancy;

  const _OverviewTab({required this.pregnancy});

  @override
  State<_OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<_OverviewTab> {
  late int _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedMonth = widget.pregnancy.currentMonth;
  }

  @override
  Widget build(BuildContext context) {
    final weeksPregnant = widget.pregnancy.weeksPregnant;
    final daysUntilDue = widget.pregnancy.daysUntilDue;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Evolution Visualization Area
          Stack(
            children: [
              Container(
                height: 350,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.black,
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: Image.asset(
                    'assets/images/fetus_m$_selectedMonth.png',
                    key: ValueKey(_selectedMonth),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.image_not_supported, color: Colors.white, size: 48),
                            const SizedBox(height: 8),
                            Text(
                              'Month $_selectedMonth Visualization Missing',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Gradient Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.4),
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                    ),
                  ),
                ),
              ),
              // Month Scroller
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: SizedBox(
                  height: 70,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: 9,
                    itemBuilder: (context, index) {
                      final month = index + 1;
                      final isSelected = month == _selectedMonth;
                      final isToday = month == widget.pregnancy.currentMonth;

                      return GestureDetector(
                        onTap: () => setState(() => _selectedMonth = month),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 12),
                          width: 60,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: isToday
                                ? Border.all(color: Colors.white, width: 2)
                                : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'M$month',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 14,
                                ),
                              ),
                              if (isToday)
                                const Text(
                                  'NOW',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          
          // Stats & Information Panel
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Development: Month $_selectedMonth',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          _selectedMonth == widget.pregnancy.currentMonth 
                            ? 'Your current milestone' 
                            : 'Future growth stage',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                         Column(
                          children: [
                            Text(
                              '$weeksPregnant',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                            ),
                            Text(
                              'Weeks',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        Container(height: 40, width: 1, color: Colors.grey.withOpacity(0.3)),
                        _StatItem(
                          label: 'Due Date',
                          value: DateFormat('MMM dd').format(widget.pregnancy.dueDate),
                          icon: Icons.calendar_today,
                        ),
                        Container(height: 40, width: 1, color: Colors.grey.withOpacity(0.3)),
                        _StatItem(
                          label: 'Days Left',
                          value: '$daysUntilDue',
                          icon: Icons.timer,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _MonthInfoCard(month: _selectedMonth),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
        ),
      ],
    );
  }
}

class _MonthInfoCard extends StatelessWidget {
  final int month;

  const _MonthInfoCard({required this.month});

  @override
  Widget build(BuildContext context) {
    final info = _getMonthInfo(month);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Month $month Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...info['highlights']!.map((highlight) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          highlight,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Map<String, List<String>> _getMonthInfo(int month) {
    final info = <int, Map<String, List<String>>>{
      1: {
        'highlights': [
          'Baby is the size of a poppy seed',
          'Your body begins producing pregnancy hormones',
          'Take folic acid supplements daily',
          'Avoid alcohol, smoking, and harmful substances',
        ],
      },
      2: {
        'highlights': [
          'Baby is the size of a blueberry',
          'Organs and systems begin to form',
          'Continue folic acid and prenatal vitamins',
          'Schedule your first prenatal appointment',
        ],
      },
      3: {
        'highlights': [
          'Baby is the size of a grape',
          'Heart begins beating',
          'You may experience morning sickness',
          'Continue prenatal vitamins',
        ],
      },
      4: {
        'highlights': [
          'Baby is the size of an avocado',
          'Organs are fully formed',
          'You may start showing',
          'Eat a balanced diet with iron-rich foods',
        ],
      },
      5: {
        'highlights': [
          'Baby is the size of a banana',
          'Baby begins moving',
          'Increase protein intake',
          'Stay hydrated',
        ],
      },
      6: {
        'highlights': [
          'Baby is the size of an ear of corn',
          'Baby can hear sounds',
          'Continue regular check-ups',
          'Eat small, frequent meals',
        ],
      },
      7: {
        'highlights': [
          'Baby is the size of a coconut',
          'Baby\'s eyes can open',
          'Watch for signs of preterm labor',
          'Maintain good posture',
        ],
      },
      8: {
        'highlights': [
          'Baby is the size of a butternut squash',
          'Baby is gaining weight rapidly',
          'Prepare for delivery',
          'Practice breathing exercises',
        ],
      },
      9: {
        'highlights': [
          'Baby is the size of a watermelon',
          'Baby is ready for birth',
          'Watch for labor signs',
          'Pack your hospital bag',
        ],
      },
    };

    return info[month] ?? {'highlights': []};
  }
}
