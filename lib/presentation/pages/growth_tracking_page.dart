import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:maternal_infant_care/data/models/growth_model.dart';
import 'package:maternal_infant_care/presentation/viewmodels/repository_providers.dart';
import 'package:maternal_infant_care/presentation/viewmodels/user_meta_provider.dart';
import 'package:maternal_infant_care/presentation/widgets/progress_chart.dart';
import 'package:fl_chart/fl_chart.dart';

class GrowthTrackingPage extends ConsumerStatefulWidget {
  const GrowthTrackingPage({super.key});

  @override
  ConsumerState<GrowthTrackingPage> createState() => _GrowthTrackingPageState();
}

class _GrowthTrackingPageState extends ConsumerState<GrowthTrackingPage> {
  @override
  Widget build(BuildContext context) {
    final growthRepo = ref.watch(growthRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Growth Tracking'),
      ),
      body: growthRepo.when(
        data: (repo) {
          final allGrowths = repo.getAllGrowths();
          final latest = repo.getLatestGrowth();

          return Column(
            children: [
              if (latest != null) _LatestGrowthCard(growth: latest),
              if (allGrowths.isNotEmpty) _GrowthCharts(growths: allGrowths),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: allGrowths.length,
                  itemBuilder: (context, index) {
                    final growth = allGrowths[index];
                    return _GrowthItemCard(
                      growth: growth, 
                      onDelete: () async {
                         await repo.deleteGrowth(growth.id);
                         ref.refresh(growthRepositoryProvider);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: ${error.toString()}')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddGrowthDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Record'),
      ),
    );
  }

  Future<void> _showAddGrowthDialog(BuildContext context) async {
    final weightController = TextEditingController();
    final heightController = TextEditingController();
    final headCircumferenceController = TextEditingController();
    final notesController = TextEditingController();

    final userMeta = ref.read(userMetaProvider);
    final birthday = userMeta.startDate;

    if (birthday == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Baby birthday not found. Please setup in profile.')),
      );
      return;
    }

    final ageInDays = DateTime.now().difference(birthday).inDays;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Growth Record'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Adding record for baby age: $ageInDays days',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: weightController,
                decoration: const InputDecoration(labelText: 'Weight (kg)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: heightController,
                decoration: const InputDecoration(labelText: 'Height (cm)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: headCircumferenceController,
                decoration: const InputDecoration(labelText: 'Head Circumference (cm)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(labelText: 'Notes (optional)'),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (weightController.text.isEmpty ||
                  heightController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill required fields')),
                );
                return;
              }

              try {
                final repo = await ref.read(growthRepositoryProvider.future);
                final growth = GrowthModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  timestamp: DateTime.now(),
                  weight: double.parse(weightController.text),
                  height: double.parse(heightController.text),
                  headCircumference: headCircumferenceController.text.isEmpty
                      ? 0.0
                      : double.parse(headCircumferenceController.text),
                  ageInDays: ageInDays,
                  notes: notesController.text.isEmpty ? null : notesController.text,
                );
                await repo.saveGrowth(growth);

                if (mounted) {
                  Navigator.pop(context);
                  setState(() {});
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _LatestGrowthCard extends StatelessWidget {
  final GrowthModel growth;

  const _LatestGrowthCard({required this.growth});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.tertiary,
            Theme.of(context).colorScheme.primary,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatColumn(
            label: 'Weight',
            value: '${growth.weight}kg',
            color: Colors.white,
          ),
          Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
          _StatColumn(
            label: 'Height',
            value: '${growth.height}cm',
            color: Colors.white,
          ),
          Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
          _StatColumn(
            label: 'Head',
            value: '${growth.headCircumference}cm',
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatColumn({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color.withOpacity(0.9),
              ),
        ),
      ],
    );
  }
}

class _GrowthCharts extends StatelessWidget {
  final List<GrowthModel> growths;

  const _GrowthCharts({required this.growths});

  @override
  Widget build(BuildContext context) {
    // if (growths.isEmpty) return const SizedBox.shrink(); // Show chart even if empty

    final weightSpots = growths.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.weight);
    }).toList();

    final heightSpots = growths.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.height);
    }).toList();

    return Column(
      children: [
        ProgressChart(spots: weightSpots, title: 'Weight Trend', yAxisLabel: 'kg'),
        const SizedBox(height: 16),
        ProgressChart(spots: heightSpots, title: 'Height Trend', yAxisLabel: 'cm'),
      ],
    );
  }
}

class _GrowthItemCard extends StatelessWidget {
  final GrowthModel growth;
  final VoidCallback onDelete;

  const _GrowthItemCard({required this.growth, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.show_chart, color: Theme.of(context).colorScheme.tertiary, size: 28),
        ),
        title: Text(
          'Age: ${growth.ageInDays} days',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'W: ${growth.weight}kg • H: ${growth.height}cm',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            if (growth.headCircumference > 0)
              Text(
                'Head: ${growth.headCircumference}cm',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            if (growth.notes != null) ...[
              const SizedBox(height: 4),
              Text(
                growth.notes!,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.grey),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
