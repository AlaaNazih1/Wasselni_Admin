import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/admin_orders_repository.dart';

final adminOrdersRepositoryProvider = Provider<AdminOrdersRepository>((ref) {
  return AdminOrdersRepository();
});

final adminOrdersProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final repository = ref.watch(adminOrdersRepositoryProvider);

  return repository.watchAllOrders();
});
