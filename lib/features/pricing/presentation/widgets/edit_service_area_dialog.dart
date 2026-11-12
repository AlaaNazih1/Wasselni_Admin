import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/service_area_model.dart';
import '../controllers/pricing_controller.dart';

class EditServiceAreaDialog extends ConsumerStatefulWidget {
  final ServiceArea area;

  const EditServiceAreaDialog({super.key, required this.area});

  @override
  ConsumerState<EditServiceAreaDialog> createState() =>
      _EditServiceAreaDialogState();
}

class _EditServiceAreaDialogState extends ConsumerState<EditServiceAreaDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _cityController;
  late final TextEditingController _areaController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _cityController = TextEditingController(text: widget.area.cityName);

    _areaController = TextEditingController(text: widget.area.areaName);
  }

  @override
  void dispose() {
    _cityController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  Future<void> _updateArea() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updatedArea = ServiceArea(
        id: widget.area.id,
        cityName: _cityController.text.trim(),
        areaName: _areaController.text.trim(),
        isActive: widget.area.isActive,
        createdAt: widget.area.createdAt,
        updatedAt: DateTime.now(),
      );

      await ref.read(pricingActionsProvider).updateServiceArea(updatedArea);

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تحديث المنطقة بنجاح'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تعذر تحديث المنطقة: $error'),
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
        'تعديل منطقة الخدمة',
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
          onPressed: _isLoading ? null : _updateArea,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.black,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('حفظ التعديلات'),
        ),
      ],
    );
  }
}
