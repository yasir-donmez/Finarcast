import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/services/currency_service.dart';
import '../../../../core/providers/db_providers.dart';
import '../../../../core/providers/settings_provider.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../features/home/home_providers.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/clickable_action.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../shared/widgets/custom_notification.dart';
import '../../../../core/database/models/exchange_rate.dart';
import '../settings_list_items.dart';
import '../../../../l10n/app_localizations.dart';

class ExchangeRateSetting extends ConsumerStatefulWidget {
  const ExchangeRateSetting({super.key});

  @override
  ConsumerState<ExchangeRateSetting> createState() => _ExchangeRateSettingState();
}

class _ExchangeRateSettingState extends ConsumerState<ExchangeRateSetting> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  bool _isUpdating = false;
  bool _showAllRates = false;

  @override
  Widget build(BuildContext context) {
    final activeColor = SettingsListItems.getSettingColor(context, SettingType.exchangeRate, ref.watch(rotaryColorProvider));
    final rates = ref.watch(exchangeRatesProvider).value ?? [];
    final l10n = AppLocalizations.of(context)!;
    
    final lastUpdate = rates.isNotEmpty 
        ? rates.first.lastUpdated 
        : null;
    
    final lastUpdateStr = lastUpdate != null 
        ? DateFormat('HH:mm').format(lastUpdate) 
        : '--:--';

    final userCurrency = ref.watch(settingsProvider).currencySymbol;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Ana Ayar Satırı
        ClickableAction(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _isExpanded = !_isExpanded);
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
                  child: Icon(Icons.currency_exchange_rounded, size: 22, color: activeColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.exchangeRates,
                        style: TextStyle(
                          color: AppColors.getTextPrimary(context),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        userCurrency == '₺' || userCurrency == 'TRY'
                            ? l10n.baseUnitLira
                            : l10n.baseUnitLabel(userCurrency),
                        style: TextStyle(
                          color: AppColors.getTextSecondary(context).withValues(alpha: 0.4),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      l10n.lastSyncShort(lastUpdateStr),
                      style: TextStyle(
                        color: activeColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    AnimatedRotation(
                      turns: _isExpanded ? 0.25 : 0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutBack,
                      child: Icon(
                        Icons.chevron_right_rounded,
                        color: activeColor.withValues(alpha: _isExpanded ? 1.0 : 0.3),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Genişleyen Bölüm
        AnimatedSize(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutQuart,
          alignment: Alignment.topCenter,
          child: _isExpanded
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      ..._buildRatesList(context, rates, userCurrency, activeColor),
                      const SizedBox(height: 16),
                      CustomButton(
                        label: _isUpdating ? l10n.updatingRates : l10n.updateRatesNow,
                        height: 48,
                        fontSize: 13,
                        onTap: () async {
                          if (_isUpdating) return;
                          setState(() => _isUpdating = true);
                          final success = await CurrencyService.updateRates();
                          if (mounted) setState(() => _isUpdating = false);

                          if (!context.mounted) return;
                          if (success) {
                            CustomNotification.success(context, l10n.exchangeRatesUpdated);
                          } else {
                            CustomNotification.error(context, l10n.exchangeRatesUpdateFailed);
                          }
                        },
                        activeColor: activeColor,
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  List<Widget> _buildRatesList(
    BuildContext context,
    List<ExchangeRate> rates,
    String userCurrency,
    Color activeColor,
  ) {
    final allRates = List<ExchangeRate>.from(rates);
    if (!allRates.any((r) => r.currencyCode == 'TRY')) {
      allRates.add(ExchangeRate()
        ..currencyCode = 'TRY'
        ..rate = 1.0
        ..lastUpdated = rates.isNotEmpty ? rates.first.lastUpdated : DateTime.now());
    }

    final normalizedUserCurrency = CurrencyUtils.symbolToCode(userCurrency);

    // Ana para birimine göre "merak edilen" popüler kurları dinamik belirle
    final List<String> commonCodes;
    switch (normalizedUserCurrency) {
      case 'TRY':
        commonCodes = ['USD', 'EUR', 'GOLD'];
        break;
      case 'USD':
        commonCodes = ['EUR', 'GBP', 'GOLD'];
        break;
      case 'EUR':
        commonCodes = ['USD', 'GBP', 'GOLD'];
        break;
      case 'GBP':
        commonCodes = ['USD', 'EUR', 'GOLD'];
        break;
      default:
        commonCodes = ['USD', 'EUR', 'GOLD'];
    }

    // Listeyi filtreleyelim
    final commonRates = allRates.where((r) {
      final code = r.currencyCode;
      return commonCodes.contains(code) && code != normalizedUserCurrency;
    }).toList();

    final otherRates = allRates.where((r) {
      final code = r.currencyCode;
      // Ortak olanlar ve kullanıcının ana para birimi dışındaki kurlar
      return !commonCodes.contains(code) && code != normalizedUserCurrency;
    }).toList();

    // Sadece göstermek istediğimiz ve isminin tanımlı olduğu kurları listeleyelim
    final filteredCommon = commonRates;

    final filteredOther = <dynamic>[];
    final seenOther = <String>{};
    for (final rate in otherRates) {
      final code = rate.currencyCode;
      // Sadece isimlendirilmiş/desteklenen kurları ve mükerrer olmayanları ekleyelim.
      final hasName = ['TRY', 'GBP', 'CHF', 'KWD', 'SAR', 'JPY', 'SILVER'].contains(code);
      if (hasName && !seenOther.contains(code)) {
        seenOther.add(code);
        filteredOther.add(rate);
      }
    }

    final List<Widget> listItems = [];
    final l10n = AppLocalizations.of(context)!;
    final isGlobal = userCurrency != '₺' && userCurrency != 'TRY';
    final locale = Localizations.localeOf(context).toString();

    String formatRate(double rate) {
      final decimals = rate < 1 ? 4 : 2;
      final formatter = NumberFormat.decimalPattern(locale);
      formatter.minimumFractionDigits = decimals;
      formatter.maximumFractionDigits = decimals;
      return formatter.format(rate);
    }

    // Popüler Kurlar
    for (final rate in filteredCommon) {
      double displayRate = CurrencyUtils.convert(1.0, rate.currencyCode, userCurrency, allRates);
      if (isGlobal) {
        if (rate.currencyCode == 'GOLD') {
          displayRate *= 31.1034768;
        } else if (rate.currencyCode == 'SILVER') {
          displayRate *= 31.1034768;
        }
      }

      listItems.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: CustomCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Text(
                  _getCurrencyEmoji(rate.currencyCode),
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 12),
                Text(
                  _getCurrencyName(rate.currencyCode, userCurrency, l10n),
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: AppColors.getTextPrimary(context),
                  ),
                ),
                const Spacer(),
                Text(
                  "$userCurrency${formatRate(displayRate)}",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: activeColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Diğer Kurlar (Eğer _showAllRates true ise)
    if (_showAllRates) {
      for (final rate in filteredOther) {
        double displayRate = CurrencyUtils.convert(1.0, rate.currencyCode, userCurrency, allRates);
        if (isGlobal) {
          if (rate.currencyCode == 'GOLD') {
            displayRate *= 31.1034768;
          } else if (rate.currencyCode == 'SILVER') {
            displayRate *= 31.1034768;
          }
        }

        listItems.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: CustomCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Text(
                    _getCurrencyEmoji(rate.currencyCode),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _getCurrencyName(rate.currencyCode, userCurrency, l10n),
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: AppColors.getTextPrimary(context),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "$userCurrency${formatRate(displayRate)}",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: activeColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    // "Daha Fazla Göster" / "Daha Az Göster" butonu
    if (filteredOther.isNotEmpty) {
      listItems.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: ClickableAction(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                _showAllRates = !_showAllRates;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _showAllRates ? AppLocalizations.of(context)!.showLess : AppLocalizations.of(context)!.showMore,
                    style: TextStyle(
                      color: activeColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    _showAllRates 
                        ? Icons.keyboard_arrow_up_rounded 
                        : Icons.keyboard_arrow_down_rounded,
                    color: activeColor,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return listItems;
  }


  String _getCurrencyEmoji(String code) {
    switch (code) {
      case 'USD': return '🇺🇸';
      case 'EUR': return '🇪🇺';
      case 'TRY': return '🇹🇷';
      case 'GBP': return '🇬🇧';
      case 'CHF': return '🇨🇭';
      case 'KWD': return '🇰🇼';
      case 'SAR': return '🇸🇦';
      case 'JPY': return '🇯🇵';
      case 'SILVER': return '🥈';
      case 'GOLD': return '🟡';
      default: return '💰';
    }
  }

  String _getCurrencyName(String code, String userCurrency, AppLocalizations l10n) {
    final isGlobal = userCurrency != '₺' && userCurrency != 'TRY';
 
    switch (code) {
      case 'USD': return l10n.currencyUSD;
      case 'EUR': return l10n.currencyEUR;
      case 'TRY': return l10n.currencyTRY;
      case 'GBP': return l10n.currencyGBP;
      case 'CHF': return l10n.currencyCHF;
      case 'KWD': return l10n.currencyKWD;
      case 'SAR': return l10n.currencySAR;
      case 'JPY': return l10n.currencyJPY;
      case 'SILVER':
        return isGlobal ? l10n.currencySILVEROunce : l10n.currencySILVER;
      case 'GOLD':
        return isGlobal ? l10n.currencyGOLDOunce : l10n.currencyGOLD;
      default: return code;
    }
  }
}
