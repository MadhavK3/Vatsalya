import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maternal_infant_care/data/models/pregnancy_model.dart';
import 'package:maternal_infant_care/presentation/viewmodels/repository_providers.dart';

class PregnancyChecklistWidget extends ConsumerStatefulWidget {
  final PregnancyModel pregnancy;

  const PregnancyChecklistWidget({super.key, required this.pregnancy});

  @override
  ConsumerState<PregnancyChecklistWidget> createState() => _PregnancyChecklistWidgetState();
}

class _PregnancyChecklistWidgetState extends ConsumerState<PregnancyChecklistWidget> {
  late Map<int, bool> checklists;

  @override
  void initState() {
    super.initState();
    checklists = Map.from(widget.pregnancy.monthlyChecklists);
  }

  Future<void> _toggleChecklist(int month, int itemIndex) async {
    final key = '$month-$itemIndex';
    final intKey = key.hashCode;
    setState(() {
      checklists[intKey] = !(checklists[intKey] ?? false);
    });

    try {
      final repo = await ref.read(pregnancyRepositoryProvider.future);
      final updated = widget.pregnancy.copyWith(
        monthlyChecklists: checklists,
      );
      await repo.savePregnancy(updated);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating checklist: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentMonth = widget.pregnancy.currentMonth;
    final checklistItems = _getChecklistItems(currentMonth);

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: checklistItems.length,
      itemBuilder: (context, index) {
        final key = '$currentMonth-$index';
        final intKey = key.hashCode;
        final isChecked = checklists[intKey] ?? false;
        final subtitle = _getChecklistSubtitle(currentMonth, index);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: CheckboxListTile(
            value: isChecked,
            onChanged: (value) => _toggleChecklist(currentMonth, index),
            title: Text(checklistItems[index]),
            subtitle: subtitle != null ? Text(subtitle) : null,
            secondary: Icon(
              isChecked ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isChecked ? Colors.green : Theme.of(context).colorScheme.primary,
            ),
          ),
        );
      },
    );
  }

  List<String> _getChecklistItems(int month) {
    final items = <int, List<String>>{
      1: [
        'Start taking folic acid supplements',
        'Schedule first prenatal appointment',
        'Avoid alcohol and smoking',
        'Eat balanced meals',
      ],
      2: [
        'Attend first prenatal appointment',
        'Continue folic acid',
        'Stay hydrated',
        'Get adequate rest',
      ],
      3: [
        'Continue prenatal vitamins',
        'Eat small, frequent meals',
        'Stay active with light exercise',
        'Track weight gain',
      ],
      4: [
        'Schedule anatomy scan',
        'Increase iron intake',
        'Continue regular check-ups',
        'Start wearing maternity clothes',
      ],
      5: [
        'Feel baby\'s first movements',
        'Continue balanced diet',
        'Stay hydrated',
        'Practice relaxation techniques',
      ],
      6: [
        'Continue regular check-ups',
        'Eat small, frequent meals',
        'Monitor blood pressure',
        'Stay active',
      ],
      7: [
        'Prepare birth plan',
        'Attend childbirth classes',
        'Continue regular check-ups',
        'Maintain good posture',
      ],
      8: [
        'Pack hospital bag',
        'Finalize birth plan',
        'Continue check-ups',
        'Practice breathing exercises',
      ],
      9: [
        'Watch for labor signs',
        'Final preparations',
        'Last prenatal check-up',
        'Prepare for baby\'s arrival',
      ],
    };

    return items[month] ?? [];
  }

  String? _getChecklistSubtitle(int month, int index) {
    final subtitles = <int, Map<int, String>>{
      1: {
        0: 'Take 400-800 mcg daily',
        1: 'Book within first 8 weeks',
      },
      3: {
        0: 'Essential for baby\'s development',
      },
    };

    return subtitles[month]?[index];
  }
}
