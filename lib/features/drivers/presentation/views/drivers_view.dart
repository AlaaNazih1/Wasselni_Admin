import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../controllers/admin_drivers_controller.dart';

class DriversView extends ConsumerStatefulWidget {
  const DriversView({super.key});

  @override
  ConsumerState<DriversView> createState() => _DriversViewState();
}

class _DriversViewState extends ConsumerState<DriversView> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String _activityFilter = 'all';
  String _approvalFilter = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getApprovalColor(bool isApproved) {
    return isApproved ? AppColors.success : AppColors.warning;
  }

  String _getApprovalStatus(bool isApproved) {
    return isApproved ? 'تمت الموافقة' : 'تحت المراجعة';
  }

  Color _getActivityColor(bool isActive) {
    return isActive ? AppColors.success : AppColors.grey;
  }

  String _getActivityStatus(bool isActive) {
    return isActive ? 'نشط' : 'غير نشط';
  }

  Widget _buildStatusBadge({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final driversAsync = ref.watch(adminDriversProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'إدارة المندوبين',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'عرض ومتابعة جميع مندوبي Wasselni',
            style: TextStyle(fontSize: 14, color: AppColors.grey),
          ),

          const SizedBox(height: 24),

          Expanded(
            child: driversAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),

              error: (error, stackTrace) {
                debugPrint('Drivers Error: $error');

                return const Center(
                  child: Text('حدث خطأ أثناء تحميل بيانات المندوبين'),
                );
              },

              data: (drivers) {
                final totalDrivers = drivers.length;

                final activeDrivers = drivers
                    .where((driver) => driver['isActive'] == true)
                    .length;

                final approvedDrivers = drivers
                    .where((driver) => driver['isApproved'] == true)
                    .length;

                final pendingDrivers = drivers
                    .where((driver) => driver['isApproved'] != true)
                    .length;
                final filteredDrivers = drivers.where((driver) {
                  final name = driver['name']?.toString().toLowerCase() ?? '';
                  final phone = driver['phone']?.toString() ?? '';

                  final matchesSearch =
                      name.contains(_searchQuery.toLowerCase()) ||
                      phone.contains(_searchQuery);

                  final isActive = driver['isActive'] == true;
                  final isApproved = driver['isApproved'] == true;

                  final matchesActivity =
                      _activityFilter == 'all' ||
                      (_activityFilter == 'active' && isActive) ||
                      (_activityFilter == 'inactive' && !isActive);

                  final matchesApproval =
                      _approvalFilter == 'all' ||
                      (_approvalFilter == 'approved' && isApproved) ||
                      (_approvalFilter == 'pending' && !isApproved);

                  return matchesSearch && matchesActivity && matchesApproval;
                }).toList();
                return Column(
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;

                        final crossAxisCount = width >= 1100
                            ? 4
                            : width >= 750
                            ? 2
                            : 1;

                        return GridView.count(
                          crossAxisCount: crossAxisCount,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.8,
                          children: [
                            _buildStatCard(
                              'إجمالي المندوبين',
                              totalDrivers,
                              Icons.delivery_dining,
                              AppColors.blue,
                            ),
                            _buildStatCard(
                              'المندوبون النشطون',
                              activeDrivers,
                              Icons.check_circle_outline,
                              AppColors.success,
                            ),
                            _buildStatCard(
                              'تمت الموافقة',
                              approvedDrivers,
                              Icons.verified_outlined,
                              AppColors.success,
                            ),
                            _buildStatCard(
                              'تحت المراجعة',
                              pendingDrivers,
                              Icons.pending_actions,
                              AppColors.warning,
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    Expanded(
                      child: Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        'قائمة المندوبين',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.black,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        'النتائج: ${filteredDrivers.length} / ${drivers.length}',
                                        style: const TextStyle(
                                          color: AppColors.grey,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 16),

                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      final isSmallScreen =
                                          constraints.maxWidth < 800;

                                      final searchField = TextField(
                                        controller: _searchController,
                                        onChanged: (value) {
                                          setState(() {
                                            _searchQuery = value.trim();
                                          });
                                        },
                                        decoration: InputDecoration(
                                          hintText:
                                              'ابحث بالاسم أو رقم الهاتف...',
                                          prefixIcon: const Icon(Icons.search),
                                          suffixIcon: _searchQuery.isNotEmpty
                                              ? IconButton(
                                                  onPressed: () {
                                                    _searchController.clear();
                                                    setState(
                                                      () => _searchQuery = '',
                                                    );
                                                  },
                                                  icon: const Icon(Icons.close),
                                                )
                                              : null,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                      );

                                      final activityDropdown =
                                          DropdownButtonFormField<String>(
                                            value: _activityFilter,
                                            decoration: InputDecoration(
                                              labelText: 'حالة الحساب',
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            items: const [
                                              DropdownMenuItem(
                                                value: 'all',
                                                child: Text('الكل'),
                                              ),
                                              DropdownMenuItem(
                                                value: 'active',
                                                child: Text('نشط'),
                                              ),
                                              DropdownMenuItem(
                                                value: 'inactive',
                                                child: Text('غير نشط'),
                                              ),
                                            ],
                                            onChanged: (value) {
                                              if (value != null) {
                                                setState(
                                                  () => _activityFilter = value,
                                                );
                                              }
                                            },
                                          );

                                      final approvalDropdown =
                                          DropdownButtonFormField<String>(
                                            value: _approvalFilter,
                                            decoration: InputDecoration(
                                              labelText: 'حالة الموافقة',
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            items: const [
                                              DropdownMenuItem(
                                                value: 'all',
                                                child: Text('الكل'),
                                              ),
                                              DropdownMenuItem(
                                                value: 'approved',
                                                child: Text('تمت الموافقة'),
                                              ),
                                              DropdownMenuItem(
                                                value: 'pending',
                                                child: Text('تحت المراجعة'),
                                              ),
                                            ],
                                            onChanged: (value) {
                                              if (value != null) {
                                                setState(
                                                  () => _approvalFilter = value,
                                                );
                                              }
                                            },
                                          );

                                      if (isSmallScreen) {
                                        return Column(
                                          children: [
                                            searchField,
                                            const SizedBox(height: 12),
                                            activityDropdown,
                                            const SizedBox(height: 12),
                                            approvalDropdown,
                                          ],
                                        );
                                      }

                                      return Row(
                                        children: [
                                          Expanded(flex: 2, child: searchField),
                                          const SizedBox(width: 12),
                                          Expanded(child: activityDropdown),
                                          const SizedBox(width: 12),
                                          Expanded(child: approvalDropdown),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),

                            const Divider(height: 1),

                            Expanded(
                              child: filteredDrivers.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.person_search_outlined,
                                            size: 64,
                                            color: AppColors.grey.withValues(
                                              alpha: 0.5,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          const Text(
                                            'لا توجد نتائج',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          const Text(
                                            'جرب تغيير كلمة البحث أو الفلاتر',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: AppColors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          OutlinedButton.icon(
                                            onPressed: () {
                                              _searchController.clear();
                                              setState(() {
                                                _searchQuery = '';
                                                _activityFilter = 'all';
                                                _approvalFilter = 'all';
                                              });
                                            },
                                            icon: const Icon(Icons.refresh),
                                            label: const Text(
                                              'إعادة ضبط البحث والفلاتر',
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : SingleChildScrollView(
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: DataTable(
                                          headingRowColor:
                                              WidgetStateProperty.all(
                                                AppColors.background,
                                              ),

                                          columns: const [
                                            DataColumn(label: Text('المندوب')),
                                            DataColumn(
                                              label: Text('رقم الهاتف'),
                                            ),
                                            DataColumn(
                                              label: Text('حالة الحساب'),
                                            ),
                                            DataColumn(label: Text('الموافقة')),
                                            DataColumn(
                                              label: Text('تاريخ التسجيل'),
                                            ),
                                          ],

                                          rows: filteredDrivers.map((driver) {
                                            final name =
                                                driver['name']?.toString() ??
                                                'بدون اسم';
                                            final phone =
                                                driver['phone']?.toString() ??
                                                '-';
                                            final isActive =
                                                driver['isActive'] == true;
                                            final isApproved =
                                                driver['isApproved'] == true;

                                            final createdAt =
                                                driver['createdAt'];
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
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      CircleAvatar(
                                                        radius: 18,
                                                        backgroundColor:
                                                            AppColors.primary
                                                                .withValues(
                                                                  alpha: 0.15,
                                                                ),
                                                        child: Text(
                                                          name.isNotEmpty
                                                              ? name[0]
                                                                    .toUpperCase()
                                                              : '?',
                                                          style:
                                                              const TextStyle(
                                                                color: AppColors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      Text(
                                                        name,
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                DataCell(Text(phone)),
                                                DataCell(
                                                  _buildStatusBadge(
                                                    label: _getActivityStatus(
                                                      isActive,
                                                    ),
                                                    color: _getActivityColor(
                                                      isActive,
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  _buildStatusBadge(
                                                    label: _getApprovalStatus(
                                                      isApproved,
                                                    ),
                                                    color: _getApprovalColor(
                                                      isApproved,
                                                    ),
                                                  ),
                                                ),
                                                DataCell(Text(formattedDate)),
                                              ],
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, int value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
                const SizedBox(height: 5),
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
}
