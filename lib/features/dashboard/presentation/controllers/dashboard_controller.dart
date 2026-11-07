import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/dashboard_repository.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository();
});

final totalOrdersProvider = StreamProvider<int>((ref) {
  return ref.watch(dashboardRepositoryProvider).watchTotalOrders();
});

final totalCustomersProvider = StreamProvider<int>((ref) {
  return ref.watch(dashboardRepositoryProvider).watchTotalCustomers();
});

final totalDriversProvider = StreamProvider<int>((ref) {
  return ref.watch(dashboardRepositoryProvider).watchTotalDrivers();
});

final completedOrdersProvider = StreamProvider<int>((ref) {
  return ref.watch(dashboardRepositoryProvider).watchCompletedOrders();
});
