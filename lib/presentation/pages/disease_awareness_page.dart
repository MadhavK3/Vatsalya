import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maternal_infant_care/core/theme/app_theme.dart';

class DiseaseAwarenessPage extends ConsumerStatefulWidget {
  const DiseaseAwarenessPage({super.key});

  @override
  ConsumerState<DiseaseAwarenessPage> createState() => _DiseaseAwarenessPageState();
}

class _DiseaseAwarenessPageState extends ConsumerState<DiseaseAwarenessPage> {
  String searchQuery = '';
  String selectedCategory = 'All';
  Map<String, dynamic>? selectedDisease;

  final List<String> categories = ['All', 'Common', 'Respiratory', 'Digestive', 'Other'];

  @override
  Widget build(BuildContext context) {
    final allDiseases = _getCommonDiseases();
    final filteredDiseases = allDiseases.where((disease) {
      final matchesSearch = disease['name'].toString().toLowerCase().contains(searchQuery.toLowerCase());
      final matchesCategory = selectedCategory == 'All' || disease['category'] == selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Disease Awareness'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  onChanged: (value) => setState(() => searchQuery = value),
                  decoration: const InputDecoration(
                    hintText: 'Search conditions...',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categories.map((category) {
                      final isSelected = selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() => selectedCategory = category);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredDiseases.isEmpty
                ? const Center(
                    child: Text('No results found.'),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: filteredDiseases.length,
                    itemBuilder: (context, index) {
                      final disease = filteredDiseases[index];
                      return _DiseaseHubCard(
                        disease: disease,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DiseaseDetailPage(disease: disease),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getCommonDiseases() {
    return [
      {
        'name': 'Common Cold',
        'category': 'Common',
        'icon': Icons.ac_unit,
        'color': const Color(0xFF4FC3F7), // Light Blue
        'symptoms': ['Runny nose', 'Sneezing', 'Cough', 'Mild fever', 'Irritability'],
        'prevention': [
          'Wash hands frequently',
          'Keep baby away from sick people',
          'Clean toys and surfaces regularly',
          'Avoid sharing utensils',
        ],
        'homeCare': [
          'Ensure adequate rest',
          'Keep baby hydrated with breast milk/formula',
          'Use saline drops for stuffy nose',
          'Monitor temperature',
        ],
        'seeDoctor': [
          'Fever above 100.4°F in babies under 3 months',
          'Difficulty breathing',
          'Severe cough lasting more than a week',
          'Signs of dehydration',
        ],
        'riskLevel': 'Low',
      },
      {
        'name': 'Fever',
        'category': 'Common',
        'icon': Icons.thermostat,
        'color': const Color(0xFFFFB74D), // Soft Orange
        'symptoms': ['Elevated body temperature', 'Irritability', 'Decreased appetite', 'Lethargy'],
        'prevention': [
          'Maintain good hygiene',
          'Ensure proper vaccination',
          'Keep baby away from sick individuals',
        ],
        'homeCare': [
          'Monitor temperature regularly',
          'Dress baby in light clothing',
          'Ensure adequate fluid intake',
          'Give lukewarm sponge baths if recommended',
        ],
        'seeDoctor': [
          'Fever above 100.4°F in babies under 3 months',
          'Fever above 102.2°F in older babies',
          'Fever lasting more than 3 days',
          'Baby appears very ill or unresponsive',
        ],
        'riskLevel': 'Moderate',
      },
      {
        'name': 'Diarrhea',
        'category': 'Digestive',
        'icon': Icons.water_drop,
        'color': const Color(0xFF8D6E63), // Sandalwood
        'symptoms': [
          'Frequent loose, watery stools',
          'Dehydration signs',
          'Reduced urine output',
          'Irritability',
        ],
        'prevention': [
          'Maintain hygiene and sanitation',
          'Wash hands before handling food',
          'Ensure safe water sources',
          'Practice safe food preparation',
        ],
        'homeCare': [
          'Continue breastfeeding/formula feeding',
          'Offer ORS as advised',
          'Monitor for signs of dehydration',
          'Change diapers frequently',
        ],
        'seeDoctor': [
          'Signs of dehydration (dry mouth, no tears)',
          'Blood in stools',
          'Diarrhea lasting more than 24 hours',
          'High fever with diarrhea',
        ],
        'riskLevel': 'High',
      },
      {
        'name': 'RSV',
        'category': 'Respiratory',
        'icon': Icons.air,
        'color': const Color(0xFFEF5350), // Soft Red
        'symptoms': [
          'Runny nose',
          'Cough',
          'Wheezing',
          'Difficulty breathing',
          'Fever',
        ],
        'prevention': [
          'Wash hands frequently',
          'Avoid close contact with sick people',
          'Keep away from crowds during season',
          'Clean and disinfect surfaces',
        ],
        'homeCare': [
          'Ensure adequate rest and hydration',
          'Use humidifier to ease breathing',
          'Keep baby in upright position',
          'Monitor breathing closely',
        ],
        'seeDoctor': [
          'Rapid or difficulty breathing',
          'Bluish color around lips',
          'Signs of dehydration',
          'High fever',
        ],
        'riskLevel': 'High',
      },
    ];
  }
}

class _DiseaseHubCard extends StatelessWidget {
  final Map<String, dynamic> disease;
  final VoidCallback onTap;

  const _DiseaseHubCard({required this.disease, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final riskColor = disease['riskLevel'] == 'High'
        ? Colors.red
        : disease['riskLevel'] == 'Moderate'
            ? Colors.orange
            : Colors.green;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (disease['color'] as Color).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  disease['icon'] as IconData,
                  color: disease['color'] as Color,
                  size: 24,
                ),
              ),
              const Spacer(),
              Text(
                disease['name'] as String,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: riskColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${disease['riskLevel']} Risk',
                    style: TextStyle(
                      fontSize: 12,
                      color: riskColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DiseaseDetailPage extends StatelessWidget {
  final Map<String, dynamic> disease;

  const DiseaseDetailPage({super.key, required this.disease});

  @override
  Widget build(BuildContext context) {
    final riskColor = disease['riskLevel'] == 'High'
        ? Colors.red
        : disease['riskLevel'] == 'Moderate'
            ? Colors.orange
            : Colors.green;

    return Scaffold(
      appBar: AppBar(
        title: Text(disease['name'] as String),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: riskColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.warning_amber_rounded, size: 20, color: riskColor),
                  const SizedBox(width: 8),
                  Text(
                    'Risk Level: ${disease['riskLevel']}',
                    style: TextStyle(
                      color: riskColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _DetailSection(
              title: 'Symptoms',
              icon: Icons.info_outline,
              items: (disease['symptoms'] as List).cast<String>(),
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            _DetailSection(
              title: 'Prevention',
              icon: Icons.shield_outlined,
              items: (disease['prevention'] as List).cast<String>(),
              color: Colors.green,
            ),
            const SizedBox(height: 24),
            _DetailSection(
              title: 'Home Care',
              icon: Icons.home_outlined,
              items: (disease['homeCare'] as List).cast<String>(),
              color: Colors.orange,
            ),
            const SizedBox(height: 32),
            _EmergencySection(
              items: (disease['seeDoctor'] as List).cast<String>(),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<String> items;
  final Color color;

  const _DetailSection({
    required this.title,
    required this.icon,
    required this.items,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0, left: 36.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle_outline, size: 16, color: color.withOpacity(0.7)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}

class _EmergencySection extends StatelessWidget {
  final List<String> items;

  const _EmergencySection({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.emergency_rounded, color: Colors.red, size: 24),
              const SizedBox(width: 12),
              Text(
                'When to See a Doctor',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
