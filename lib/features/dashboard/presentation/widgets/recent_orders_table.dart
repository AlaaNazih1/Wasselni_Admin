import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:wasselni_admin/features/orders/presentation/controllers/admin_orders_controller.dart';

import '../../../../core/theme/app_colors.dart';

class RecentOrdersTable extends ConsumerWidget {
  const RecentOrdersTable({super.key});

  String _getStatus(String? status) {
    switch (status) {
      case 'delivered':
        return 'تم التوصيل';
      case 'inProgress':
        return 'جاري التوصيل';
      case 'accepted':
        return 'تم قبول الطلب';
      case 'pending':
        return 'طلب جديد';
      case 'cancelled':
        return 'ملغي';
      default:
        return status ?? 'غير معروف';
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'delivered':
        return AppColors.success;
      case 'inProgress':
        return AppColors.blue;
      case 'accepted':
        return AppColors.warning;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.grey;
    }
  }

  String _formatDate(dynamic value) {
    if (value == null) return '-';

    DateTime? date;

    if (value is Timestamp) {
      date = value.toDate();
    } else if (value is DateTime) {
      date = value;
    }

    if (date == null) return '-';

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatLocation(dynamic value) {
    if (value == null) return '-';

    if (value is String) return value;

    if (value is Map) {
      return value['address']?.toString() ?? value['name']?.toString() ?? '-';
    }

    return value.toString();
  }

  String _formatPrice(dynamic value) {
    if (value == null) return '0 EGP';

    if (value is num) {
      return '${value.toStringAsFixed(0)} EGP';
    }

    return '$value EGP';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(adminOrdersProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'أحدث الطلبات',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            ordersAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stackTrace) {
                debugPrint('Error loading orders: $error\n$stackTrace');

                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('حدث خطأ أثناء تحميل الطلبات'),
                  ),
                );
              },
              data: (orders) {
                if (orders.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: Text('لا توجد طلبات حتى الآن'),
                    ),
                  );
                }

                final recentOrders = orders.take(5).toList();

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                      AppColors.background,
                    ),
                    columns: const [
                      DataColumn(label: Text('رقم الطلب')),
                      DataColumn(label: Text('العميل')),
                      DataColumn(label: Text('المندوب')),
                      DataColumn(label: Text('من')),
                      DataColumn(label: Text('إلى')),
                      DataColumn(label: Text('السعر')),
                      DataColumn(label: Text('الحالة')),
                      DataColumn(label: Text('التاريخ')),
                    ],
                    rows: recentOrders.map((order) {
                      final status = order['status']?.toString();

                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              order['orderNumber']?.toString() ??
                                  order['orderId']?.toString() ??
                                  '-',
                            ),
                          ),
                          DataCell(
                            Text(
                              order['customerName']?.toString() ??
                                  'عميل غير معروف',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(order['driverName']?.toString() ?? 'غير معين'),
                          ),
                          DataCell(Text(_formatLocation(order['from']))),
                          DataCell(Text(_formatLocation(order['to']))),
                          DataCell(Text(_formatPrice(order['totalPrice']))),
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
                                _getStatus(status),
                                style: TextStyle(
                                  color: _getStatusColor(status),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          DataCell(Text(_formatDate(order['createdAt']))),
                        ],
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
