import 'package:flutter/material.dart';
import '../../../core/theme/app_constants.dart';
import '../../../shared/widgets/segmented_control.dart';
import '../../../core/utils/string_utils.dart';
import '../../../l10n/app_localizations.dart';

class TransactionTypeToggle extends StatelessWidget {
  final int tabIndex; // 0 = Gider, 1 = Gelir, 2 = Transfer
  final ValueChanged<int>? onTabChanged;
  final bool isTransferAllowed;

  const TransactionTypeToggle({
    super.key,
    required this.tabIndex,
    this.onTabChanged,
    this.isTransferAllowed = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    final tabs = [
      l10n.expense.toSafeUpperCase(context),
      l10n.income.toSafeUpperCase(context),
    ];
    
    if (isTransferAllowed) {
      // locale'de transfer anahtarını kullanacağız, olmazsa default
      // henüz l10n içine eklenmemişse fallback yapıyoruz, sonrasında arb'ye eklenecek
      // Şimdilik l10n sınıfında "transfer" diyeceğimiz için extension veya property olması lazım
      // Eğer yoksa compile error verir. Şimdilik geçici olarak String yazalım veya l10n kullanıp ekleyelim.
      tabs.add('TRANSFER');
    }

    Color getActiveColor() {
      if (tabIndex == 1) return AppColors.getIncome(context);
      if (tabIndex == 2 && isTransferAllowed) return AppColors.getAccentDeep(context, Colors.blueGrey);
      return AppColors.getExpense(context);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: IgnorePointer(
        ignoring: onTabChanged == null,
        child: Opacity(
          opacity: onTabChanged == null ? 0.6 : 1.0,
          child: SegmentedControl(
            tabs: tabs,
            activeColor: getActiveColor(),
            selectedIndex: tabIndex,
            onTabChanged: onTabChanged ?? (_) {},
          ),
        ),
      ),
    );
  }
}
