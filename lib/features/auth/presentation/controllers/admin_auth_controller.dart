import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../data/repositories/admin_auth_repository.dart';

final adminAuthRepositoryProvider = Provider<AdminAuthRepository>((ref) {
  return AdminAuthRepository();
});

final authStateChangesProvider = StreamProvider<User?>((ref) {
  final repository = ref.watch(adminAuthRepositoryProvider);

  return repository.authStateChanges();
});
