import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AdminSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const AdminSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  static const List<Map<String, dynamic>> _menuItems = [
    {'title': 'الرئيسية', 'icon': Icons.dashboard_rounded},
    {'title': 'إدارة الطلبات', 'icon': Icons.shopping_bag_rounded},
    {'title': 'المندوبون', 'icon': Icons.delivery_dining_rounded},
    {'title': 'العملاء', 'icon': Icons.people_alt_rounded},
    {'title': 'التقارير', 'icon': Icons.bar_chart_rounded},
    {'title': 'الأسعار والمناطق', 'icon': Icons.location_on_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: AppColors.white,
      child: Column(
        children: [
          const SizedBox(height: 30),

          // Logo
          const Text(
            'WASSELNI',
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w900,
              color: AppColors.black,
              letterSpacing: 1.5,
            ),
          ),

          const Text(
            'ADMIN DASHBOARD',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.grey,
              letterSpacing: 2,
            ),
          ),

          const SizedBox(height: 35),

          const Divider(color: AppColors.border),

          const SizedBox(height: 15),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                final item = _menuItems[index];
                final isSelected = selectedIndex == index;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () => onItemSelected(index),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 15,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(item['icon'], color: AppColors.black, size: 21),

                          const SizedBox(width: 12),

                          Text(
                            item['title'],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: AppColors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const Divider(color: AppColors.border),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 19,
                  backgroundColor: AppColors.primary,
                  child: Icon(
                    Icons.admin_panel_settings,
                    color: AppColors.black,
                  ),
                ),

                const SizedBox(width: 10),

                const Expanded(
                  child: Text(
                    'Administrator',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                ),

                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.error,
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
