import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/service_area_model.dart';
import '../controllers/pricing_controller.dart';

class AddServiceAreaDialog extends ConsumerStatefulWidget {
  const AddServiceAreaDialog({super.key});

  @override
  ConsumerState<AddServiceAreaDialog> createState() =>
      _AddServiceAreaDialogState();
}

class _AddServiceAreaDialogState extends ConsumerState<AddServiceAreaDialog> {
  final _formKey = GlobalKey<FormState>();

  final _cityController = TextEditingController();
  final _areaController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _cityController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  Future<void> _addArea() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final area = ServiceArea(
        id: '',
        cityName: _cityController.text.trim(),
        areaName: _areaController.text.trim(),
        isActive: true,
      );

      await ref.read(pricingActionsProvider).addServiceArea(area);

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تمت إضافة المنطقة بنجاح'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تعذرت إضافة المنطقة: $error'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'إضافة منطقة خدمة',
        style: TextStyle(color: AppColors.black, fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'اسم المدينة',
                  hintText: 'مثال: المنيا',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'من فضلك أدخل اسم المدينة';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _areaController,
                decoration: const InputDecoration(
                  labelText: 'اسم المنطقة (اختياري)',
                  hintText: 'مثال: وسط البلد',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('إلغاء', style: TextStyle(color: AppColors.grey)),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _addArea,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.black,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.black,
                  ),
                )
              : const Text('إضافة'),
        ),
      ],
    );
  }
}
