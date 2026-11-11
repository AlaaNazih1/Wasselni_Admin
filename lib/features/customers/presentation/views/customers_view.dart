import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasselni_admin/features/customers/presentation/views/customer_details_view.dart';

import '../../../../core/theme/app_colors.dart';
import '../controllers/admin_customers_controller.dart';

class CustomersView extends ConsumerStatefulWidget {
  const CustomersView({super.key});

  @override
  ConsumerState<CustomersView> createState() => _CustomersViewState();
}

class _CustomersViewState extends ConsumerState<CustomersView> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(adminCustomersProvider);

    return customersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) =>
          Center(child: Text('حدث خطأ أثناء تحميل العملاء: $error')),
      data: (customers) {
        final filteredCustomers = customers.where((customer) {
          final name = customer['name']?.toString().toLowerCase() ?? '';
          final phone = customer['phone']?.toString().toLowerCase() ?? '';
          final email = customer['email']?.toString().toLowerCase() ?? '';

          return name.contains(_searchQuery) ||
              phone.contains(_searchQuery) ||
              email.contains(_searchQuery);
        }).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'إدارة العملاء',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'عرض ومتابعة جميع عملاء Wasselni',
                style: TextStyle(color: AppColors.grey),
              ),
              const SizedBox(height: 24),

              _buildStats(customers),

              const SizedBox(height: 24),

              TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.trim().toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'ابحث بالاسم أو رقم الهاتف أو البريد الإلكتروني',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                          icon: const Icon(Icons.close),
                        ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              _buildCustomersTable(filteredCustomers),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStats(List<Map<String, dynamic>> customers) {
    final now = DateTime.now();

    final newCustomers = customers.where((customer) {
      final createdAt = customer['createdAt'];

      if (createdAt is! Timestamp) return false;

      final date = createdAt.toDate();

      return date.year == now.year && date.month == now.month;
    }).length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 600;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildStatCard(
              title: 'إجمالي العملاء',
              value: customers.length.toString(),
              icon: Icons.people_alt_outlined,
              color: AppColors.primary,
              width: isWide
                  ? (constraints.maxWidth - 16) / 2
                  : constraints.maxWidth,
            ),
            _buildStatCard(
              title: 'عملاء جدد هذا الشهر',
              value: newCustomers.toString(),
              icon: Icons.person_add_alt_1_outlined,
              color: Colors.green,
              width: isWide
                  ? (constraints.maxWidth - 16) / 2
                  : constraints.maxWidth,
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: AppColors.grey, fontSize: 14),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomersTable(List<Map<String, dynamic>> customers) {
    if (customers.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Text('لا يوجد عملاء مطابقون للبحث'),
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(AppColors.background),
          columns: const [
            DataColumn(label: Text('العميل')),
            DataColumn(label: Text('رقم الهاتف')),
            DataColumn(label: Text('البريد الإلكتروني')),
            DataColumn(label: Text('تاريخ التسجيل')),
          ],
          rows: customers.map((customer) {
            final name = customer['name']?.toString() ?? 'بدون اسم';
            final phone = customer['phone']?.toString() ?? '-';
            final email = customer['email']?.toString() ?? '-';

            final createdAt = customer['createdAt'];
            final date = createdAt is Timestamp ? createdAt.toDate() : null;

            final formattedDate = date == null
                ? '-'
                : '${date.day.toString().padLeft(2, '0')}/'
                      '${date.month.toString().padLeft(2, '0')}/'
                      '${date.year}';

            return DataRow(
              cells: [
                DataCell(
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CustomerDetailsView(customer: customer),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 16,
                            child: Icon(Icons.person_outline, size: 18),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.open_in_new,
                            size: 14,
                            color: AppColors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                DataCell(Text(phone)),
                DataCell(Text(email)),
                DataCell(Text(formattedDate)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
