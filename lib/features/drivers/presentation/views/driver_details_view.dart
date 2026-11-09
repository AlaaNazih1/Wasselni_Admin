import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasselni_admin/features/drivers/presentation/controllers/admin_drivers_controller.dart';
import 'package:wasselni_admin/features/orders/presentation/views/order_details_view.dart';
import '../../../../core/theme/app_colors.dart';

class DriverDetailsView extends ConsumerWidget {
  final Map<String, dynamic> driver;

  const DriverDetailsView({super.key, required this.driver});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = driver['name']?.toString() ?? 'بدون اسم';
    final phone = driver['phone']?.toString() ?? '-';
    final isActive = driver['isActive'] == true;
    final isApproved = driver['isApproved'] == true;
    final email = driver['email']?.toString() ?? '-';
    final driverId = driver['driverId']?.toString() ?? '';

    final ordersAsync = ref.watch(driverOrdersProvider(driverId));

    final createdAt = driver['createdAt'];
    final updatedAt = driver['updatedAt'];

    String formatDate(dynamic value) {
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 12),
              const Text(
                'تفاصيل المندوب',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                  ),

                  const SizedBox(width: 20),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          phone,
                          style: const TextStyle(
                            color: AppColors.grey,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'حالة الحساب',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      const Expanded(child: Text('النشاط')),
                      _buildStatusBadge(
                        isActive ? 'نشط' : 'غير نشط',
                        isActive ? AppColors.success : AppColors.grey,
                      ),
                    ],
                  ),

                  const Divider(height: 32),

                  Row(
                    children: [
                      const Expanded(child: Text('الموافقة')),
                      _buildStatusBadge(
                        isApproved ? 'تمت الموافقة' : 'تحت المراجعة',
                        isApproved ? AppColors.success : AppColors.warning,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'معلومات إضافية',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.black,
                            ),
                          ),

                          const SizedBox(height: 20),

                          _buildInfoRow(
                            Icons.email_outlined,
                            'البريد الإلكتروني',
                            email,
                          ),

                          const Divider(height: 28),

                          _buildInfoRow(
                            Icons.calendar_today_outlined,
                            'تاريخ التسجيل',
                            formatDate(createdAt),
                          ),

                          const Divider(height: 28),

                          _buildInfoRow(
                            Icons.update_outlined,
                            'آخر تحديث',
                            formatDate(updatedAt),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  ordersAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),

                    error: (error, stackTrace) {
                      debugPrint('Driver Orders Error: $error');

                      return const Center(
                        child: Text('حدث خطأ أثناء تحميل إحصائيات المندوب'),
                      );
                    },

                    data: (orders) {
                      final totalOrders = orders.length;

                      final deliveredOrders = orders
                          .where((order) => order['status'] == 'delivered')
                          .length;

                      final inProgressOrders = orders
                          .where((order) => order['status'] == 'inProgress')
                          .length;

                      final acceptedOrders = orders
                          .where((order) => order['status'] == 'accepted')
                          .length;

                      final cancelledOrders = orders
                          .where((order) => order['status'] == 'cancelled')
                          .length;
                      final recentOrders = [...orders]
                        ..sort((a, b) {
                          final dateA = a['createdAt'];
                          final dateB = b['createdAt'];

                          if (dateA is! Timestamp || dateB is! Timestamp) {
                            return 0;
                          }

                          return dateB.compareTo(dateA);
                        });

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'إحصائيات أداء المندوب',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.black,
                            ),
                          ),

                          const SizedBox(height: 16),

                          Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: [
                              _buildStatCard(
                                'إجمالي الطلبات',
                                totalOrders,
                                Icons.inventory_2_outlined,
                                AppColors.blue,
                              ),
                              _buildStatCard(
                                'طلبات مكتملة',
                                deliveredOrders,
                                Icons.check_circle_outline,
                                AppColors.success,
                              ),
                              _buildStatCard(
                                'جاري التوصيل',
                                inProgressOrders,
                                Icons.delivery_dining,
                                AppColors.blue,
                              ),
                              _buildStatCard(
                                'طلبات مقبولة',
                                acceptedOrders,
                                Icons.thumb_up_alt_outlined,
                                AppColors.warning,
                              ),
                              _buildStatCard(
                                'طلبات ملغاة',
                                cancelledOrders,
                                Icons.cancel_outlined,
                                AppColors.error,
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),

                          const Text(
                            'سجل طلبات المندوب',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.black,
                            ),
                          ),

                          const SizedBox(height: 16),

                          Card(
                            child: recentOrders.isEmpty
                                ? const Padding(
                                    padding: EdgeInsets.all(32),
                                    child: Center(
                                      child: Text(
                                        'لا توجد طلبات مسجلة لهذا المندوب',
                                        style: TextStyle(
                                          color: AppColors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  )
                                : SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: DataTable(
                                      headingRowColor: WidgetStateProperty.all(
                                        AppColors.background,
                                      ),
                                      columns: const [
                                        DataColumn(label: Text('رقم الطلب')),
                                        DataColumn(label: Text('الوجهة')),
                                        DataColumn(label: Text('قيمة الطلب')),
                                        DataColumn(label: Text('الحالة')),
                                        DataColumn(label: Text('التاريخ')),
                                      ],
                                      rows: recentOrders.map((order) {
                                        final orderNumber =
                                            order['orderNumber']?.toString() ??
                                            '-';

                                        final destination =
                                            order['to']?.toString() ?? '-';

                                        final totalPrice =
                                            order['totalPrice']?.toString() ??
                                            '0';

                                        final status =
                                            order['status']?.toString() ??
                                            'unknown';

                                        final createdAt = order['createdAt'];
                                        final date = createdAt is Timestamp
                                            ? createdAt.toDate()
                                            : null;

                                        final formattedDate = date == null
                                            ? '-'
                                            : '${date.day.toString().padLeft(2, '0')}/'
                                                  '${date.month.toString().padLeft(2, '0')}/'
                                                  '${date.year}';

                                        return DataRow(
                                          cells: [
                                            DataCell(
                                              InkWell(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          OrderDetailsView(
                                                            order: order,
                                                          ),
                                                    ),
                                                  );
                                                },
                                                child: Text(
                                                  '#$orderNumber',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.blue,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            DataCell(Text(destination)),
                                            DataCell(Text('$totalPrice ج.م')),
                                            DataCell(
                                              _buildOrderStatusBadge(status),
                                            ),
                                            DataCell(Text(formattedDate)),
                                          ],
                                        );
                                      }).toList(),
                                    ),
                                  ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStatusBadge(String status) {
    final statusInfo = {
      'delivered': ('تم التوصيل', AppColors.success),
      'inProgress': ('جاري التوصيل', AppColors.blue),
      'accepted': ('تم القبول', AppColors.warning),
      'pending': ('طلب جديد', AppColors.grey),
      'cancelled': ('ملغي', AppColors.error),
    };

    final info = statusInfo[status] ?? ('غير معروف', AppColors.grey);

    return _buildStatusBadge(info.$1, info.$2);
  }

  Widget _buildStatCard(String title, int value, IconData icon, Color color) {
    return Container(
      width: 190,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value.toString(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: AppColors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.grey, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 14, color: AppColors.grey),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}
