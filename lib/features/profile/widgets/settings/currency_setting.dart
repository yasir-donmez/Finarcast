import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/settings_provider.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../shared/widgets/precision_sheet.dart';
import '../../../../shared/widgets/precision_picker.dart';
import '../../../../shared/widgets/precision_button.dart';
import '../../../../shared/widgets/precision_action.dart';
import '../../../../shared/widgets/precision_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../dashboard/dashboard_providers.dart';

final _currencyExpandedProvider = StateProvider.autoDispose<bool>((ref) => false);

class CurrencySetting extends ConsumerWidget {
  const CurrencySetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencySymbol = ref.watch(settingsProvider.select((s) => s.currencySymbol));
    final activeColor = ref.watch(rotaryColorProvider);
    final l10n = AppLocalizations.of(context)!;
    final isExpanded = ref.watch(_currencyExpandedProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PrecisionAction(
          onTap: () {
            HapticFeedback.selectionClick();
            ref.read(_currencyExpandedProvider.notifier).state = !isExpanded;
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: activeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.currency_lira_rounded, color: activeColor, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Para Birimi",
                        style: TextStyle(
                          color: AppColors.getTextPrimary(context),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        isExpanded ? "Ana uygulama birimini seçin." : currencySymbol,
                        style: TextStyle(
                          color: AppColors.getTextSecondary(context).withValues(alpha: 0.5),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: isExpanded ? 0.25 : 0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutBack,
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: activeColor.withValues(alpha: isExpanded ? 1.0 : 0.3),
                  ),
                ),
              ],
            ),
          ),
        ),

        AnimatedSize(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutQuart,
          child: isExpanded
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.getInnerSurface(context),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "Bu birim tüm uygulama genelinde (Dashboard, Kasalar ve İstatistikler) "
                          "ana para birimi olarak kullanılır. Tüm varlıklarınız bu birime göre hesaplanır.",
                          style: TextStyle(
                            color: AppColors.getTextSecondary(context),
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      PrecisionCard(
                        onTap: () => _showCurrencyPicker(context, ref, currencySymbol, l10n),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Text(
                              currencySymbol,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: activeColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "Birimi Değiştir",
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.getTextPrimary(context),
                              ),
                            ),
                            const Spacer(),
                            Icon(Icons.edit_rounded, size: 18, color: activeColor.withValues(alpha: 0.5)),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  void _showCurrencyPicker(BuildContext context, WidgetRef ref, String currentSymbol, AppLocalizations l10n) {
    HapticFeedback.lightImpact();
    final activeColor = ref.read(rotaryColorProvider);
    final currencies = AppCurrency.supportedSymbols;
    int initialIndex = currencies.indexOf(currentSymbol);
    if (initialIndex == -1) initialIndex = 0;

    int tempIndex = initialIndex;

    PrecisionSheet.show(
      context: context,
      title: l10n.selectCurrency,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PrecisionPicker(
            itemCount: currencies.length,
            initialItem: initialIndex,
            onSelectedItemChanged: (index) => tempIndex = index,
            itemBuilder: (context, index, isSelected) {
              final symbol = currencies[index];
              String name = "";
              switch (symbol) {
                case '₺': name = "Türk Lirası"; break;
                case r'$': name = "Amerikan Doları"; break;
                case '€': name = "Euro"; break;
                case '£': name = "İngiliz Sterlini"; break;
                case '¥': name = "Japon Yeni"; break;
                case '₩': name = "Kore Wonu"; break;
                case '元': name = "Çin Yuanı"; break;
                case r'R$': name = "Brezilya Reali"; break;
                case 'Fr': name = "İsviçre Frangı"; break;
                case 'G': name = "Gram Altın"; break;
              }

              return Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      symbol,
                      style: TextStyle(
                        color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)
                            .withValues(alpha: isSelected ? 1.0 : 0.3),
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      name,
                      style: TextStyle(
                        color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)
                            .withValues(alpha: isSelected ? 1.0 : 0.3),
                        fontSize: 15,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          PrecisionButton(
            label: l10n.ok,
            onTap: () {
              ref.read(settingsProvider.notifier).setCurrency(currencies[tempIndex]);
              Navigator.pop(context);
            },
            activeColor: activeColor,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
