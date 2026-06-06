import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../shared/widgets/custom_bottom_sheet.dart';
import '../../../shared/widgets/wheel_picker.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/clickable_action.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/utils/string_utils.dart';

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
    final l10n = AppLocalizations.of(context)!;
    
    final Map<int, String> options = {
      0: l10n.sameDay,
      1: l10n.oneDayBefore,
      2: l10n.twoDaysBefore,
      3: l10n.threeDaysBefore,
      7: l10n.oneWeekBefore,
    };

    final keys = options.keys.toList();
    final values = options.values.toList();
    
    int tempIndex = keys.indexOf(selectedDays);
    if (tempIndex == -1) tempIndex = 0;

    CustomBottomSheet.show(
      context: context,
      title: l10n.reminderDay,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          WheelPicker.strings(
            items: values,
            initialItem: tempIndex,
            onSelectedItemChanged: (idx) => tempIndex = idx,
          ),
          const SizedBox(height: 32),
          CustomButton(
            onTap: () {
              onChanged(keys[tempIndex]);
              Navigator.pop(context);
              HapticFeedback.mediumImpact();
            },
            label: l10n.ok,
            activeColor: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final Map<int, String> options = {
      0: l10n.sameDay,
      1: l10n.oneDayBefore,
      2: l10n.twoDaysBefore,
      3: l10n.threeDaysBefore,
      7: l10n.oneWeekBefore,
    };

    return ClickableAction(
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
                l10n.reminderDay.toSafeUpperCase(context),
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
                options[selectedDays] ?? l10n.unknown,
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
