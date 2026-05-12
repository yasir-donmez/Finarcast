import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../shared/widgets/precision_sheet.dart';
import '../../../shared/widgets/precision_picker.dart';
import '../../../shared/widgets/precision_button.dart';
import '../../../shared/widgets/precision_action.dart';

class TransactionReminderDaysSelector extends StatelessWidget {
  final int selectedDays;
  final ValueChanged<int> onChanged;
  final double scalingFactor;

  const TransactionReminderDaysSelector({
    super.key,
    required this.selectedDays,
    required this.onChanged,
    this.scalingFactor = 1.0,
  });

  void _showDaysPickerSheet(BuildContext context) {
    HapticFeedback.mediumImpact();
    
    final Map<int, String> options = {
      0: 'Aynı Gün',
      1: '1 Gün Önce',
      2: '2 Gün Önce',
      3: '3 Gün Önce',
      7: '1 Hafta Önce',
    };

    final keys = options.keys.toList();
    final values = options.values.toList();
    
    int tempIndex = keys.indexOf(selectedDays);
    if (tempIndex == -1) tempIndex = 0;

    PrecisionSheet.show(
      context: context,
      title: 'HATIRLATMA GÜNÜ',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PrecisionPicker.strings(
            items: values,
            initialItem: tempIndex,
            onSelectedItemChanged: (idx) => tempIndex = idx,
          ),
          const SizedBox(height: 32),
          PrecisionButton(
            onTap: () {
              onChanged(keys[tempIndex]);
              Navigator.pop(context);
              HapticFeedback.mediumImpact();
            },
            label: 'TAMAM',
            activeColor: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<int, String> options = {
      0: 'Aynı Gün',
      1: '1 Gün Önce',
      2: '2 Gün Önce',
      3: '3 Gün Önce',
      7: '1 Hafta Önce',
    };

    return PrecisionAction(
      onTap: () => _showDaysPickerSheet(context),
      color: Colors.transparent,
      showFlash: false,
      padding: EdgeInsets.symmetric(
        horizontal: 16 * scalingFactor,
        vertical: 12 * scalingFactor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 18 * scalingFactor,
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
              ),
              SizedBox(width: 12 * scalingFactor),
              Text(
                'HATIRLATMA GÜNÜ'.toUpperCase(),
                style: TextStyle(
                  fontSize: 11 * scalingFactor,
                  fontWeight: FontWeight.w900,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                options[selectedDays] ?? 'Bilinmiyor',
                style: TextStyle(
                  fontSize: 14 * scalingFactor,
                  fontWeight: FontWeight.w900,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                size: 18 * scalingFactor,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
