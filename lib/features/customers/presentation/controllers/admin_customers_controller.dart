import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/admin_customers_repository.dart';

final adminCustomersRepositoryProvider = Provider<AdminCustomersRepository>((
  ref,
) {
  return AdminCustomersRepository();
});

final adminCustomersProvider = StreamProvider<List<Map<String, dynamic>>>((
  ref,
) {
  final repository = ref.watch(adminCustomersRepositoryProvider);

  return repository.watchAllCustomers();
});

final customerOrdersProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((
      ref,
      customerId,
    ) {
      final repository = ref.watch(adminCustomersRepositoryProvider);

      return repository.getCustomerOrders(customerId);
    });
