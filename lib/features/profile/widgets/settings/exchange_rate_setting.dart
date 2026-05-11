import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/services/currency_service.dart';
import '../../../../core/providers/db_providers.dart';
import '../../../../core/providers/settings_provider.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../features/dashboard/dashboard_providers.dart';
import '../../../../shared/widgets/precision_card.dart';
import '../../../../shared/widgets/precision_button.dart';
import '../../../../shared/widgets/precision_action.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../shared/widgets/precision_notification.dart';

class ExchangeRateSetting extends ConsumerStatefulWidget {
  const ExchangeRateSetting({super.key});

  @override
  ConsumerState<ExchangeRateSetting> createState() => _ExchangeRateSettingState();
}

class _ExchangeRateSettingState extends ConsumerState<ExchangeRateSetting> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  bool _isUpdating = false;

  @override
  Widget build(BuildContext context) {
    final activeColor = ref.watch(rotaryColorProvider);
    final rates = ref.watch(exchangeRatesProvider).value ?? [];
    
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
        PrecisionAction(
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
                    border: Border.all(
                      color: activeColor.withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                  child: Icon(Icons.currency_exchange_rounded, size: 22, color: activeColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Döviz Kurları",
                        style: TextStyle(
                          color: AppColors.getTextPrimary(context),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        userCurrency == '₺' 
                            ? "Baz Birim: Türk Lirası" 
                            : "Baz Birim: $userCurrency",
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
                      "SON: $lastUpdateStr",
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
                      // 1. Eğer ana birim TL değilse, Türk Lirası'nı (TRY) listeye ekle
                      if (userCurrency != '₺')
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: PrecisionCard(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                const Text("🇹🇷", style: TextStyle(fontSize: 16)),
                                const SizedBox(width: 12),
                                Text(
                                  "Türk Lirası (TRY)",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    color: AppColors.getTextPrimary(context),
                                  ),
                                ),
                                const Spacer(),
                                Builder(builder: (context) {
                                  // 1 TL kaç [Ana Birim] eder?
                                  final rateInUserCurrency = CurrencyUtils.convert(1.0, 'TRY', userCurrency, rates);
                                  return Text(
                                    "$userCurrency${rateInUserCurrency.toStringAsFixed(4)}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16,
                                      color: activeColor,
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),

                      // 2. Diğer kurları göster (Kendi birimi hariç)
                      ...rates.where((r) {
                        final code = r.currencyCode;
                        final isSupported = ['USD', 'EUR', 'GBP', 'GOLD'].contains(code);
                        return isSupported && code != _normalizeSymbol(userCurrency);
                      }).map((rate) {
                        // Kuru kullanıcının birimine çevir
                        final displayRate = CurrencyUtils.convert(1.0, rate.currencyCode, userCurrency, rates);
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: PrecisionCard(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                Text(
                                  _getCurrencyEmoji(rate.currencyCode),
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  _getCurrencyName(rate.currencyCode),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    color: AppColors.getTextPrimary(context),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  "$userCurrency${displayRate.toStringAsFixed(displayRate < 1 ? 4 : 2)}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                    color: activeColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                      PrecisionButton(
                        label: _isUpdating ? "GÜNCELLENİYOR..." : "KURLARI ŞİMDİ GÜNCELLE",
                        height: 48,
                        fontSize: 13,
                        onTap: () async {
                          if (_isUpdating) return;
                          setState(() => _isUpdating = true);
                          final success = await CurrencyService.updateRates();
                          if (mounted) setState(() => _isUpdating = false);

                          if (!context.mounted) return;
                          if (success) {
                            PrecisionNotification.success(context, "Kurlar başarıyla güncellendi.");
                          } else {
                            PrecisionNotification.error(context, "Güncelleme başarısız. İnternet bağlantınızı kontrol edin.");
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

  String _normalizeSymbol(String symbol) {
    switch (symbol) {
      case r'$': return 'USD';
      case '€': return 'EUR';
      case '£': return 'GBP';
      case '₺': return 'TRY';
      default: return symbol;
    }
  }

  String _getCurrencyEmoji(String code) {
    switch (code) {
      case 'USD': return '🇺🇸';
      case 'EUR': return '🇪🇺';
      case 'GBP': return '🇬🇧';
      case 'CHF': return '🇨🇭';
      case 'KWD': return '🇰🇼';
      case 'SAR': return '🇸🇦';
      case 'JPY': return '🇯🇵';
      case 'GOLD': 
      case 'G': return '🟡';
      default: return '💰';
    }
  }

  String _getCurrencyName(String code) {
    switch (code) {
      case 'USD': return 'Amerikan Doları';
      case 'EUR': return 'Euro';
      case 'GBP': return 'İngiliz Sterlini';
      case 'CHF': return 'İsviçre Frangı';
      case 'KWD': return 'Kuveyt Dinarı';
      case 'SAR': return 'Suudi Riyali';
      case 'JPY': return 'Japon Yeni';
      case 'GOLD': 
      case 'G': return 'Gram Altın';
      default: return code;
    }
  }
}
