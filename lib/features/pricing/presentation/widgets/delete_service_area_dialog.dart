import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/service_area_model.dart';
import '../controllers/pricing_controller.dart';

class DeleteServiceAreaDialog extends ConsumerStatefulWidget {
  final ServiceArea area;

  const DeleteServiceAreaDialog({super.key, required this.area});

  @override
  ConsumerState<DeleteServiceAreaDialog> createState() =>
      _DeleteServiceAreaDialogState();
}

class _DeleteServiceAreaDialogState
    extends ConsumerState<DeleteServiceAreaDialog> {
  bool _isLoading = false;

  Future<void> _deleteArea() async {
    setState(() => _isLoading = true);

    try {
      await ref.read(pricingActionsProvider).deleteServiceArea(widget.area.id);

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حذف المنطقة بنجاح'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تعذر حذف المنطقة: $error'),
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
        'حذف منطقة الخدمة',
        style: TextStyle(color: AppColors.black, fontWeight: FontWeight.bold),
      ),
      content: Text(
        'هل أنت متأكد من حذف منطقة "${widget.area.cityName} - ${widget.area.areaName}"؟',
        style: const TextStyle(color: AppColors.grey),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('إلغاء', style: TextStyle(color: AppColors.grey)),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _deleteArea,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: AppColors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('تأكيد الحذف'),
        ),
      ],
    );
  }
}
