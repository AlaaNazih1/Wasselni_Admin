import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../controllers/admin_customers_controller.dart';

class CustomerDetailsView extends ConsumerWidget {
  final Map<String, dynamic> customer;

  const CustomerDetailsView({super.key, required this.customer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerId = customer['customerId']?.toString() ?? '';
    final ordersAsync = ref.watch(customerOrdersProvider(customerId));

    final name = customer['name']?.toString() ?? 'بدون اسم';
    final phone = customer['phone']?.toString() ?? '-';
    final email = customer['email']?.toString() ?? '-';

    final createdAt = customer['createdAt'];
    final registrationDate = createdAt is Timestamp
        ? _formatDate(createdAt.toDate())
        : '-';

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
              const SizedBox(width: 8),
              const Text(
                'تفاصيل العميل',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 24),

          _buildCustomerInfo(
            name: name,
            phone: phone,
            email: email,
            registrationDate: registrationDate,
          ),

          const SizedBox(height: 28),

          ordersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) =>
                Text('حدث خطأ أثناء تحميل الإحصائيات: $error'),
            data: (orders) => _buildOrderStats(orders),
          ),

          const SizedBox(height: 28),

          const Text(
            'سجل الطلبات',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          ordersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) =>
                Center(child: Text('حدث خطأ أثناء تحميل الطلبات: $error')),
            data: (orders) {
              if (orders.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('هذا العميل ليس لديه طلبات حتى الآن'),
                  ),
                );
              }

              return Column(
                children: orders.map((order) {
                  return _buildOrderCard(order);
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStats(List<Map<String, dynamic>> orders) {
    final completedOrders = orders
        .where((order) => order['status'] == 'delivered')
        .length;

    final totalSpent = orders.fold<double>(0, (total, order) {
      final price = order['totalPrice'];

      if (price is num) {
        return total + price.toDouble();
      }

      return total + (double.tryParse(price?.toString() ?? '0') ?? 0);
    });
    final cancelledOrders = orders
        .where((order) => order['status'] == 'cancelled')
        .length;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        final cardWidth = isWide
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
              title: 'إجمالي قيمة الطلبات',
              value: '${totalSpent.toStringAsFixed(2)} EGP',
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(fontSize: 13, color: AppColors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfo({
    required String name,
    required String phone,
    required String email,
    required String registrationDate,
  }) {
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
          Row(
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.background,
                child: Icon(
                  Icons.person_outline,
                  size: 32,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          _buildInfoRow(Icons.phone_outlined, 'رقم الهاتف', phone),
          _buildInfoRow(Icons.email_outlined, 'البريد الإلكتروني', email),
          _buildInfoRow(
            Icons.calendar_today_outlined,
            'تاريخ التسجيل',
            registrationDate,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: AppColors.grey, size: 20),
          const SizedBox(width: 12),
          Text('$title:', style: const TextStyle(color: AppColors.grey)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final orderNumber = order['orderNumber']?.toString() ?? '-';
    final status = order['status']?.toString() ?? 'unknown';
    final orderType = order['orderType'];
    final totalPrice = order['totalPrice']?.toString() ?? '0';

    final createdAt = order['createdAt'];
    final orderDate = createdAt is Timestamp
        ? _formatDate(createdAt.toDate())
        : '-';

    final from = order['from']?.toString() ?? '-';
    final to = order['to']?.toString() ?? '-';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'طلب #$orderNumber',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              _buildStatusBadge(status),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            orderType == 1 ? 'توصيل فقط' : 'استلام وتوصيل',
            style: const TextStyle(color: AppColors.grey),
          ),
          const SizedBox(height: 8),
          Text('من: $from'),
          const SizedBox(height: 6),
          Text('إلى: $to'),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(orderDate, style: const TextStyle(color: AppColors.grey)),
              Text(
                '$totalPrice EGP',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;

    switch (status) {
      case 'delivered':
        color = Colors.green;
        label = 'تم التوصيل';
        break;
      case 'inProgress':
        color = Colors.blue;
        label = 'جاري التوصيل';
        break;
      case 'accepted':
        color = Colors.orange;
        label = 'تم القبول';
        break;
      case 'pending':
        color = Colors.grey;
        label = 'قيد الانتظار';
        break;
      case 'cancelled':
        color = Colors.red;
        label = 'ملغي';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
