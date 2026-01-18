import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maternal_infant_care/data/models/dashboard_card_model.dart';
import 'package:maternal_infant_care/presentation/widgets/customizable_dashboard.dart';
import 'package:maternal_infant_care/presentation/widgets/milestone_tracker_widget.dart';

// Import existing pages for navigation
import 'package:maternal_infant_care/presentation/pages/feeding_tracking_page.dart';
import 'package:maternal_infant_care/presentation/pages/sleep_tracking_page.dart';
import 'package:maternal_infant_care/presentation/pages/diaper_tracking_page.dart';
import 'package:maternal_infant_care/presentation/pages/vaccination_page.dart';
import 'package:maternal_infant_care/presentation/pages/growth_tracking_page.dart';
import 'package:maternal_infant_care/presentation/pages/activity_ideas_page.dart';
import 'package:maternal_infant_care/presentation/pages/daily_summary_page.dart';
import 'package:maternal_infant_care/presentation/pages/weekly_stats_page.dart';
import 'package:maternal_infant_care/presentation/viewmodels/user_meta_provider.dart';

class ToddlerDashboardPage extends ConsumerWidget {
  const ToddlerDashboardPage({super.key});

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
    final displayName = (username != null && username.isNotEmpty) ? username : 'Parent';

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
               Icon(Icons.child_care, color: Colors.orange[400], size: 28),
               const SizedBox(width: 8),
              Text(
                'Parenting Hub',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Keep up with your little explorer.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardContent(BuildContext context, DashboardCardModel card) {
    switch (card.widgetType) {
      case 'tracker_hub':
        return _buildTrackerHub(context);
      case 'milestones':
        return const MilestoneTrackerWidget();
      case 'vaccinations':
        return _buildActionCard(context, 'Vaccinations', 'Upcoming shots', Icons.vaccines, Colors.red, () {
           Navigator.push(context, MaterialPageRoute(builder: (_) => const VaccinationPage()));
        });
      case 'growth_chart':
        return _buildActionCard(context, 'Growth Tracker', 'Height & Weight', Icons.show_chart, Colors.purple, () {
           Navigator.push(context, MaterialPageRoute(builder: (_) => const GrowthTrackingPage()));
        });
      case 'daily_summary':
        return _buildActionCard(context, 'Daily Summary', 'View today\'s logs', Icons.assignment, Colors.blueGrey, () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const DailySummaryPage()));
        });
      case 'weekly_stats':
        return _buildActionCard(context, 'Weekly Insights', 'View charts & trends', Icons.bar_chart, Colors.deepPurpleAccent, () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const WeeklyStatsPage()));
        });
      case 'activity_suggestions':
        return _buildActionCard(context, 'Activity Ideas', 'Age-appropriate play', Icons.toys, Colors.green, () {
           Navigator.push(context, MaterialPageRoute(builder: (_) => const ActivityIdeasPage()));
        });
      case 'daily_tips':
        return _buildActionCard(context, 'Parenting Tip', 'Toddlers love routine.', Icons.lightbulb, Colors.amber, null);
      default:
        return _buildActionCard(context, card.title, '', Icons.widgets, Colors.grey, null);
    }
  }

  Widget _buildTrackerHub(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMiniTracker(context, 'Feeding', Icons.restaurant, Colors.orange, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const FeedingTrackingPage()));
              }),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMiniTracker(context, 'Sleep', Icons.bedtime, Colors.indigo, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SleepTrackingPage()));
              }),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMiniTracker(context, 'Diaper', Icons.layers, Colors.teal, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const DiaperTrackingPage()));
              }),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMiniTracker(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, String subtitle, IconData icon, Color color, VoidCallback? onTap) {
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
        subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
