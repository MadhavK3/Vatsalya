import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maternal_infant_care/presentation/viewmodels/auth_provider.dart';
import 'package:maternal_infant_care/presentation/viewmodels/user_provider.dart';

class UserMeta {
  final UserProfileType? role;
  final DateTime? startDate;
  final String? username;
  final bool tipsEnabled;
  final bool alertsEnabled;
  final bool remindersEnabled;

  UserMeta({
    this.role, 
    this.startDate, 
    this.username, 
    this.tipsEnabled = true, 
    this.alertsEnabled = true,
    this.remindersEnabled = true,
  });

  factory UserMeta.fromMetadata(Map<String, dynamic>? metadata) {
    if (metadata == null) return UserMeta();
    
    final roleStr = metadata['role'] as String?;
    final role = roleStr == 'pregnant' 
        ? UserProfileType.pregnant 
        : (roleStr == 'parent' || roleStr == 'toddler_parent' ? UserProfileType.toddlerParent : null);
    
    final startDateStr = metadata['start_date'] as String?;
    final startDate = startDateStr != null ? DateTime.tryParse(startDateStr) : null;
    final username = metadata['username'] as String?;
    
    // Explicitly check for false, default to true if null or not present
    final tipsEnabled = metadata['tips_enabled'] != false;
    final alertsEnabled = metadata['alerts_enabled'] != false;
    final remindersEnabled = metadata['reminders_enabled'] != false;

    return UserMeta(
      role: role,
      startDate: startDate,
      username: username,
      tipsEnabled: tipsEnabled,
      alertsEnabled: alertsEnabled,
      remindersEnabled: remindersEnabled,
    );
  }
}

final userMetaProvider = Provider<UserMeta>((ref) {
  final user = ref.watch(currentUserProvider);
  
  if (user == null) return UserMeta();
  
  return UserMeta.fromMetadata(user.userMetadata);
});
