import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/settings_provider.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../shared/widgets/custom_bottom_sheet.dart';
import '../../../../shared/widgets/wheel_picker.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/clickable_action.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../home/home_providers.dart';
import '../../../../core/database/database_service.dart';
import '../../../../core/services/currency_service.dart';
import '../../../../core/utils/currency_utils.dart';
import '../settings_list_items.dart';
import '../../../../shared/widgets/custom_notification.dart';

final _currencyExpandedProvider = StateProvider.autoDispose<bool>((ref) => false);

class CurrencySetting extends ConsumerWidget {
  const CurrencySetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencySymbol = ref.watch(settingsProvider.select((s) => s.currencySymbol));
    final activeColor = SettingsListItems.getSettingColor(context, SettingType.currency, ref.watch(rotaryColorProvider));
    final l10n = AppLocalizations.of(context)!;
    final isExpanded = ref.watch(_currencyExpandedProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClickableAction(
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
                        l10n.currency,
                        style: TextStyle(
                          color: AppColors.getTextPrimary(context),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        isExpanded ? l10n.selectMainCurrency : currencySymbol,
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
                      CustomCard(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          l10n.currencyDesc,
                          style: TextStyle(
                            color: AppColors.getTextSecondary(context),
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      CustomCard(
                       onTap: () => _showCurrencyPicker(context, ref, currencySymbol, activeColor, l10n),
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
                              l10n.changeCurrency,
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

  void _showCurrencyPicker(BuildContext context, WidgetRef ref, String currentSymbol, Color activeColor, AppLocalizations l10n) {
    HapticFeedback.lightImpact();
    final currencies = AppCurrency.displaySymbols;
    int initialIndex = currencies.indexOf(currentSymbol);
    if (initialIndex == -1) initialIndex = 0;

    int tempIndex = initialIndex;
    bool isLoading = false;

    CustomBottomSheet.show(
      context: context,
      title: l10n.selectCurrency,
      child: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              WheelPicker(
                itemCount: currencies.length,
                initialItem: initialIndex,
                onSelectedItemChanged: (index) => tempIndex = index,
                itemBuilder: (context, index, isSelected) {
                  final symbol = currencies[index];
                  String name = "";
                  switch (symbol) {
                    case '₺': name = l10n.currencyTRY; break;
                    case r'$': name = l10n.currencyUSD; break;
                    case '€': name = l10n.currencyEUR; break;
                    case '£': name = l10n.currencyGBP; break;
                    case '¥': name = l10n.currencyJPY; break;
                    case '₩': name = l10n.currencyKRW; break;
                    case '元': name = l10n.currencyCNY; break;
                    case r'R$': name = l10n.currencyBRL; break;
                    case 'Fr': name = l10n.currencyCHF; break;
                    case 'G': name = l10n.currencyGOLD; break;
                    case 'Ag': name = l10n.currencySILVER; break;
                    case 'SR': name = l10n.currencySAR; break;
                    case 'KD': name = l10n.currencyKWD; break;
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
              CustomButton(
                label: l10n.ok,
                isLoading: isLoading,
                onTap: () async {
                  if (isLoading) return;

                  final selectedCurrency = currencies[tempIndex];
                  if (selectedCurrency != '₺') {
                    setState(() => isLoading = true);
                    try {
                      final code = CurrencyUtils.symbolToCode(selectedCurrency);
                      final rates = await DatabaseService.getAllExchangeRates();
                      final hasRate = rates.any((r) => r.currencyCode == code && r.rate > 0);

                      if (!hasRate) {
                        final success = await CurrencyService.updateRates(force: true);
                        if (success) {
                          final newRates = await DatabaseService.getAllExchangeRates();
                          final hasRateAfterUpdate = newRates.any((r) => r.currencyCode == code && r.rate > 0);
                          if (!hasRateAfterUpdate) {
                            if (context.mounted) {
                              CustomNotification.error(
                                context,
                                l10n.exchangeRateNotFoundError,
                              );
                            }
                            setState(() => isLoading = false);
                            return;
                          }
                        } else {
                          if (context.mounted) {
                            CustomNotification.error(
                              context,
                              l10n.exchangeRatesDownloadFailed,
                            );
                          }
                          setState(() => isLoading = false);
                          return;
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        CustomNotification.error(
                          context,
                          l10n.exchangeRatesCheckError,
                        );
                      }
                      setState(() => isLoading = false);
                      return;
                    }
                  }

                  ref.read(settingsProvider.notifier).setCurrency(selectedCurrency);
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                activeColor: activeColor,
              ),
              const SizedBox(height: 12),
            ],
          );
        },
      ),
    );
  }
}
