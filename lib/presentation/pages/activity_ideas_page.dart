import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maternal_infant_care/presentation/viewmodels/user_meta_provider.dart';

class ActivityIdeasPage extends ConsumerWidget {
  const ActivityIdeasPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userMeta = ref.watch(userMetaProvider);
    final birthday = userMeta.startDate;
    final ageInDays = birthday != null ? DateTime.now().difference(birthday).inDays : 0;
    final ageInMonths = (ageInDays / 30.44).floor();

    final activities = _getActivitiesForAge(ageInMonths);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Ideas'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: activities.length,
        itemBuilder: (context, index) {
          final activity = activities[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(activity.icon, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          activity.title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    activity.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: activity.tags
                        .map((tag) => Chip(
                              label: Text(tag, style: const TextStyle(fontSize: 10)),
                              padding: EdgeInsets.zero,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<ActivityIdea> _getActivitiesForAge(int months) {
    if (months < 6) {
      return [
        ActivityIdea(
          title: 'Tummy Time',
          description: 'Place your baby on their tummy for short periods to strengthen neck and shoulder muscles.',
          icon: Icons.child_care,
          tags: ['Physical', 'Motor Skills'],
        ),
        ActivityIdea(
          title: 'High-Contrast Images',
          description: 'Show black and white or high-contrast patterns to stimulate visual development.',
          icon: Icons.remove_red_eye,
          tags: ['Visual', 'Cognitive'],
        ),
      ];
    } else if (months < 12) {
      return [
        ActivityIdea(
          title: 'Peek-a-Boo',
          description: 'A classic game to help with object permanence and social interaction.',
          icon: Icons.sentiment_very_satisfied,
          tags: ['Social', 'Cognitive'],
        ),
        ActivityIdea(
          title: 'Texture Exploration',
          description: 'Let your baby feel different textures like soft blankets, bumpy balls, and crinkly paper.',
          icon: Icons.touch_app,
          tags: ['Sensory', 'Discovery'],
        ),
      ];
    } else if (months < 24) {
      return [
        ActivityIdea(
          title: 'Stacking Blocks',
          description: 'Encourage your toddler to stack blocks or containers to improve fine motor skills and hand-eye coordination.',
          icon: Icons.grid_view,
          tags: ['Motor Skills', 'Problem Solving'],
        ),
        ActivityIdea(
          title: 'Simple Sorting',
          description: 'Use large items of different colors or shapes and show them how to sort them into baskets.',
          icon: Icons.category,
          tags: ['Cognitive', 'Logic'],
        ),
      ];
    } else {
      return [
        ActivityIdea(
          title: 'Imaginative Play',
          description: 'Encourage pretend play with dolls, toy kitchens, or dress-up clothes.',
          icon: Icons.auto_awesome,
          tags: ['Creative', 'Social'],
        ),
        ActivityIdea(
          title: 'Drawing & Coloring',
          description: 'Provide chunky crayons and large paper for your toddler to explore their artistic side.',
          icon: Icons.edit,
          tags: ['Fine Motor', 'Artistic'],
        ),
      ];
    }
  }
}

class ActivityIdea {
  final String title;
  final String description;
  final IconData icon;
  final List<String> tags;

  ActivityIdea({
    required this.title,
    required this.description,
    required this.icon,
    required this.tags,
  });
}
