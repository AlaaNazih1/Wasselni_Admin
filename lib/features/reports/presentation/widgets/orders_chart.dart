import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class OrdersChart extends StatelessWidget {
  final List<Map<String, dynamic>> orders;
  final String selectedPeriod;

  const OrdersChart({
    super.key,
    required this.orders,
    required this.selectedPeriod,
  });

  DateTime _getStartDate() {
    final now = DateTime.now();

    switch (selectedPeriod) {
      case 'today':
        return DateTime(now.year, now.month, now.day);

      case 'week':
        return DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(const Duration(days: 6));

      case 'month':
        return DateTime(now.year, now.month, 1);

      default:
        return DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(const Duration(days: 6));
    }
  }

  List<DateTime> _getChartDates(DateTime startDate) {
    final now = DateTime.now();

    final daysCount = selectedPeriod == 'today'
        ? 1
        : selectedPeriod == 'month'
        ? now.day
        : 7;

    return List.generate(
      daysCount,
      (index) => startDate.add(Duration(days: index)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final startDate = _getStartDate();
    final dates = _getChartDates(startDate);

    final orderCounts = List<int>.filled(dates.length, 0);

    for (final order in orders) {
      final createdAt = order['createdAt'];

      if (createdAt is! Timestamp) continue;

      final orderDate = createdAt.toDate();

      final index = dates.indexWhere(
        (date) =>
            date.year == orderDate.year &&
            date.month == orderDate.month &&
            date.day == orderDate.day,
      );

      if (index != -1) {
        orderCounts[index]++;
      }
    }

    final maxOrders = orderCounts.isEmpty
        ? 1
        : orderCounts.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'الطلبات خلال الفترة',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 280,
            child: BarChart(
              BarChartData(
                maxY: (maxOrders + 1).toDouble(),
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
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();

                        if (index < 0 || index >= dates.length) {
                          return const SizedBox.shrink();
                        }

                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '${dates[index].day}/${dates[index].month}',
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(orderCounts.length, (index) {
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: orderCounts[index].toDouble(),
                        width: 18,
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.blue,
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
