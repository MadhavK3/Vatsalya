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
          Row(
            children: [
              Text(
                'Namaste, $displayName',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const Spacer(),
              Icon(Icons.family_restroom, color: Theme.of(context).colorScheme.secondary, size: 28),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Nurturing the future.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardContent(BuildContext context, DashboardCardModel card) {
    final theme = Theme.of(context);
    
    switch (card.widgetType) {
      case 'tracker_hub':
        return _buildTrackerHub(context);
      case 'milestones':
        return const MilestoneTrackerWidget();
      case 'vaccinations':
        return _buildActionCard(
          context, 
          'Vaccinations', 
          'Upcoming shots', 
          Icons.vaccines, 
          theme.colorScheme.tertiary, // Bronze vs Red
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VaccinationPage()))
        );
      case 'growth_chart':
        return _buildActionCard(
          context, 
          'Growth Tracker', 
          'Height & Weight', 
          Icons.show_chart, 
          theme.colorScheme.primary, 
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GrowthTrackingPage()))
        );
      case 'daily_summary':
        return _buildActionCard(
          context, 
          'Daily Summary', 
          'View today\'s logs', 
          Icons.auto_stories, 
          theme.colorScheme.primary, 
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DailySummaryPage()))
        );
      case 'weekly_stats':
        return _buildActionCard(
          context, 
          'Weekly Insights', 
          'View charts & trends', 
          Icons.insights, 
          theme.colorScheme.tertiary, 
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WeeklyStatsPage()))
        );
      case 'activity_suggestions':
        return _buildActionCard(
          context, 
          'Activity Ideas', 
          'Age-appropriate play', 
          Icons.toys_outlined, 
          theme.colorScheme.secondary, 
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ActivityIdeasPage()))
        );
      case 'daily_tips':
        return _buildActionCard(
          context, 
          'Parenting Wisdom', 
          'Ancient knowledge', 
          Icons.lightbulb_outline, 
          theme.colorScheme.secondary, 
          null
        );
      default:
        return _buildActionCard(context, card.title, '', Icons.widgets_outlined, theme.colorScheme.onSurface, null);
    }
  }

  Widget _buildTrackerHub(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMiniTracker(
                context, 
                'Feeding', 
                Icons.restaurant_menu, 
                theme.colorScheme.primary, 
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeedingTrackingPage()))
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMiniTracker(
                context, 
                'Sleep', 
                Icons.bedtime_outlined, 
                theme.colorScheme.tertiary, 
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SleepTrackingPage()))
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMiniTracker(
                context, 
                'Diaper', 
                Icons.layers_outlined, 
                theme.colorScheme.secondary, 
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DiaperTrackingPage()))
              ),
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
          border: Border.all(color: color.withOpacity(0.3)),
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
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
      child: InkWell(
        onTap: onTap,
        customBorder: Theme.of(context).cardTheme.shape,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  border: Border.all(color: color.withOpacity(0.3)),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title, 
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                      )
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle, 
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)
                        )
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios, 
                size: 14,
                color: Theme.of(context).colorScheme.tertiary.withOpacity(0.7)
              ),
            ],
          ),
        ),
      ),
    );
  }
}
