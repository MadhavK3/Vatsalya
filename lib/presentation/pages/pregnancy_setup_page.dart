import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maternal_infant_care/core/theme/app_theme.dart';
import 'package:maternal_infant_care/data/models/pregnancy_model.dart';
import 'package:maternal_infant_care/presentation/viewmodels/repository_providers.dart';
import 'package:maternal_infant_care/presentation/viewmodels/auth_provider.dart';
import 'package:maternal_infant_care/presentation/pages/main_navigation_shell.dart';

class PregnancySetupPage extends ConsumerStatefulWidget {
  const PregnancySetupPage({super.key});

  @override
  ConsumerState<PregnancySetupPage> createState() => _PregnancySetupPageState();
}

class _PregnancySetupPageState extends ConsumerState<PregnancySetupPage> {
  DateTime? _lastPeriodDate;
  DateTime? _dueDate;

  Future<void> _selectLastPeriodDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 90)),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _lastPeriodDate = picked;
        _dueDate = picked.add(const Duration(days: 280));
      });
    }
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 190)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
        if (_lastPeriodDate == null) {
          _lastPeriodDate = picked.subtract(const Duration(days: 280));
        }
      });
    }
  }

  Future<void> _savePregnancy() async {
    if (_lastPeriodDate == null || _dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both dates')),
      );
      return;
    }

    try {
      final repo = await ref.read(pregnancyRepositoryProvider.future);
      
      try {
        final existing = repo.getPregnancy();
        if (existing != null) {
          await repo.clearAll();
        }
      } catch (e) {
        await repo.clearAll();
      }
      
      final lastPeriodDate = DateTime.utc(
        _lastPeriodDate!.year,
        _lastPeriodDate!.month,
        _lastPeriodDate!.day,
      );
      final dueDate = DateTime.utc(
        _dueDate!.year,
        _dueDate!.month,
        _dueDate!.day,
      );
      
      final now = DateTime.now();
      final weeksSinceLastPeriod = now.difference(lastPeriodDate).inDays ~/ 7;
      final currentMonth = ((weeksSinceLastPeriod / 4.33).floor()).clamp(1, 9);

      final pregnancy = PregnancyModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        lastPeriodDate: lastPeriodDate,
        dueDate: dueDate,
        currentMonth: currentMonth,
        monthlyChecklists: {},
        completedTests: [],
        riskSymptoms: [],
      );

      await repo.savePregnancy(pregnancy);

      // Save start_date to Supabase User Metadata
      print('DEBUG: Saving pregnancy setup - lastPeriodDate: ${lastPeriodDate.toIso8601String()}');
      final authService = ref.read(authServiceProvider);
      await authService.updateUserMetadata({
        'start_date': lastPeriodDate.toIso8601String(),
      });

      // Force refresh auth state
      ref.invalidate(authStateProvider);
      await ref.read(authStateProvider.future);

      if (mounted) {
        print('DEBUG: Pregnancy setup saved successfully, navigating to MainNavigationShell');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNavigationShell()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pregnancy Setup'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.pregnant_woman,
                          size: 72,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Setup Your Journey',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Provide your details to customize your pregnancy tracking experience.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                _DateInputField(
                  label: 'Last Menstrual Period Date',
                  value: _lastPeriodDate,
                  onTap: () => _selectLastPeriodDate(context),
                  icon: Icons.calendar_today,
                ),
                const SizedBox(height: 24),
                _DateInputField(
                  label: 'Estimated Due Date',
                  value: _dueDate,
                  onTap: () => _selectDueDate(context),
                  icon: Icons.event,
                ),
                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: _savePregnancy,
                  child: const Text('Complete Setup'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateInputField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;
  final IconData icon;

  const _DateInputField({
    required this.label,
    required this.value,
    required this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ),
        child: Text(
          value != null ? DateFormat('MMMM dd, yyyy').format(value!) : 'Select date',
          style: TextStyle(
            fontSize: 16,
            color: value != null 
              ? Theme.of(context).colorScheme.onSurface 
              : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
          ),
        ),
      ),
    );
  }
}
