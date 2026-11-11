import 'package:flutter/material.dart';
import 'package:wasselni_admin/features/customers/presentation/views/customers_view.dart';

import 'package:wasselni_admin/features/dashboard/presentation/widgets/dashboard_stats_section.dart';
import 'package:wasselni_admin/features/dashboard/presentation/widgets/recent_orders_table.dart';
import 'package:wasselni_admin/features/drivers/presentation/views/drivers_view.dart';
import 'package:wasselni_admin/features/orders/presentation/views/orders_view.dart';
import 'package:wasselni_admin/features/reports/presentation/views/reports_view.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/admin_sidebar.dart';

class AdminDashboardLayout extends StatefulWidget {
  const AdminDashboardLayout({super.key});

  @override
  State<AdminDashboardLayout> createState() => _AdminDashboardLayoutState();
}

class _AdminDashboardLayoutState extends State<AdminDashboardLayout> {
  int _selectedIndex = 0;

  static const List<String> _pageTitles = [
    'الرئيسية',
    'إدارة الطلبات',
    'المندوبون',
    'العملاء',
    'التقارير',
    'الأسعار والمناطق',
  ];

  Widget _getSelectedPage() {
    switch (_selectedIndex) {
      case 0:
        return const _DashboardHomeView();

      case 1:
        return const OrdersView();
      case 2:
        return const DriversView();
      case 3:
        return const CustomersView();
      case 4:
        return const ReportsView();
      default:
        return Center(
          child: Text(
            'صفحة ${_pageTitles[_selectedIndex]} قريباً',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          AdminSidebar(
            selectedIndex: _selectedIndex,
            onItemSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),

          Expanded(
            child: Column(
              children: [
                // Top Bar
                Container(
                  height: 75,
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    border: Border(bottom: BorderSide(color: AppColors.border)),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _pageTitles[_selectedIndex],
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.notifications_none_rounded, size: 25),
                      const SizedBox(width: 20),
                      const CircleAvatar(
                        backgroundColor: AppColors.primary,
                        child: Icon(Icons.person, color: AppColors.black),
                      ),
                    ],
                  ),
                ),

                // Page Content
                Expanded(child: _getSelectedPage()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardHomeView extends StatelessWidget {
  const _DashboardHomeView();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'نظرة عامة على Wasselni',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'تابع أداء المنصة وإدارة عمليات التوصيل.',
            style: TextStyle(fontSize: 14, color: AppColors.grey),
          ),
          SizedBox(height: 28),
          DashboardStatsSection(),
          SizedBox(height: 30),
          RecentOrdersTable(),
        ],
      ),
    );
  }
}
