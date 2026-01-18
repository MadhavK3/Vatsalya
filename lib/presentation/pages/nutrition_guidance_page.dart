import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NutritionGuidancePage extends ConsumerStatefulWidget {
  const NutritionGuidancePage({super.key});

  @override
  ConsumerState<NutritionGuidancePage> createState() => _NutritionGuidancePageState();
}

class _NutritionGuidancePageState extends ConsumerState<NutritionGuidancePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int? selectedAgeRange;

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition & Allergy Guide'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Age Guide'),
            Tab(text: 'Food Recommendations'),
            Tab(text: 'Allergy Info'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _AgeGuideTab(selectedAgeRange: selectedAgeRange, onAgeSelected: (age) {
            setState(() => selectedAgeRange = age);
          }),
          _FoodRecommendationsTab(selectedAge: selectedAgeRange),
          _AllergyInfoTab(),
        ],
      ),
    );
  }
}

class _AgeGuideTab extends StatelessWidget {
  final int? selectedAgeRange;
  final Function(int) onAgeSelected;

  const _AgeGuideTab({
    required this.selectedAgeRange,
    required this.onAgeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final ageRanges = [
      {'title': '0-6 Months', 'months': '0-6', 'icon': Icons.child_care, 'color': Colors.blue},
      {'title': '6-12 Months', 'months': '6-12', 'icon': Icons.baby_changing_station, 'color': Colors.orange},
      {'title': '1-3 Years', 'months': '12-36', 'icon': Icons.self_improvement, 'color': Colors.green},
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(24.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: ageRanges.length,
      itemBuilder: (context, index) {
        final range = ageRanges[index];
        final isSelected = selectedAgeRange == index;
        final color = range['color'] as Color;

        return InkWell(
          onTap: () => onAgeSelected(index),
          borderRadius: BorderRadius.circular(24),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? color.withOpacity(0.15) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected ? color : Colors.grey[200]!,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(range['icon'] as IconData, color: color, size: 32),
                ),
                const SizedBox(height: 16),
                Text(
                  range['title'] as String,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? color : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${range['months']} months',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(height: 8),
                  Icon(Icons.check_circle, color: color, size: 20),
                ]
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FoodRecommendationsTab extends StatelessWidget {
  final int? selectedAge;

  const _FoodRecommendationsTab({this.selectedAge});

  @override
  Widget build(BuildContext context) {
    if (selectedAge == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Select an age range first',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Go to "Age Guide" tab to select',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
            ),
          ],
        ),
      );
    }

    final recommendations = _getRecommendations(selectedAge!);

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Recommended Foods',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...recommendations['foods']!.map((food) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  food['name'] as String,
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                if (food['info'] != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    food['info'] as String,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.7),
                                        ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          color: Theme.of(context).colorScheme.errorContainer,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning, color: Theme.of(context).colorScheme.error),
                    const SizedBox(width: 8),
                    Text(
                      'Foods to Avoid',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...recommendations['avoid']!.map((food) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.cancel,
                            color: Theme.of(context).colorScheme.error,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              food,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: Theme.of(context).colorScheme.tertiary),
                    const SizedBox(width: 8),
                    Text(
                      'Tips',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...recommendations['tips']!.map((tip) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.star,
                            color: Theme.of(context).colorScheme.tertiary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              tip,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Map<String, List> _getRecommendations(int ageIndex) {
    final allRecommendations = [
      {
        'foods': [
          {'name': 'Breast Milk', 'info': 'Primary source of nutrition'},
          {'name': 'Formula Milk', 'info': 'If breastfeeding is not possible'},
        ],
        'avoid': [
          'Solid foods',
          'Honey (risk of botulism)',
          'Cow\'s milk as main drink',
          'Sugary drinks',
        ],
        'tips': [
          'Feed on demand, typically 8-12 times per day',
          'Ensure adequate hydration',
          'No water needed if exclusively breastfeeding',
        ],
      },
      {
        'foods': [
          {'name': 'Breast Milk / Formula', 'info': 'Continue as primary milk source'},
          {'name': 'Iron-fortified Cereals', 'info': 'Rice, oatmeal cereals'},
          {'name': 'Pureed Fruits', 'info': 'Apple, banana, pear'},
          {'name': 'Pureed Vegetables', 'info': 'Sweet potato, carrot, peas'},
          {'name': 'Soft Proteins', 'info': 'Pureed meat, fish, eggs'},
          {'name': 'Mashed Beans', 'info': 'Rich in protein and iron'},
        ],
        'avoid': [
          'Honey (risk of botulism)',
          'Whole nuts (choking hazard)',
          'Raw honey',
          'Added salt and sugar',
          'Hard, round foods (grapes, whole cherry tomatoes)',
        ],
        'tips': [
          'Introduce one new food at a time (wait 3-5 days between new foods)',
          'Start with iron-fortified cereals mixed with breast milk/formula',
          'Progress from purees to mashed and finger foods',
          'Offer water in a sippy cup',
          'Watch for allergic reactions (rash, vomiting, diarrhea)',
        ],
      },
      {
        'foods': [
          {'name': 'Whole Grains', 'info': 'Whole wheat bread, rice, pasta'},
          {'name': 'Fruits & Vegetables', 'info': 'All varieties, washed and cut appropriately'},
          {'name': 'Proteins', 'info': 'Meat, fish, eggs, beans, lentils'},
          {'name': 'Dairy', 'info': 'Whole milk, yogurt, cheese'},
          {'name': 'Healthy Fats', 'info': 'Avocado, nuts (ground), olive oil'},
        ],
        'avoid': [
          'Honey (until 12 months)',
          'Whole nuts (choking hazard - use ground/powder)',
          'Large chunks that can cause choking',
          'Excessive sugar and salt',
          'Caffeinated beverages',
        ],
        'tips': [
          'Offer 3 main meals + 2-3 snacks per day',
          'Cut foods into safe sizes to prevent choking',
          'Encourage self-feeding with appropriate utensils',
          'Continue to introduce variety and new textures',
          'Monitor for food allergies and intolerances',
          'Limit juice to 4-6 oz per day',
        ],
      },
    ];

    return allRecommendations[ageIndex];
  }
}

class _AllergyInfoTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final commonAllergens = [
      {
        'name': 'Cow\'s Milk',
        'symptoms': ['Rash', 'Vomiting', 'Diarrhea', 'Wheezing'],
        'risk': 'High',
        'introduction': 'Wait until 12 months, start with small amounts',
      },
      {
        'name': 'Eggs',
        'symptoms': ['Hives', 'Swelling', 'Digestive issues', 'Difficulty breathing'],
        'risk': 'High',
        'introduction': 'Start with well-cooked yolk at 6-8 months',
      },
      {
        'name': 'Peanuts',
        'symptoms': ['Rash', 'Swelling', 'Anaphylaxis', 'Vomiting'],
        'risk': 'High',
        'introduction': 'Introduce in powder form between 6-8 months',
      },
      {
        'name': 'Tree Nuts',
        'symptoms': ['Hives', 'Swelling', 'Breathing difficulties'],
        'risk': 'High',
        'introduction': 'Start with ground nuts after 6 months',
      },
      {
        'name': 'Fish',
        'symptoms': ['Rash', 'Swelling', 'Digestive issues'],
        'risk': 'Moderate',
        'introduction': 'Introduce well-cooked fish at 6-8 months',
      },
      {
        'name': 'Shellfish',
        'symptoms': ['Severe allergic reactions', 'Anaphylaxis'],
        'risk': 'High',
        'introduction': 'Wait until 12 months, introduce cautiously',
      },
      {
        'name': 'Soy',
        'symptoms': ['Rash', 'Digestive issues', 'Wheezing'],
        'risk': 'Moderate',
        'introduction': 'Can be introduced at 6 months in small amounts',
      },
      {
        'name': 'Wheat',
        'symptoms': ['Rash', 'Digestive issues', 'Bloating'],
        'risk': 'Moderate',
        'introduction': 'Introduce iron-fortified cereals at 6 months',
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Card(
          color: Theme.of(context).colorScheme.errorContainer,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Theme.of(context).colorScheme.error),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Always introduce new foods one at a time and wait 3-5 days before introducing another new food to monitor for reactions.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Common Allergens',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        ...commonAllergens.map((allergen) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: allergen['risk'] == 'High'
                      ? Theme.of(context).colorScheme.errorContainer
                      : Theme.of(context).colorScheme.tertiaryContainer,
                  child: Icon(
                    Icons.warning,
                    color: allergen['risk'] == 'High'
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.tertiary,
                  ),
                ),
                title: Text(
                  allergen['name'] as String,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text('Risk: ${allergen['risk']}'),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Common Symptoms:',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: (allergen['symptoms'] as List).map((symptom) {
                            return Chip(
                              label: Text(symptom),
                              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Introduction Guidelines:',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          allergen['introduction'] as String,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
        const SizedBox(height: 16),
        Card(
          color: Theme.of(context).colorScheme.errorContainer,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.emergency, color: Theme.of(context).colorScheme.error),
                    const SizedBox(width: 8),
                    Text(
                      'When to Seek Immediate Medical Help',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const _EmergencyIndicator(
                  text: 'Difficulty breathing or wheezing',
                ),
                const _EmergencyIndicator(
                  text: 'Swelling of face, lips, or tongue',
                ),
                const _EmergencyIndicator(
                  text: 'Severe vomiting or diarrhea',
                ),
                const _EmergencyIndicator(
                  text: 'Loss of consciousness',
                ),
                const _EmergencyIndicator(
                  text: 'Severe rash covering large areas',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EmergencyIndicator extends StatelessWidget {
  final String text;

  const _EmergencyIndicator({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error, color: Theme.of(context).colorScheme.error, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
