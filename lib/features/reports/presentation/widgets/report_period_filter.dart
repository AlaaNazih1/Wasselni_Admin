import 'package:flutter/material.dart';

class ReportPeriodFilter extends StatelessWidget {
  final String selectedPeriod;
  final ValueChanged<String> onChanged;

  const ReportPeriodFilter({
    super.key,
    required this.selectedPeriod,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: SizedBox(
        width: 220,
        child: DropdownButtonFormField<String>(
          value: selectedPeriod,
          decoration: InputDecoration(
            labelText: 'الفترة الزمنية',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items: const [
            DropdownMenuItem(value: 'today', child: Text('اليوم')),
            DropdownMenuItem(value: 'week', child: Text('آخر 7 أيام')),
            DropdownMenuItem(value: 'month', child: Text('الشهر الحالي')),
            DropdownMenuItem(value: 'all', child: Text('كل الوقت')),
          ],
          onChanged: (value) {
            if (value != null) {
              onChanged(value);
            }
          },
        ),
      ),
    );
  }
}
