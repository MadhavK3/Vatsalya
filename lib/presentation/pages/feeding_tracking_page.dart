import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:maternal_infant_care/core/constants/app_constants.dart';
import 'package:maternal_infant_care/data/models/feeding_model.dart';
import 'package:maternal_infant_care/presentation/viewmodels/repository_providers.dart';

class FeedingTrackingPage extends ConsumerStatefulWidget {
  const FeedingTrackingPage({super.key});

  @override
  ConsumerState<FeedingTrackingPage> createState() => _FeedingTrackingPageState();
}

class _FeedingTrackingPageState extends ConsumerState<FeedingTrackingPage> {
  @override
  Widget build(BuildContext context) {
    final feedingRepo = ref.watch(feedingRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feeding Tracker'),
      ),
      body: feedingRepo.when(
        data: (repo) {
          final today = DateTime.now();
          final todayFeedings = repo.getFeedingsByDate(today);
          final allFeedings = repo.getAllFeedings();

          return Column(
            children: [
              _TodaySummaryCard(feedings: todayFeedings),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: allFeedings.length,
                  itemBuilder: (context, index) {
                    final feeding = allFeedings[index];
                    return _FeedingItemCard(feeding: feeding, repo: repo);
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
        onPressed: () => _showAddFeedingDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Feeding'),
      ),
    );
  }

  Future<void> _showAddFeedingDialog(BuildContext context) async {
    final typeController = TextEditingController();
    final quantityController = TextEditingController();
    final notesController = TextEditingController();
    String selectedType = AppConstants.feedingTypes[0];

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Feeding'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: AppConstants.feedingTypes.map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedType = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: quantityController,
                  decoration: const InputDecoration(labelText: 'Quantity'),
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
                if (quantityController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter quantity')),
                  );
                  return;
                }

                try {
                  final repo = await ref.read(feedingRepositoryProvider.future);
                  final feeding = FeedingModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    timestamp: DateTime.now(),
                    type: selectedType,
                    quantity: double.parse(quantityController.text),
                    notes: notesController.text.isEmpty ? null : notesController.text,
                  );
                  await repo.saveFeeding(feeding);

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
      ),
    );
  }
}

class _TodaySummaryCard extends StatelessWidget {
  final List<FeedingModel> feedings;

  const _TodaySummaryCard({required this.feedings});

  @override
  Widget build(BuildContext context) {
    final totalQuantity = feedings.fold(0.0, (sum, f) => sum + f.quantity);

    return Card(
      elevation: 4,
      shape: Theme.of(context).cardTheme.shape,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.tertiary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatColumn(
              label: 'Total',
              value: '${totalQuantity.toStringAsFixed(0)}ml',
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            Container(width: 1, height: 40, color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.3)),
            _StatColumn(
              label: 'Sessions',
              value: '${feedings.length}',
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ],
        ),
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
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
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

class _FeedingItemCard extends StatelessWidget {
  final FeedingModel feeding;
  final dynamic repo;

  const _FeedingItemCard({required this.feeding, required this.repo});

  @override
  Widget build(BuildContext context) {
    IconData feedingIcon;
    Color feedingColor;
    final theme = Theme.of(context);

    switch (feeding.type) {
      case 'Breastfeeding':
        feedingIcon = Icons.favorite_border;
        feedingColor = theme.colorScheme.primary;
        break;
      case 'Formula':
        feedingIcon = Icons.water_drop_outlined;
        feedingColor = theme.colorScheme.tertiary; // More distinct
        break;
      case 'Solid Food':
        feedingIcon = Icons.restaurant_menu;
        feedingColor = theme.colorScheme.secondary;
        break;
      default:
        feedingIcon = Icons.lunch_dining;
        feedingColor = theme.colorScheme.onSurface;
    }

    return Card(
      elevation: 2,
      shape: theme.cardTheme.shape,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: feedingColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(feedingIcon, color: feedingColor, size: 28),
        ),
        title: Text(
          feeding.type,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${feeding.quantity}${feeding.unit} • ${DateFormat('hh:mm a').format(feeding.timestamp)}',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)),
            ),
            if (feeding.notes != null) ...[
              const SizedBox(height: 4),
              Text(
                feeding.notes!,
                style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete_outline, color: theme.colorScheme.error.withOpacity(0.6)),
          onPressed: () async {
            try {
              await repo.deleteFeeding(feeding.id);
            } catch (e) {}
          },
        ),
      ),
    );
  }
}
