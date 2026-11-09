import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/admin_drivers_repository.dart';

final adminDriversRepositoryProvider = Provider<AdminDriversRepository>((ref) {
  return AdminDriversRepository();
});

final adminDriversProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final repository = ref.watch(adminDriversRepositoryProvider);

  return repository.watchAllDrivers();
});
