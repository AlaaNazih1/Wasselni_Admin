import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasselni_admin/features/orders/presentation/views/order_details_view.dart';

import '../../../../core/theme/app_colors.dart';
import '../controllers/admin_orders_controller.dart';

class OrdersView extends ConsumerStatefulWidget {
  const OrdersView({super.key});

  @override
  ConsumerState<OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends ConsumerState<OrdersView> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String _selectedStatus = 'all';

  static const Map<String, String> _statuses = {
    'all': 'كل الطلبات',
    'pending': 'طلب جديد',
    'accepted': 'تم قبول الطلب',
    'inProgress': 'جاري التوصيل',
    'delivered': 'تم التوصيل',
    'cancelled': 'ملغي',
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getStatus(String? status) {
    return _statuses[status] ?? status ?? 'غير معروف';
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

    final DateTime? date = value is DateTime
        ? value
        : value.toDate() as DateTime;

    if (date == null) return '-';

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatPrice(dynamic value) {
    if (value == null) return '0 EGP';
    if (value is num) return '${value.toStringAsFixed(0)} EGP';
    return '$value EGP';
  }

  List<Map<String, dynamic>> _filterOrders(List<Map<String, dynamic>> orders) {
    return orders.where((order) {
      final orderNumber = order['orderNumber']?.toString().toLowerCase() ?? '';

      final orderId = order['orderId']?.toString().toLowerCase() ?? '';

      final customer = order['customerName']?.toString().toLowerCase() ?? '';

      final driver = order['driverName']?.toString().toLowerCase() ?? '';

      final query = _searchQuery.toLowerCase();

      final matchesSearch =
          query.isEmpty ||
          orderNumber.contains(query) ||
          orderId.contains(query) ||
          customer.contains(query) ||
          driver.contains(query);

      final matchesStatus =
          _selectedStatus == 'all' ||
          order['status']?.toString() == _selectedStatus;

      return matchesSearch && matchesStatus;
    }).toList();
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedStatus = 'all';
    });
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(adminOrdersProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'إدارة الطلبات',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'عرض ومتابعة جميع طلبات العملاء',
            style: TextStyle(color: AppColors.grey, fontSize: 14),
          ),
          const SizedBox(height: 24),

          // Search and Filters
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.trim();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'ابحث برقم الطلب أو العميل أو المندوب...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                            icon: const Icon(Icons.close),
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'حالة الطلب',
                    filled: true,
                    fillColor: AppColors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _statuses.entries.map((entry) {
                    return DropdownMenuItem(
                      value: entry.key,
                      child: Text(entry.value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value == null) return;

                    setState(() {
                      _selectedStatus = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                tooltip: 'إعادة تعيين الفلاتر',
                onPressed: _resetFilters,
                icon: const Icon(Icons.restart_alt),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Orders Table
          Expanded(
            child: ordersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) {
                debugPrint('Orders View Error: $error');

                return const Center(child: Text('حدث خطأ أثناء تحميل الطلبات'));
              },
              data: (orders) {
                final filteredOrders = _filterOrders(orders);

                if (filteredOrders.isEmpty) {
                  return const Center(
                    child: Text('لا توجد طلبات تطابق البحث أو الفلتر'),
                  );
                }

                return Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'عدد النتائج: ${filteredOrders.length}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: SingleChildScrollView(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowColor: WidgetStateProperty.all(
                                AppColors.background,
                              ),
                              columns: const [
                                DataColumn(label: Text('رقم الطلب')),
                                DataColumn(label: Text('العميل')),
                                DataColumn(label: Text('المندوب')),
                                DataColumn(label: Text('السعر')),
                                DataColumn(label: Text('الحالة')),
                                DataColumn(label: Text('التاريخ')),
                              ],
                              rows: filteredOrders.map((order) {
                                final status = order['status']?.toString();

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
                                          order['orderNumber']?.toString() ??
                                              '-',
                                          style: const TextStyle(
                                            color: AppColors.blue,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        order['customerName']?.toString() ??
                                            'عميل غير معروف',
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        order['driverName']?.toString() ??
                                            'غير معين',
                                      ),
                                    ),
                                    DataCell(
                                      Text(_formatPrice(order['totalPrice'])),
                                    ),
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
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
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
                                    DataCell(
                                      Text(_formatDate(order['createdAt'])),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
