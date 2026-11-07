import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class RecentOrdersTable extends StatelessWidget {
  const RecentOrdersTable({super.key});

  static const List<Map<String, String>> _orders = [
    {
      'id': '#WS-1001',
      'customer': 'Ahmed Mohamed',
      'driver': 'Mohamed Ali',
      'price': '150 EGP',
      'status': 'تم التوصيل',
      'date': '07 Nov 2026',
    },
    {
      'id': '#WS-1002',
      'customer': 'Sara Ahmed',
      'driver': 'Omar Hassan',
      'price': '220 EGP',
      'status': 'جاري التوصيل',
      'date': '07 Nov 2026',
    },
    {
      'id': '#WS-1003',
      'customer': 'Mahmoud Ali',
      'driver': 'غير معين',
      'price': '100 EGP',
      'status': 'طلب جديد',
      'date': '06 Nov 2026',
    },
  ];

  Color _getStatusColor(String status) {
    switch (status) {
      case 'تم التوصيل':
        return AppColors.success;
      case 'جاري التوصيل':
        return AppColors.blue;
      default:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'أحدث الطلبات',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 20),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(AppColors.background),
              columns: const [
                DataColumn(label: Text('رقم الطلب')),
                DataColumn(label: Text('العميل')),
                DataColumn(label: Text('المندوب')),
                DataColumn(label: Text('القيمة')),
                DataColumn(label: Text('الحالة')),
                DataColumn(label: Text('التاريخ')),
              ],
              rows: _orders.map((order) {
                final status = order['status']!;

                return DataRow(
                  cells: [
                    DataCell(Text(order['id']!)),
                    DataCell(Text(order['customer']!)),
                    DataCell(Text(order['driver']!)),
                    DataCell(Text(order['price']!)),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            status,
                          ).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: _getStatusColor(status),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    DataCell(Text(order['date']!)),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
