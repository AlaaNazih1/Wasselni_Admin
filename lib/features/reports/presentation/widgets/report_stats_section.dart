import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'report_stat_card.dart';

class ReportStatsSection extends StatelessWidget {
  final int totalOrders;
  final int completedOrders;
  final int cancelledOrders;
  final double totalRevenue;

  const ReportStatsSection({
    super.key,
    required this.totalOrders,
    required this.completedOrders,
    required this.cancelledOrders,
    required this.totalRevenue,
  });

  @override
  Widget build(BuildContext context) {
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
            ReportStatCard(
              title: 'إجمالي الطلبات',
              value: totalOrders.toString(),
              icon: Icons.receipt_long_outlined,
              color: AppColors.primary,
              width: cardWidth,
            ),
            ReportStatCard(
              title: 'الطلبات المكتملة',
              value: completedOrders.toString(),
              icon: Icons.check_circle_outline,
              color: Colors.green,
              width: cardWidth,
            ),
            ReportStatCard(
              title: 'الطلبات الملغية',
              value: cancelledOrders.toString(),
              icon: Icons.cancel_outlined,
              color: Colors.red,
              width: cardWidth,
            ),
            ReportStatCard(
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
}
