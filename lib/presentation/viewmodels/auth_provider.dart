import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maternal_infant_care/domain/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.asData?.value.session?.user;
});
