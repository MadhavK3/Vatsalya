import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maternal_infant_care/presentation/viewmodels/auth_provider.dart';
import 'package:maternal_infant_care/presentation/viewmodels/user_provider.dart';

class UserMeta {
  final UserProfileType? role;
  final DateTime? startDate;

  UserMeta({this.role, this.startDate});

  factory UserMeta.fromMetadata(Map<String, dynamic>? metadata) {
    if (metadata == null) return UserMeta();
    
    final roleStr = metadata['role'] as String?;
    final role = roleStr == 'pregnant' 
        ? UserProfileType.pregnant 
        : (roleStr == 'parent' || roleStr == 'toddler_parent' ? UserProfileType.toddlerParent : null);
    
    final startDateStr = metadata['start_date'] as String?;
    final startDate = startDateStr != null ? DateTime.tryParse(startDateStr) : null;

    return UserMeta(
      role: role,
      startDate: startDate,
    );
  }
}

final userMetaProvider = Provider<UserMeta>((ref) {
  final user = ref.watch(currentUserProvider);
  
  if (user == null) return UserMeta();
  
  return UserMeta.fromMetadata(user.userMetadata);
});
