import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/admin_drivers_repository.dart';

final adminDriversRepositoryProvider = Provider<AdminDriversRepository>((ref) {
  return AdminDriversRepository();
});

final adminDriversProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final repository = ref.watch(adminDriversRepositoryProvider);

  return repository.watchAllDrivers();
});
final driverOrdersProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((
      ref,
      driverId,
    ) async {
      final repository = ref.watch(adminDriversRepositoryProvider);

      return repository.getDriverOrders(driverId);
    });

final driverActionsProvider = Provider((ref) {
  final repository = ref.watch(adminDriversRepositoryProvider);

  return DriverActionsController(repository);
});

class DriverActionsController {
  final AdminDriversRepository _repository;

  DriverActionsController(this._repository);

  Future<void> approveDriver(String driverId) {
    return _repository.approveDriver(driverId);
  }

  Future<void> activateDriver(String driverId) {
    return _repository.activateDriver(driverId);
  }

  Future<void> deactivateDriver(String driverId) {
    return _repository.deactivateDriver(driverId);
  }
}
