import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasselni_admin/core/theme/app_colors.dart';
import 'package:wasselni_admin/features/pricing/presentation/widgets/add_service_area_dialog.dart';
import 'package:wasselni_admin/features/pricing/presentation/widgets/delete_service_area_dialog.dart';
import 'package:wasselni_admin/features/pricing/presentation/widgets/edit_service_area_dialog.dart';

import '../controllers/pricing_controller.dart';

class ServiceAreasSection extends ConsumerWidget {
  const ServiceAreasSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final areasAsync = ref.watch(serviceAreasProvider);

  return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'مناطق الخدمة',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const AddServiceAreaDialog(),
                );
              },
              
              icon: const Icon(Icons.add),
              label: const Text('إضافة منطقة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        areasAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) =>
              Center(child: Text('حدث خطأ أثناء تحميل المناطق: $error')),
          data: (areas) {
            if (areas.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.location_off_outlined,
                      size: 40,
                      color: AppColors.grey,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'لا توجد مناطق خدمة حتى الآن',
                      style: TextStyle(color: AppColors.grey, fontSize: 15),
                    ),
                  ],
                ),
              );
            }

            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: areas.map((area) {
                return Container(
                  width: 280,
                  padding: const EdgeInsets.all(18),
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
                          const Icon(
                            Icons.location_on_outlined,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              area.cityName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Icon(
                            area.isActive ? Icons.check_circle : Icons.cancel,
                            color: area.isActive ? AppColors.blue : AppColors.error,
                            size: 20,
                          ),
                          PopupMenuButton<String>(
                            tooltip: 'إجراءات المنطقة',
                            icon: const Icon(
                              Icons.more_vert,
                              color: AppColors.grey,
                            ),
                            onSelected: (value) {
                              if (value == 'edit') {
                                showDialog(
                                  context: context,
                                  builder: (_) =>
                                      EditServiceAreaDialog(area: area),
                                );
                              } else if (value == 'delete') {
                                showDialog(
                                  context: context,
                                  builder: (_) =>
                                      DeleteServiceAreaDialog(area: area),
                                );
                              }
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit_outlined, size: 18),
                                    SizedBox(width: 8),
                                    Text('تعديل'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete_outline,
                                      size: 18,
                                      color: AppColors.error,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'حذف',
                                      style: TextStyle(color: AppColors.error),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (area.areaName.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          area.areaName,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Text(
                            area.isActive ? 'نشطة' : 'متوقفة',
                            style: TextStyle(
                              color: area.isActive ? AppColors.blue
                                  : AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Switch(
                            value: area.isActive,
                            onChanged: (value) async {
                              try {
                                await ref
                                    .read(pricingActionsProvider)
                                    .toggleServiceArea(area.id, value);
                              } catch (error) {
                                if (!context.mounted) return;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('تعذر تحديث المنطقة: $error'),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
