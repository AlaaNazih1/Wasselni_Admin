import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasselni_admin/features/reports/presentation/controllers/reports_controller.dart';

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
    Widget _buildPeriodFilter() {
      return Align(
        alignment: Alignment.centerRight,
        child: SizedBox(
          width: 220,
          child: DropdownButtonFormField<String>(
            value: _selectedPeriod,
            decoration: InputDecoration(
              labelText: 'الفترة الزمنية',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'today', child: Text('اليوم')),
              DropdownMenuItem(value: 'week', child: Text('آخر 7 أيام')),
              DropdownMenuItem(value: 'month', child: Text('الشهر الحالي')),
              DropdownMenuItem(value: 'all', child: Text('كل الوقت')),
            ],
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                _selectedPeriod = value;
              });
            },
          ),
        ),
      );
    }

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
                  _buildPeriodFilter(),
                  const SizedBox(height: 24),

                  _buildReportsContent(filteredOrders),

                  const SizedBox(height: 28),

                  _buildOrdersChart(filteredOrders),
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth >= 1100
            ? (constraints.maxWidth - 48) / 4
            : constraints.maxWidth >= 600
            ? (constraints.maxWidth - 16) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildStatCard(
              title: 'إجمالي الطلبات',
              value: orders.length.toString(),
              icon: Icons.receipt_long_outlined,
              color: AppColors.primary,
              width: cardWidth,
            ),
            _buildStatCard(
              title: 'الطلبات المكتملة',
              value: completedOrders.toString(),
              icon: Icons.check_circle_outline,
              color: Colors.green,
              width: cardWidth,
            ),
            _buildStatCard(
              title: 'الطلبات الملغية',
              value: cancelledOrders.toString(),
              icon: Icons.cancel_outlined,
              color: Colors.red,
              width: cardWidth,
            ),
            _buildStatCard(
              title: 'إجمالي الإيرادات',
              value: '${totalRevenue.toStringAsFixed(2)} EGP',
              icon: Icons.payments_outlined,
              color: Colors.blue,
              width: cardWidth,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required double width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 14, color: AppColors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersChart(List<Map<String, dynamic>> orders) {
    final now = DateTime.now();

    final days = _selectedPeriod == 'today'
        ? 1
        : _selectedPeriod == 'week'
        ? 7
        : _selectedPeriod == 'month'
        ? DateTime(now.year, now.month + 1, 0).day
        : 7;

    final startDate = _selectedPeriod == 'today'
        ? DateTime(now.year, now.month, now.day)
        : _selectedPeriod == 'month'
        ? DateTime(now.year, now.month, 1)
        : _selectedPeriod == 'week'
        ? DateTime(
            now.year,
            now.month,
            now.day,
          ).subtract(const Duration(days: 6))
        : DateTime(
            now.year,
            now.month,
            now.day,
          ).subtract(const Duration(days: 6));

    final dailyCounts = List<int>.filled(days, 0);

    for (final order in orders) {
      final createdAt = order['createdAt'];

      if (createdAt is! Timestamp) continue;

      final date = createdAt.toDate();

      final index = date.difference(startDate).inDays;

      if (index >= 0 && index < days) {
        dailyCounts[index]++;
      }
    }

    final maxCount = dailyCounts.isEmpty
        ? 1
        : dailyCounts.reduce((a, b) => a > b ? a : b);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'حركة الطلبات',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 280,
            child: BarChart(
              BarChartData(
                maxY: (maxCount + 1).toDouble(),
                alignment: BarChartAlignment.spaceAround,
                gridData: const FlGridData(show: true),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 35),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 35,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();

                        if (index < 0 || index >= days) {
                          return const SizedBox.shrink();
                        }

                        final date = startDate.add(Duration(days: index));

                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '${date.day}/${date.month}',
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(days, (index) {
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: dailyCounts[index].toDouble(),
                        color: AppColors.primary,
                        width: 14,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
