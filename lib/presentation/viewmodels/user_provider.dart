import 'package:flutter_riverpod/flutter_riverpod.dart';

enum UserProfileType { pregnant, toddlerParent }

final userProfileProvider = StateProvider<UserProfileType?>((ref) => null);
