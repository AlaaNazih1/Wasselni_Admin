import 'package:flutter/material.dart';

import '../widgets/service_areas_section.dart';

class PricingAreasView extends StatelessWidget {
  const PricingAreasView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'إدارة الأسعار ومناطق الخدمة',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'إدارة المدن والمناطق المتاحة لخدمات التوصيل.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 28),

          const ServiceAreasSection(),
        ],
      ),
    );
  }
}
