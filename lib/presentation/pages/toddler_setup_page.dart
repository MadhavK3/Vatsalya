import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:maternal_infant_care/presentation/viewmodels/auth_provider.dart';
import 'package:maternal_infant_care/presentation/pages/main_navigation_shell.dart';

class ToddlerSetupPage extends ConsumerStatefulWidget {
  const ToddlerSetupPage({super.key});

  @override
  ConsumerState<ToddlerSetupPage> createState() => _ToddlerSetupPageState();
}

class _ToddlerSetupPageState extends ConsumerState<ToddlerSetupPage> {
  DateTime? _babyBirthday;
  bool _isLoading = false;

  Future<void> _selectBirthday(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365)),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 3)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _babyBirthday = picked;
      });
    }
  }

  Future<void> _saveSetup() async {
    if (_babyBirthday == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your baby\'s birthday')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('DEBUG: Saving setup - birthday: ${_babyBirthday!.toIso8601String()}');
      final authService = ref.read(authServiceProvider);
      await authService.updateUserMetadata({
        'start_date': _babyBirthday!.toIso8601String(),
      });

      // Force refresh auth state to update metadata everywhere
      ref.invalidate(authStateProvider);
      await ref.read(authStateProvider.future); // Wait for refresh

      if (mounted) {
        print('DEBUG: Setup saved successfully, navigating to MainNavigationShell');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNavigationShell()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving setup: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Your Journey'),
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
                        Icons.child_care,
                        size: 72,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Welcome Parent!',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Tell us your baby\'s birthday to personalize your dashboard and activity ideas.',
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
              InkWell(
                onTap: () => _selectBirthday(context),
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Baby\'s Birthday',
                    prefixIcon: Icon(Icons.cake_outlined),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _babyBirthday == null
                        ? 'Select Date'
                        : DateFormat('MMMM dd, yyyy').format(_babyBirthday!),
                    style: TextStyle(
                      color: _babyBirthday == null
                          ? Theme.of(context).colorScheme.onSurfaceVariant
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              FilledButton(
                onPressed: _isLoading ? null : _saveSetup,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Complete Setup'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
