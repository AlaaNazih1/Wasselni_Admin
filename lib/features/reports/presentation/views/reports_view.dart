import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasselni_admin/features/reports/presentation/controllers/reports_controller.dart';
import 'package:wasselni_admin/features/reports/presentation/widgets/orders_chart.dart';
import 'package:wasselni_admin/features/reports/presentation/widgets/report_period_filter.dart';
import 'package:wasselni_admin/features/reports/presentation/widgets/report_stats_section.dart';

import '../../../../core/theme/app_colors.dart';

class ReportsView extends ConsumerStatefulWidget {
  const ReportsView({super.key});

  @override
  ConsumerState<ReportsView> createState() => _ReportsViewState();
}

class _ReportsViewState extends ConsumerState<ReportsView> {
  String _selectedPeriod = 'all';

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(reportsOrdersProvider);

    List<Map<String, dynamic>> _filterOrders(
      List<Map<String, dynamic>> orders,
    ) {
      final now = DateTime.now();

      DateTime? startDate;

      switch (_selectedPeriod) {
        case 'today':
          startDate = DateTime(now.year, now.month, now.day);
          break;

        case 'week':
          startDate = DateTime(
            now.year,
            now.month,
            now.day,
          ).subtract(const Duration(days: 6));
          break;

        case 'month':
          startDate = DateTime(now.year, now.month, 1);
          break;

        case 'all':
          return orders;
      }

      return orders.where((order) {
        final createdAt = order['createdAt'];

        if (createdAt is! Timestamp) return false;

        final orderDate = createdAt.toDate();

        return !orderDate.isBefore(startDate!) && !orderDate.isAfter(now);
      }).toList();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'تقارير Wasselni',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'تابع أداء الطلبات والإيرادات والمندوبين.',
            style: TextStyle(fontSize: 14, color: AppColors.grey),
          ),
          const SizedBox(height: 28),

          ordersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) =>
                Center(child: Text('حدث خطأ أثناء تحميل التقارير: $error')),
            data: (orders) {
              final filteredOrders = _filterOrders(orders);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ReportPeriodFilter(
                    selectedPeriod: _selectedPeriod,
                    onChanged: (value) {
                      setState(() {
                        _selectedPeriod = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  _buildReportsContent(filteredOrders),

                  const SizedBox(height: 28),

                  OrdersChart(
                    orders: filteredOrders,
                    selectedPeriod: _selectedPeriod,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReportsContent(List<Map<String, dynamic>> orders) {
    final completedOrders = orders
        .where((order) => order['status'] == 'delivered')
        .length;

    final cancelledOrders = orders
        .where((order) => order['status'] == 'cancelled')
        .length;

    final totalRevenue = orders.fold<double>(0, (total, order) {
      if (order['status'] != 'delivered') return total;

      final price = order['totalPrice'];

      if (price is num) {
        return total + price.toDouble();
      }

      return total + (double.tryParse(price?.toString() ?? '0') ?? 0);
    });

    return ReportStatsSection(
      totalOrders: orders.length,
      completedOrders: completedOrders,
      cancelledOrders: cancelledOrders,
      totalRevenue: totalRevenue,
    );
  }
}
