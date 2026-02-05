import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maternal_infant_care/presentation/viewmodels/user_meta_provider.dart';

class ActivityIdeasPage extends ConsumerStatefulWidget {
  const ActivityIdeasPage({super.key});

  @override
  ConsumerState<ActivityIdeasPage> createState() => _ActivityIdeasPageState();
}

class _ActivityIdeasPageState extends ConsumerState<ActivityIdeasPage> {
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Physical', 'Cognitive', 'Sensory', 'Social', 'Creative', 'Outdoors'];

  @override
  Widget build(BuildContext context) {
    final userMeta = ref.watch(userMetaProvider);
    final birthday = userMeta.startDate;
    final ageInDays = birthday != null ? DateTime.now().difference(birthday).inDays : 0;
    final ageInMonths = (ageInDays / 30.44).floor();

    final allActivities = _getActivitiesForAge(ageInMonths);
    final filteredActivities = _selectedCategory == 'All'
        ? allActivities
        : allActivities.where((a) => a.tags.contains(_selectedCategory)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Ideas'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    backgroundColor: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
                    labelStyle: TextStyle(
                      color: isSelected ? Theme.of(context).colorScheme.onPrimaryContainer : null,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: filteredActivities.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.category_outlined, size: 60, color: Theme.of(context).colorScheme.outline),
                        const SizedBox(height: 16),
                        const Text('No activities found for this category.'),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredActivities.length,
                    itemBuilder: (context, index) {
                      final activity = filteredActivities[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(activity.icon, color: Theme.of(context).colorScheme.primary),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          activity.title,
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                        ),
                                        if (activity.duration != null)
                                            Text(
                                              activity.duration!,
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: Theme.of(context).colorScheme.outline
                                              ),
                                            ),
                                      ],
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
                                          visualDensity: VisualDensity.compact,
                                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          backgroundColor: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.5),
                                        ))
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  List<ActivityIdea> _getActivitiesForAge(int months) {
    if (months < 3) {
      return [
        ActivityIdea(title: 'Tummy Time', description: 'Place baby on tummy to strengthen neck/shoulders.', icon: Icons.child_care, tags: ['Physical'], duration: '5-10 mins'),
        ActivityIdea(title: 'High Contrast', description: 'Show black & white cards.', icon: Icons.visibility, tags: ['Sensory', 'Cognitive'], duration: '5 mins'),
        ActivityIdea(title: 'Gentle Massage', description: 'Rub legs and arms gently.', icon: Icons.spa, tags: ['Sensory', 'Physical'], duration: '10 mins'),
        ActivityIdea(title: 'Singing', description: 'Sing lullabies or talk softly.', icon: Icons.music_note, tags: ['Sensory', 'Social']),
      ];
    } else if (months < 6) {
      return [
        ActivityIdea(title: 'Rattle Play', description: 'Shake a rattle and let them track sound.', icon: Icons.toys, tags: ['Sensory', 'Cognitive'], duration: '10 mins'),
        ActivityIdea(title: 'Supported Sit', description: 'Prop them up with pillows.', icon: Icons.chair, tags: ['Physical'], duration: '5-10 mins'),
        ActivityIdea(title: 'Mirror Play', description: 'Let them see their reflection.', icon: Icons.face, tags: ['Cognitive', 'Social'], duration: '10 mins'),
        ActivityIdea(title: 'Texture Feel', description: 'Let them touch fabrics.', icon: Icons.touch_app, tags: ['Sensory'], duration: '5 mins'),
      ];
    } else if (months < 12) {
      return [
        ActivityIdea(title: 'Peek-a-Boo', description: 'Hide face and reveal.', icon: Icons.sentiment_very_satisfied, tags: ['Social', 'Cognitive'], duration: '10 mins'),
        ActivityIdea(title: 'Crawling Course', description: 'Pillows obstacle course.', icon: Icons.directions_run, tags: ['Physical'], duration: '15 mins'),
        ActivityIdea(title: 'Stacking Cups', description: 'Stack and knock down.', icon: Icons.layers, tags: ['Cognitive', 'Physical']),
        ActivityIdea(title: 'Water Splash', description: 'Sensory water play (supervised).', icon: Icons.water_drop, tags: ['Sensory'], duration: '20 mins'),
      ];
    } else if (months < 24) {
      return [
        ActivityIdea(title: 'Shape Sorter', description: 'Fit shapes into holes.', icon: Icons.category, tags: ['Cognitive', 'Problem Solving'], duration: '15 mins'),
        ActivityIdea(title: 'Dance Party', description: 'Move to music.', icon: Icons.music_note, tags: ['Physical', 'Social'], duration: '15 mins'),
        ActivityIdea(title: 'Scribbling', description: 'Crayons on paper.', icon: Icons.create, tags: ['Creative', 'Physical'], duration: '10 mins'),
        ActivityIdea(title: 'Ball Roll', description: 'Roll ball back and forth.', icon: Icons.sports_soccer, tags: ['Social', 'Physical'], duration: '10 mins'),
        ActivityIdea(title: 'Nature Walk', description: 'Walk outside and name items.', icon: Icons.park, tags: ['Outdoors', 'Sensory'], duration: '20 mins'),
      ];
    } else {
      // 2+ years
      return [
        ActivityIdea(title: 'Pretend Play', description: 'Kitchen, doctor, store.', icon: Icons.shopping_bag, tags: ['Social', 'Creative'], duration: '30 mins'),
        ActivityIdea(title: 'Simple Puzzles', description: 'Wood puzzles or matching.', icon: Icons.extension, tags: ['Cognitive', 'Problem Solving'], duration: '15 mins'),
        ActivityIdea(title: 'Obstacle Course', description: 'Run, jump, crawl path.', icon: Icons.flag, tags: ['Physical', 'Outdoors'], duration: '30 mins'),
        ActivityIdea(title: 'Painting', description: 'Finger paints or brush.', icon: Icons.palette, tags: ['Creative', 'Sensory'], duration: '20 mins'),
        ActivityIdea(title: 'Story Time', description: 'Read longer books.', icon: Icons.menu_book, tags: ['Cognitive', 'Social'], duration: '15 mins'),
        ActivityIdea(title: 'Playground', description: 'Slides and swings.', icon: Icons.landscape, tags: ['Outdoors', 'Physical'], duration: '45 mins'),
      ];
    }
  }
}

class ActivityIdea {
  final String title;
  final String description;
  final IconData icon;
  final List<String> tags;
  final String? duration;

  ActivityIdea({
    required this.title,
    required this.description,
    required this.icon,
    required this.tags,
    this.duration,
  });
}
