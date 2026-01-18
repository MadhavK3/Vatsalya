import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maternal_infant_care/presentation/viewmodels/user_meta_provider.dart';

class DailyTipsPage extends ConsumerWidget {
  const DailyTipsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userMeta = ref.watch(userMetaProvider);
    final startDate = userMeta.startDate;
    final now = DateTime.now();
    
    // Calculate current week
    int currentWeek = 1;
    if (startDate != null) {
      currentWeek = (now.difference(startDate).inDays / 7).floor() + 1;
    }
    
    // Clamp to 1-40 range for pregnancy
    currentWeek = currentWeek.clamp(1, 40);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pregnancy Timeline'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(color: Theme.of(context).scaffoldBackgroundColor),
          ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 20),
            itemCount: 40,
            itemBuilder: (context, index) {
              final week = index + 1;
              final isCurrent = week == currentWeek;
              final isPast = week < currentWeek;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      // Timeline column
                      Column(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isCurrent 
                                  ? Theme.of(context).colorScheme.primary 
                                  : isPast 
                                      ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
                                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                              border: isCurrent 
                                  ? Border.all(color: Theme.of(context).colorScheme.onPrimary, width: 2) 
                                  : null,
                              boxShadow: isCurrent 
                                  ? [BoxShadow(color: Theme.of(context).colorScheme.primary.withOpacity(0.5), blurRadius: 10)] 
                                  : null,
                            ),
                          ),
                          if (week < 40)
                            Expanded(
                              child: Container(
                                width: 2,
                                color: isPast ? Theme.of(context).colorScheme.primary.withOpacity(0.5) : Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 24),
                      // Content column
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 24),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isCurrent 
                                ? Theme.of(context).colorScheme.surface 
                                : Theme.of(context).colorScheme.surface.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(16),
                            border: isCurrent 
                                ? Border.all(color: Theme.of(context).colorScheme.secondary) 
                                : Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1)),
                            boxShadow: [
                            BoxShadow(color: Theme.of(context).colorScheme.shadow.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Week $week',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: isCurrent ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                  if (isCurrent)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.secondary,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'Today', 
                                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: Theme.of(context).colorScheme.onSecondary, 
                                          fontWeight: FontWeight.bold
                                        )
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _getTipForWeek(week),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                                  height: 1.4,
                                ),
                              ),
                              if (isCurrent) ...[
                                const SizedBox(height: 12),
                                const Divider(),
                                Row(
                                  children: [
                                    Icon(Icons.info_outline, size: 14, color: Theme.of(context).colorScheme.tertiary),
                                    const SizedBox(width: 4),
                                    Text('Baby is developing taste buds now!', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
                                  ],
                                ),
                              ]
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _getTipForWeek(int week) {
    final tips = [
      'Take folic acid supplements daily.',
      'Drink plenty of water (8-10 glasses).',
      'Eat small, frequent meals for nausea.',
      'Wear a supportive bra as breasts change.',
      'Schedule your first prenatal appointment.',
      'Avoid high-mercury fish and raw seafood.',
      'Get 8-10 hours of sleep per night.',
      'Start a gentle exercise routine like walking.',
      'Moisturize your belly to help with stretch marks.',
      'Ensure you are getting enough iron from food.',
      'Listen to your body and rest when tired.',
      'Connect with other expecting mothers.',
      'Start reading about childbirth and newborn care.',
      'Focus on good posture as your gravity shifts.',
      'Elevate your feet to reduce swelling.',
      'Eat more fiber to prevent constipation.',
      'Do pelvic floor (Kegel) exercises regularly.',
      'Avoid standing for long periods.',
      'Sleep on your side, preferably the left.',
      'Stay cool and avoid overheating.',
    ];
    
    return tips[(week - 1) % tips.length];
  }
}
