import 'package:flutter/material.dart';
import '../../../core/theme/app_constants.dart';
import '../../../shared/widgets/segmented_control.dart';
import '../../../core/utils/string_utils.dart';
import '../../../l10n/app_localizations.dart';

class TransactionTypeToggle extends StatelessWidget {
  final int tabIndex; // 0 = Gider, 1 = Gelir
  final ValueChanged<int>? onTabChanged;

  const TransactionTypeToggle({
    super.key,
    required this.tabIndex,
    this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isIncome = tabIndex == 1;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: IgnorePointer(
        ignoring: onTabChanged == null,
        child: Opacity(
          opacity: onTabChanged == null ? 0.6 : 1.0,
          child: SegmentedControl(
            tabs: [
              l10n.expense.toSafeUpperCase(context),
              l10n.income.toSafeUpperCase(context),
            ],
            // Seçili sekmeye göre ana rengi değiştiriyoruz
            activeColor: isIncome ? AppColors.getIncome(context) : AppColors.getExpense(context),
            selectedIndex: tabIndex,
            onTabChanged: onTabChanged ?? (_) {},
          ),
        ),
      ),
    );
  }
}
