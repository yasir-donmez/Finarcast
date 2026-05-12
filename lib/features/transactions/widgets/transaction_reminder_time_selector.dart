import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../shared/widgets/precision_sheet.dart';
import '../../../shared/widgets/precision_picker.dart';
import '../../../shared/widgets/precision_button.dart';
import '../../../shared/widgets/precision_action.dart';

class TransactionReminderTimeSelector extends StatelessWidget {
  final TimeOfDay selectedTime;
  final ValueChanged<TimeOfDay> onChanged;
  final double scalingFactor;

  const TransactionReminderTimeSelector({
    super.key,
    required this.selectedTime,
    required this.onChanged,
    this.scalingFactor = 1.0,
  });

  void _showTimePickerSheet(BuildContext context) {
    HapticFeedback.mediumImpact();
    
    int tempHour = selectedTime.hour;
    int tempMinute = selectedTime.minute;

    PrecisionSheet.show(
      context: context,
      title: 'HATIRLATMA SAATİ',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          SizedBox(
            height: 240,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 100,
                  child: PrecisionPicker.strings(
                    items: List.generate(24, (i) => i.toString().padLeft(2, '0')),
                    initialItem: tempHour,
                    onSelectedItemChanged: (idx) => tempHour = idx,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    ':',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: PrecisionPicker.strings(
                    items: List.generate(60, (i) => i.toString().padLeft(2, '0')),
                    initialItem: tempMinute,
                    onSelectedItemChanged: (idx) => tempMinute = idx,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          PrecisionButton(
            onTap: () {
              onChanged(TimeOfDay(hour: tempHour, minute: tempMinute));
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
    return PrecisionAction(
      onTap: () => _showTimePickerSheet(context),
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
                Icons.access_time_rounded,
                size: 18 * scalingFactor,
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
              ),
              SizedBox(width: 12 * scalingFactor),
              Text(
                'HATIRLATMA SAATİ'.toUpperCase(),
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
                selectedTime.format(context),
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
