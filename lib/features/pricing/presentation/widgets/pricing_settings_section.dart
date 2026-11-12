import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/pricing_settings_model.dart';
import '../controllers/pricing_controller.dart';

class PricingSettingsSection extends ConsumerWidget {
  const PricingSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(pricingSettingsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'إعدادات التسعير',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'تحكم في تكلفة التوصيل الأساسية وسعر الكيلومتر.',
          style: TextStyle(color: AppColors.grey),
        ),
        const SizedBox(height: 16),

        settingsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) =>
              Center(child: Text('حدث خطأ أثناء تحميل الأسعار: $error')),
          data: (settings) => _PricingSettingsForm(settings: settings),
        ),
      ],
    );
  }
}

class _PricingSettingsForm extends ConsumerStatefulWidget {
  final PricingSettings settings;

  const _PricingSettingsForm({required this.settings});

  @override
  ConsumerState<_PricingSettingsForm> createState() =>
      _PricingSettingsFormState();
}

class _PricingSettingsFormState extends ConsumerState<_PricingSettingsForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _basePriceController;
  late final TextEditingController _pricePerKmController;
  late final TextEditingController _minimumPriceController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _basePriceController = TextEditingController(
      text: widget.settings.basePrice.toString(),
    );

    _pricePerKmController = TextEditingController(
      text: widget.settings.pricePerKm.toString(),
    );

    _minimumPriceController = TextEditingController(
      text: widget.settings.minimumDeliveryPrice.toString(),
    );
  }

  @override
  void dispose() {
    _basePriceController.dispose();
    _pricePerKmController.dispose();
    _minimumPriceController.dispose();
    super.dispose();
  }

  String? _validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'هذا الحقل مطلوب';
    }

    final price = double.tryParse(value.trim());

    if (price == null || price < 0) {
      return 'أدخل قيمة صحيحة';
    }

    return null;
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final settings = PricingSettings(
        basePrice: double.parse(_basePriceController.text.trim()),
        pricePerKm: double.parse(_pricePerKmController.text.trim()),
        minimumDeliveryPrice: double.parse(_minimumPriceController.text.trim()),
      );

      await ref.read(pricingActionsProvider).updatePricingSettings(settings);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ إعدادات التسعير بنجاح'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تعذر حفظ الإعدادات: $error'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildPriceField({
    required String label,
    required String hint,
    required TextEditingController controller,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: _validatePrice,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixText: 'جنيه',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPriceField(
              label: 'السعر الأساسي',
              hint: 'مثال: 20',
              controller: _basePriceController,
            ),
            const SizedBox(height: 20),

            _buildPriceField(
              label: 'سعر الكيلومتر',
              hint: 'مثال: 5',
              controller: _pricePerKmController,
            ),
            const SizedBox(height: 20),

            _buildPriceField(
              label: 'الحد الأدنى لسعر التوصيل',
              hint: 'مثال: 25',
              controller: _minimumPriceController,
            ),
            const SizedBox(height: 24),

            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveSettings,
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: const Text('حفظ الإعدادات'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
