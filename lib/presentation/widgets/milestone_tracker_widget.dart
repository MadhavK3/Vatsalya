import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maternal_infant_care/presentation/viewmodels/repository_providers.dart';
import 'package:maternal_infant_care/data/models/milestone_model.dart';
import 'package:maternal_infant_care/presentation/pages/milestones_page.dart';

class MilestoneTrackerWidget extends ConsumerWidget {
  const MilestoneTrackerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final milestoneRepo = ref.watch(milestoneRepositoryProvider);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.star_rounded, color: Colors.amber),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Milestones',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const MilestonesPage()));
                  },
                  child: const Text('See All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            milestoneRepo.when(
              data: (repo) {
                final milestones = repo.getAllMilestones();
                final completedCount = milestones.where((m) => m.isCompleted).length;
                final totalCount = milestones.length;
                final progress = totalCount > 0 ? completedCount / totalCount : 0.0;
                
                // Sort by: Incomplete first, then by age
                milestones.sort((a,b) {
                   if (a.isCompleted != b.isCompleted) {
                     return a.isCompleted ? 1 : -1;
                   }
                   return a.ageMonthsMin.compareTo(b.ageMonthsMin);
                });
                
                final nextMilestones = milestones.take(3).toList();

                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('$completedCount/$totalCount achieved'),
                        Text('${(progress * 100).toInt()}%'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress,
                      color: Colors.amber,
                      backgroundColor: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 16),
                    ...nextMilestones.map((m) => _MilestoneCheckbox(
                      milestone: m,
                      onChanged: (val) {
                         // Update repo
                         repo.toggleCompletion(m.id, val!);
                         // Force UI update
                         // In a real app we'd use streams, but here we trigger refresh
                         // Note: This refreshes the *provider*, so any other watchers (like MilestonesPage) update too.
                         ref.refresh(milestoneRepositoryProvider);
                      },
                    )),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Text('Error: $e'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MilestoneCheckbox extends StatelessWidget {
  final MilestoneModel milestone;
  final ValueChanged<bool?> onChanged;

  const _MilestoneCheckbox({required this.milestone, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: milestone.isCompleted,
      onChanged: onChanged,
      title: Text(
        milestone.title,
        style: TextStyle(
          decoration: milestone.isCompleted ? TextDecoration.lineThrough : null,
          color: milestone.isCompleted ? Colors.grey : null,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        '${milestone.ageMonthsMin}-${milestone.ageMonthsMax} months',
        style: const TextStyle(fontSize: 12),
      ),
      dense: true,
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: Colors.amber,
    );
  }
}
