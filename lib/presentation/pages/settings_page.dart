import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maternal_infant_care/core/theme/app_theme.dart';
import 'package:maternal_infant_care/presentation/viewmodels/auth_provider.dart';
import 'package:maternal_infant_care/presentation/viewmodels/user_meta_provider.dart';
import 'package:maternal_infant_care/presentation/viewmodels/user_provider.dart';
import 'package:intl/intl.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  // No username controller anymore
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // No username initialization needed
    });
  }

  @override
  void dispose() {
    // _usernameController.dispose(); removed
    super.dispose();
  }

  // _updateUsername removed

  Future<void> _updateStartDate() async {
    final userMeta = ref.read(userMetaProvider);
    final isPregnancy = userMeta.role == UserProfileType.pregnant;

    final picked = await showDatePicker(
      context: context,
      initialDate: userMeta.startDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 3)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => _isLoading = true);
      try {
        await ref.read(authServiceProvider).updateUserMetadata({
          'start_date': picked.toIso8601String(),
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${isPregnancy ? "Last Period Date" : "Baby Birthday"} updated')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating date: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final userMeta = ref.watch(userMetaProvider);
    final isPregnancy = userMeta.role == UserProfileType.pregnant;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSectionHeader('Account'),
          const SizedBox(height: 16),
          // Username field removed
          const SizedBox(height: 32),
          _buildSectionHeader('My Journey'),
          const SizedBox(height: 16),
          ListTile(
            title: Text(isPregnancy ? 'Last Period Date' : 'Baby Birthday'),
            subtitle: Text(userMeta.startDate != null ? DateFormat('MMMM dd, yyyy').format(userMeta.startDate!) : 'Not set'),
            leading: Icon(isPregnancy ? Icons.pregnant_woman : Icons.child_care, color: Theme.of(context).colorScheme.primary),
            trailing: const Icon(Icons.edit_outlined, size: 20),
            onTap: _updateStartDate,
            tileColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          const SizedBox(height: 32),
          _buildSectionHeader('Appearance'),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Dark Mode'),
            secondary: Icon(themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode, color: Theme.of(context).colorScheme.primary),
            value: themeMode == ThemeMode.dark,
            onChanged: (val) => ref.read(themeModeProvider.notifier).toggleTheme(),
            tileColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          const SizedBox(height: 32),
          _buildSectionHeader('Notifications'),
          const SizedBox(height: 16),
          _buildNotificationToggle('Daily Tips', true),
          const SizedBox(height: 12),
          _buildNotificationToggle('Health Checkups', true),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Test notification sent!')),
              );
            },
            icon: const Icon(Icons.notification_important_outlined),
            label: const Text('Test Notification'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
    );
  }

  Widget _buildNotificationToggle(String title, bool value) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: (val) {},
      dense: true,
      tileColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
