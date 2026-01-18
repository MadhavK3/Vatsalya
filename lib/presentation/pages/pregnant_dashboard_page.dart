import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maternal_infant_care/data/models/dashboard_card_model.dart';
import 'package:maternal_infant_care/presentation/widgets/customizable_dashboard.dart';
import 'package:maternal_infant_care/presentation/widgets/kick_counter_widget.dart';
import 'package:maternal_infant_care/presentation/widgets/contraction_timer_widget.dart';
import 'package:maternal_infant_care/presentation/pages/hospital_bag_page.dart';
import 'package:maternal_infant_care/presentation/pages/symptom_tracker_page.dart';
import 'package:maternal_infant_care/presentation/pages/daily_tips_page.dart';
import 'package:maternal_infant_care/presentation/viewmodels/user_meta_provider.dart';
import 'package:maternal_infant_care/presentation/widgets/start_journey_widget.dart';

import 'package:maternal_infant_care/presentation/pages/daily_summary_page.dart';
import 'package:maternal_infant_care/presentation/pages/weekly_stats_page.dart';

// Reuse existing widgets where possible or create simple ones
class PregnantDashboardPage extends ConsumerWidget {
  const PregnantDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomizableDashboard(
      header: _buildHeader(context, ref),
      cardBuilder: (context, card) {
        return _buildCardContent(context, card);
      },
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final userMeta = ref.watch(userMetaProvider);
    final username = userMeta.username;
    final displayName = (username != null && username.isNotEmpty) ? username : 'Mama';

    return Padding(
      padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 24.0, bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hi, $displayName',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
               Icon(Icons.favorite, color: Colors.pink[300], size: 28),
               const SizedBox(width: 8),
              Text(
                'Pregnancy Journey',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.pink[400],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Track every precious moment.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          const StartJourneyWidget(),
        ],
      ),
    );
  }

  Widget _buildCardContent(BuildContext context, DashboardCardModel card) {
    switch (card.widgetType) {
      case 'pregnancy_progress':
        return const SizedBox.shrink(); // Hidden as per user request
      case 'daily_summary':
        return _buildActionCard(context, 'Daily Summary', 'View today\'s logs', Icons.assignment, Colors.blueGrey, () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const DailySummaryPage()));
        });
      case 'weekly_stats':
        return _buildActionCard(context, 'Weekly Insights', 'View charts & trends', Icons.bar_chart, Colors.deepPurpleAccent, () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const WeeklyStatsPage()));
        });
      case 'kick_counter':
        return const KickCounterWidget();
      case 'contraction_timer':
        return const ContractionTimerWidget();
      case 'hospital_bag':
        return _buildActionCard(context, 'Hospital Bag', 'Checklist for delivery day', Icons.luggage, Colors.blue, () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const HospitalBagPage()));
        });
      case 'symptom_tracker':
        return _buildActionCard(context, 'Symptom Tracker', 'Log "morning" sickness & more', Icons.healing, Colors.green, () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const SymptomTrackerPage()));
        });
       case 'daily_tips':
        return _buildActionCard(context, 'Daily Tips', 'Eat well, sleep well.', Icons.lightbulb, Colors.orange, () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const DailyTipsPage()));
        });
      default:
        // Fallback
        return _buildActionCard(context, card.title, 'Widget not implemented', Icons.widgets, Colors.grey, () {});
    }
  }

  Widget _buildProgressCard(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final userMeta = ref.watch(userMetaProvider);
        final startDate = userMeta.startDate;
        int week = 1;
        if (startDate != null) {
          week = (DateTime.now().difference(startDate).inDays / 7).floor() + 1;
        }
        week = week.clamp(1, 40);
        double progress = (week / 40);

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pink[300]!, Colors.purple[300]!],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: Colors.pink.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
            ],
          ),
          child: Column(
            children: [
              Text('Week $week', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
              const Text('Baby is growing every day! 🌟', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 20),
              LinearProgressIndicator(value: progress, backgroundColor: Colors.white24, color: Colors.white),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionCard(BuildContext context, String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
