import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasselni_admin/features/dashboard/presentation/controllers/dashboard_controller.dart';

import '../../../../core/theme/app_colors.dart';
import 'dashboard_stat_card.dart';

class DashboardStatsSection extends ConsumerWidget {
  const DashboardStatsSection({super.key});

 @override
Widget build(BuildContext context, WidgetRef ref) {
  final orders = ref.watch(totalOrdersProvider);
  final customers = ref.watch(totalCustomersProvider);
  final drivers = ref.watch(totalDriversProvider);
  final completed = ref.watch(completedOrdersProvider);

  return LayoutBuilder(
    builder: (context, constraints) {
      final crossAxisCount = constraints.maxWidth >= 1100
          ? 4
          : constraints.maxWidth >= 650
              ? 2
              : 1;

      return GridView.count(
        crossAxisCount: crossAxisCount,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: crossAxisCount == 1
            ? 2.2
            : crossAxisCount == 2
                ? 1.5
                : 1.25,
        children: [
          DashboardStatCard(
            title: 'إجمالي الطلبات',
            value: orders.when(
              data: (value) => value.toString(),
              loading: () => '...',
              error: (_, __) => 'خطأ',
            ),
            icon: Icons.shopping_bag_rounded,
            iconColor: AppColors.blue,
            subtitle: 'جميع الطلبات المسجلة',
          ),
          DashboardStatCard(
            title: 'إجمالي العملاء',
            value: customers.when(
              data: (value) => value.toString(),
              loading: () => '...',
              error: (_, __) => 'خطأ',
            ),
            icon: Icons.people_alt_rounded,
            iconColor: AppColors.success,
            subtitle: 'جميع حسابات العملاء',
          ),
          DashboardStatCard(
            title: 'إجمالي المندوبين',
            value: drivers.when(
              data: (value) => value.toString(),
              loading: () => '...',
              error: (_, __) => 'خطأ',
            ),
            icon: Icons.delivery_dining_rounded,
            iconColor: AppColors.warning,
            subtitle: 'جميع حسابات المندوبين',
          ),
          DashboardStatCard(
            title: 'الطلبات المكتملة',
            value: completed.when(
              data: (value) => value.toString(),
              loading: () => '...',
              error: (_, __) => 'خطأ',
            ),
            icon: Icons.check_circle_rounded,
            iconColor: AppColors.success,
            subtitle: 'الطلبات التي تم توصيلها',
          ),
        ],
      );
    },
  );
}
}