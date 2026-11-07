import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasselni_admin/features/orders/presentation/controllers/admin_orders_controller.dart';

import '../../../../core/theme/app_colors.dart';

class RecentOrdersTable extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(adminOrdersProvider);

    return ordersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) {

        debugPrint('Error loading orders: $error\n$stackTrace');
        return const Center(child: Text('حدث خطأ أثناء تحميل الطلبات'));
      },
      data: (orders) {
        // هنضع هنا تصميم الجدول في الخطوة التالية.
        return Text('عدد الطلبات: ${orders.length}');
      },
    );
  }
}
