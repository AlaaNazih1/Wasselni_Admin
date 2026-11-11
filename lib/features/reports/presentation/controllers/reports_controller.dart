import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/reports_repository.dart';

final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
  return ReportsRepository();
});

final reportsOrdersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  final repository = ref.watch(reportsRepositoryProvider);

  return repository.getAllOrders();
});
