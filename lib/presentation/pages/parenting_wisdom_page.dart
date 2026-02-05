import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ParentingWisdomPage extends ConsumerWidget {
  const ParentingWisdomPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We can expand this to be dynamic or categorized later.
    // For now, let's show a list of wisdom categories/articles.
    final wisdomList = _getWisdomList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Parenting Wisdom'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: wisdomList.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final item = wisdomList[index];
          return Card(
            child: ExpansionTile(
              leading: Icon(item.icon, color: Theme.of(context).colorScheme.secondary),
              title: Text(
                item.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                item.category,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 12,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    item.content,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<WisdomItem> _getWisdomList() {
    return [
      WisdomItem(
        title: 'The Power of Routine',
        category: 'Behavior',
        content: 'Toddlers thrive on routine. Consistency helps them feel safe and secure. Try to keep regular sleep and meal times.',
        icon: Icons.schedule,
      ),
      WisdomItem(
        title: 'Dealing with Tantrums',
        category: 'Emotional Health',
        content: 'Tantrums are a normal part of development. Stay calm, validate their feelings ("I see you are angry"), and help them Self-Regulate.',
        icon: Icons.sentiment_dissatisfied,
      ),
      WisdomItem(
        title: 'Encouraging Independence',
        category: 'Development',
        content: 'Let your child do simple tasks like putting on socks or picking up toys. It builds confidence and motor skills.',
        icon: Icons.accessibility_new,
      ),
      WisdomItem(
        title: 'Healthy Eating Habits',
        category: 'Nutrition',
        content: 'Offer a variety of foods and be patient. It often takes multiple exposures for a child to accept a new food.',
        icon: Icons.restaurant,
      ),
      WisdomItem(
        title: 'Reading Together',
        category: 'Bonding',
        content: 'Reading aloud everyday stimulates language development and fosters a love for books from an early age.',
        icon: Icons.menu_book,
      ),
      WisdomItem(
        title: 'Positive Reinforcement',
        category: 'Discipline',
        content: 'Praise good behavior specifically. "Good job putting your shoes away" is better than just "Good boy".',
        icon: Icons.thumb_up,
      ),
      WisdomItem(
        title: 'Safe Exploration',
        category: 'Safety',
        content: 'Child-proof your home to create a safe environment where they can explore freely without constant "No"s.',
        icon: Icons.security,
      ),
    ];
  }
}

class WisdomItem {
  final String title;
  final String category;
  final String content;
  final IconData icon;

  WisdomItem({
    required this.title,
    required this.category,
    required this.content,
    required this.icon,
  });
}
