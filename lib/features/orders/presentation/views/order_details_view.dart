import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class OrderDetailsView extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderDetailsView({super.key, required this.order});

  String get orderNumber =>
      order['orderNumber']?.toString() ?? order['orderId']?.toString() ?? '-';

  String get status => order['status']?.toString() ?? 'unknown';

  String get orderType {
    final type = order['orderType'];

    if (type == 0) return 'Pickup & Delivery';
    if (type == 1) return 'Delivery Only';

    return 'غير معروف';
  }

  String get statusLabel {
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
        return 'غير معروف';
    }
  }

  Color get statusColor {
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

  Future<Map<String, dynamic>?> _getDocumentData(
    String collection,
    String? documentId,
  ) async {
    if (documentId == null || documentId.isEmpty) {
      return null;
    }

    final document = await FirebaseFirestore.instance
        .collection(collection)
        .doc(documentId)
        .get();

    return document.data();
  }

  Widget _buildPersonCard({
    required String title,
    required IconData icon,
    required Map<String, dynamic>? data,
    required String? fallbackName,
    required bool isCustomer,
  }) {
    final name = data?['name']?.toString() ?? fallbackName ?? 'غير معروف';

    final phone = data?['phone']?.toString() ?? '-';

    final email = isCustomer ? (data?['email']?.toString() ?? '-') : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.black, size: 21),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: AppColors.background,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isCustomer ? 'Customer' : 'Delivery Driver',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),
          const Divider(color: AppColors.border),
          const SizedBox(height: 14),

          _buildDetailRow(Icons.phone_outlined, phone),

          if (email != null) ...[
            const SizedBox(height: 14),
            _buildDetailRow(Icons.email_outlined, email),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.grey),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationCard({
    required String title,
    required String address,
    required IconData icon,
    required Color iconColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: AppColors.grey, fontSize: 13),
              ),
              const SizedBox(height: 6),
              Text(
                address.isEmpty ? 'العنوان غير محدد' : address,
                style: const TextStyle(
                  color: AppColors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryCard() {
    final orderType = order['orderType'];

    final from = order['from']?.toString() ?? '';
    final to = order['to']?.toString() ?? '';

    final isPickupDelivery = orderType == 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: AppColors.primary,
                size: 24,
              ),
              SizedBox(width: 10),
              Text(
                'معلومات التوصيل',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          if (isPickupDelivery) ...[
            _buildLocationCard(
              title: 'عنوان الاستلام',
              address: from,
              icon: Icons.storefront_outlined,
              iconColor: AppColors.blue,
            ),
            const Padding(
              padding: EdgeInsets.only(left: 20, top: 14, bottom: 14),
              child: Icon(Icons.more_vert, color: AppColors.grey),
            ),
          ],

          _buildLocationCard(
            title: 'عنوان التوصيل',
            address: to,
            icon: Icons.location_on_outlined,
            iconColor: AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow({
    required String title,
    required dynamic value,
    bool isTotal = false,
  }) {
    final amount = value is num ? value : num.tryParse('$value') ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? AppColors.black : AppColors.grey,
            ),
          ),
          Text(
            '${amount.toStringAsFixed(0)} EGP',
            style: TextStyle(
              fontSize: isTotal ? 18 : 15,
              fontWeight: FontWeight.bold,
              color: isTotal ? AppColors.success : AppColors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                color: AppColors.primary,
                size: 24,
              ),
              SizedBox(width: 10),
              Text(
                'ملخص الأسعار',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          _buildPriceRow(title: 'سعر التوصيل', value: order['deliveryPrice']),

          _buildPriceRow(title: 'رسوم إضافية', value: order['additionalFees']),

          const SizedBox(height: 12),
          const Divider(color: AppColors.border),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الإجمالي النهائي',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Total Amount',
                      style: TextStyle(fontSize: 12, color: AppColors.grey),
                    ),
                  ],
                ),

                Text(
                  '${_formatAmount(order['totalPrice'])} EGP',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(dynamic value) {
    final amount = value is num
        ? value
        : num.tryParse(value?.toString() ?? '') ?? 0;

    return amount.toStringAsFixed(0);
  }

  DateTime? _getDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  String _formatTimelineDate(dynamic value) {
    final date = _getDateTime(value);

    if (date == null) return 'غير متاح';

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;

    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/$year - $hour:$minute';
  }

  Widget _buildTimelineItem({
    required String title,
    required dynamic date,
    required bool isCompleted,
    required bool isLast,
  }) {
    final color = isCompleted ? AppColors.success : AppColors.grey;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(
              isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
              color: color,
              size: 24,
            ),
            if (!isLast)
              Container(width: 2, height: 45, color: AppColors.border),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isCompleted ? AppColors.black : AppColors.grey,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _formatTimelineDate(date),
                  style: const TextStyle(fontSize: 13, color: AppColors.grey),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderTimeline() {
    final status = order['status']?.toString();

    final isCancelled = status == 'cancelled';
    final isInProgress = status == 'inProgress' || status == 'delivered';

    final isDelivered = status == 'delivered';

    final steps = [
      {
        'title': 'تم إنشاء الطلب',
        'date': order['createdAt'],
        'completed': order['createdAt'] != null,
      },
      {
        'title': 'بدأ المندوب التوصيل',
        'date': order['inProgressAt'],
        'completed': isInProgress,
      },
      {
        'title': isCancelled ? 'تم إلغاء الطلب' : 'تم تسليم الطلب',
        'date': isCancelled ? order['cancelledAt'] : order['deliveredAt'],
        'completed': isCancelled || isDelivered,
      },
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.timeline_rounded, color: AppColors.primary, size: 24),
              SizedBox(width: 10),
              Text(
                'رحلة الطلب',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          ...List.generate(steps.length, (index) {
            final step = steps[index];

            final completed = step['completed'] as bool;
            final isLast = index == steps.length - 1;

            return _buildTimelineItem(
              title: step['title'] as String,
              date: step['date'],
              isCompleted: completed,
              isLast: isLast,
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Header
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded),
                tooltip: 'رجوع',
              ),
              const SizedBox(width: 8),
              const Text(
                'تفاصيل الطلب',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Order Summary Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Order $orderNumber',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                const Divider(color: AppColors.border),

                const SizedBox(height: 16),

                Wrap(
                  spacing: 40,
                  runSpacing: 20,
                  children: [
                    _buildInfoItem(
                      'نوع الطلب',
                      orderType,
                      Icons.shopping_bag_outlined,
                    ),
                    _buildInfoItem(
                      'تفاصيل الطلب',
                      order['orderDetails']?.toString() ?? '-',
                      Icons.inventory_2_outlined,
                    ),
                    _buildInfoItem(
                      'المسافة',
                      '${order['distance'] ?? 0} KM',
                      Icons.route_outlined,
                    ),
                    _buildInfoItem(
                      'طريقة الدفع',
                      order['paymentMethod'] == 'cash_on_delivery'
                          ? 'Cash on Delivery'
                          : order['paymentMethod']?.toString() ?? '-',
                      Icons.payments_outlined,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          FutureBuilder<Map<String, dynamic>?>(
            future: _getDocumentData('users', order['customerId']?.toString()),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              return _buildPersonCard(
                title: 'بيانات العميل',
                icon: Icons.person_outline,
                data: snapshot.data,
                fallbackName: order['customerName']?.toString(),
                isCustomer: true,
              );
            },
          ),

          const SizedBox(height: 16),

          FutureBuilder<Map<String, dynamic>?>(
            future: _getDocumentData('drivers', order['driverId']?.toString()),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              return _buildPersonCard(
                title: 'بيانات المندوب',
                icon: Icons.delivery_dining_outlined,
                data: snapshot.data,
                fallbackName: order['driverName']?.toString(),
                isCustomer: false,
              );
            },
          ),
          const SizedBox(height: 24),
          _buildDeliveryCard(),
          const SizedBox(height: 24),
          _buildPriceSummary(),
          const SizedBox(height: 24),
          _buildOrderTimeline(),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String title, String value, IconData icon) {
    return SizedBox(
      width: 220,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.grey, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: AppColors.grey, fontSize: 13),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
