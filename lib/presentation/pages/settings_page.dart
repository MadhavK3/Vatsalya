import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maternal_infant_care/core/theme/app_theme.dart';
import 'package:maternal_infant_care/presentation/viewmodels/auth_provider.dart';
import 'package:maternal_infant_care/presentation/viewmodels/user_meta_provider.dart';
import 'package:maternal_infant_care/presentation/viewmodels/user_provider.dart';
import 'package:maternal_infant_care/core/utils/notification_service.dart';
import 'package:intl/intl.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _usernameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userMeta = ref.read(userMetaProvider);
      _usernameController.text = userMeta.username ?? '';
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _updateUsername() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(authServiceProvider).updateUserMetadata({
        'username': username,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating username: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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

  Future<void> _showChangePasswordDialog() async {
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool isObscure = true;

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: passwordController,
                obscureText: isObscure,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  suffixIcon: IconButton(
                    icon: Icon(isObscure ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setDialogState(() => isObscure = !isObscure),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                obscureText: isObscure,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final password = passwordController.text.trim();
                final confirmPassword = confirmPasswordController.text.trim();

                if (password.isEmpty || password.length < 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password must be at least 6 characters')),
                  );
                  return;
                }

                if (password != confirmPassword) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Passwords do not match')),
                  );
                  return;
                }

                try {
                  await ref.read(authServiceProvider).updatePassword(password);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password updated successfully')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleNotification(String key, bool currentValue) async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authServiceProvider).updateUserMetadata({
        key: !currentValue,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Notification settings updated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating notifications: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
          TextField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: 'Username',
              prefixIcon: const Icon(Icons.person_outline),
              suffixIcon: IconButton(
                icon: const Icon(Icons.check, color: Colors.green),
                onPressed: _isLoading ? null : _updateUsername,
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 32),
          _buildSectionHeader('Security'),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Change Password'),
            subtitle: const Text('Update your account password'),
            leading: Icon(Icons.lock_outline, color: Theme.of(context).colorScheme.primary),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _showChangePasswordDialog,
            tileColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
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
          _buildSectionHeader('Notifications'),
          const SizedBox(height: 16),
          _buildNotificationToggle(
            'Daily Tips', 
            userMeta.tipsEnabled, 
            (val) => _toggleNotification('tips_enabled', userMeta.tipsEnabled),
          ),
          const SizedBox(height: 12),
          _buildNotificationToggle(
            'Health Checkups', 
            userMeta.alertsEnabled, 
            (val) => _toggleNotification('alerts_enabled', userMeta.alertsEnabled),
          ),
          const SizedBox(height: 12),
          _buildNotificationToggle(
            'Important Alerts', 
            userMeta.remindersEnabled, 
            (val) => _toggleNotification('reminders_enabled', userMeta.remindersEnabled),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {
              NotificationService.showInstantNotification(
                id: 999,
                title: 'Test Notification',
                body: 'This is a test notification from your settings.',
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

  Widget _buildNotificationToggle(String title, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: _isLoading ? null : onChanged,
      dense: true,
      tileColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
