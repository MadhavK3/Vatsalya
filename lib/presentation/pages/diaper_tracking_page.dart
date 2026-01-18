import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:maternal_infant_care/core/constants/app_constants.dart';
import 'package:maternal_infant_care/data/models/diaper_model.dart';
import 'package:maternal_infant_care/presentation/viewmodels/repository_providers.dart';

class DiaperTrackingPage extends ConsumerStatefulWidget {
  const DiaperTrackingPage({super.key});

  @override
  ConsumerState<DiaperTrackingPage> createState() => _DiaperTrackingPageState();
}

class _DiaperTrackingPageState extends ConsumerState<DiaperTrackingPage> {
  @override
  Widget build(BuildContext context) {
    final diaperRepo = ref.watch(diaperRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diaper Tracker'),
        elevation: 0,
      ),
      body: diaperRepo.when(
        data: (repo) {
          final today = DateTime.now();
          final todayDiapers = repo.getDiapersByDate(today);
          final allDiapers = repo.getAllDiapers();

          return Column(
            children: [
              _DiaperSummaryCard(diapers: todayDiapers),
              Expanded(
                child: allDiapers.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: allDiapers.length,
                        itemBuilder: (context, index) {
                          final diaper = allDiapers[index];
                          return _DiaperItemCard(diaper: diaper, repo: repo);
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
        onPressed: () => _showAddDiaperDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('New Change'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.layers_outlined, size: 80, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            'No diaper changes logged yet',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddDiaperDialog(BuildContext context) async {
    final notesController = TextEditingController();
    String selectedStatus = AppConstants.diaperTypes[0];

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Diaper Change'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('What was the status?'),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: AppConstants.diaperTypes.map((status) {
                  final isSelected = selectedStatus == status;
                  return ChoiceChip(
                    label: Text(status),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setDialogState(() => selectedStatus = status);
                      }
                    },
                    selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: isSelected ? Theme.of(context).colorScheme.primary : null,
                      fontWeight: isSelected ? FontWeight.bold : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: InputDecoration(
                  labelText: 'Notes',
                  hintText: 'Any observations?',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final repo = await ref.read(diaperRepositoryProvider.future);
                  final diaper = DiaperModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    timestamp: DateTime.now(),
                    status: selectedStatus,
                    notes: notesController.text.isEmpty ? null : notesController.text,
                  );
                  await repo.addDiaper(diaper);

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

class _DiaperSummaryCard extends StatelessWidget {
  final List<DiaperModel> diapers;

  const _DiaperSummaryCard({required this.diapers});

  @override
  Widget build(BuildContext context) {
    final wetCount = diapers.where((d) => d.status == 'Wet' || d.status == 'Both').length;
    final dirtyCount = diapers.where((d) => d.status == 'Dirty' || d.status == 'Both').length;

    return Card(
      elevation: 4,
      shape: Theme.of(context).cardTheme.shape,
      child: Container(
        padding: const EdgeInsets.all(24),
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
        child: Column(
          children: [
            Text(
              'Today\'s Changes',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                  label: 'Total', 
                  value: '${diapers.length}', 
                  icon: Icons.history,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                _StatItem(
                  label: 'Wet', 
                  value: '$wetCount', 
                  icon: Icons.water_drop,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                _StatItem(
                  label: 'Dirty', 
                  value: '$dirtyCount', 
                  icon: Icons.warning_amber,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color.withOpacity(0.8), size: 24),
        const SizedBox(height: 8),
        Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: color, 
          fontWeight: FontWeight.bold
        )),
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color.withOpacity(0.7)
        )),
      ],
    );
  }
}

class _DiaperItemCard extends StatelessWidget {
  final DiaperModel diaper;
  final dynamic repo;

  const _DiaperItemCard({required this.diaper, required this.repo});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;
    final theme = Theme.of(context);

    switch (diaper.status) {
      case 'Wet':
        statusColor = theme.colorScheme.primary;
        statusIcon = Icons.water_drop_outlined;
        break;
      case 'Dirty':
        statusColor = theme.colorScheme.tertiary;
        statusIcon = Icons.warning_amber_rounded;
        break;
      case 'Both':
        statusColor = theme.colorScheme.secondary;
        statusIcon = Icons.layers;
        break;
      default:
        statusColor = theme.colorScheme.onSurface;
        statusIcon = Icons.help_outline;
    }

    return Card(
      elevation: 2,
      shape: theme.cardTheme.shape,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(statusIcon, color: statusColor, size: 28),
        ),
        title: Text(
          diaper.status,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              DateFormat('hh:mm a').format(diaper.timestamp),
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)),
            ),
            if (diaper.notes != null) ...[
              const SizedBox(height: 4),
              Text(
                diaper.notes!,
                style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete_outline, color: theme.colorScheme.error.withOpacity(0.6)),
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete Entry?'),
                content: const Text('Are you sure you want to remove this log?'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                  TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                ],
              ),
            );

            if (confirm == true) {
              await repo.deleteDiaper(diaper.id);
            }
          },
        ),
      ),
    );
  }
}
