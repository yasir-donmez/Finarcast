import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_constants.dart';
import '../../core/utils/currency_utils.dart';
import '../../shared/widgets/glass_surface.dart';
import '../../shared/widgets/custom_card.dart';
import '../../l10n/app_localizations.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/providers/db_providers.dart';
import '../../core/utils/string_utils.dart';
import '../../core/database/models/transaction_status.dart';
import '../vaults/vaults_providers.dart';
import 'home_providers.dart';
import 'widgets/animated_currency_selector.dart';
import 'widgets/horizontal_vault_selector.dart';
import 'widgets/home_widget.dart';
import 'widgets/due_date_radar_widget.dart';
import 'widgets/spending_giants_widget.dart';
import 'widgets/timeline_activity_widget.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/announcement.dart';
import 'providers/announcement_provider.dart';
import '../../core/services/subscription_service.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  String _getGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    final locale = Localizations.localeOf(context).languageCode;
    final isTr = locale == 'tr';
    
    final user = Supabase.instance.client.auth.currentUser;
    String name = "";
    if (user != null) {
      final username = user.userMetadata?['username'] as String?;
      if (username != null && username.isNotEmpty) {
        name = ", ${username[0].toUpperCase() + username.substring(1)}";
      } else if (user.email != null && user.email!.isNotEmpty) {
        name = ", ${user.email!.split('@').first}";
      }
    }

    if (hour >= 5 && hour < 12) {
      return isTr ? 'Günaydın$name ☀️' : 'Good morning$name ☀️';
    } else if (hour >= 12 && hour < 17) {
      return isTr ? 'Tünaydın$name 🌤️' : 'Good afternoon$name 🌤️';
    } else if (hour >= 17 && hour < 22) {
      return isTr ? 'İyi Akşamlar$name 🌙' : 'Good evening$name 🌙';
    } else {
      return isTr ? 'İyi Geceler$name 🌌' : 'Good night$name 🌌';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeVaultId = ref.watch(homeMainBalanceVaultIdProvider);
    final globalCurrency = ref.watch(settingsProvider).currencySymbol;
    final l10n = AppLocalizations.of(context)!;
    final vaults = ref.watch(allVaultsProvider);
    final isTr = Localizations.localeOf(context).languageCode == 'tr';
    final announcements = ref.watch(announcementsProvider).value ?? [];
    final isPro = ref.watch(subscriptionServiceProvider).isPro;

    final visibleAnnouncements = announcements.where((a) {
      if (a.isPremiumPromotion && isPro) {
        return false;
      }
      return true;
    }).toList();

    // Kasa Listesi ve Seçim İndeksi
    final List<String> vaultItems = [l10n.allVaults];
    for (var vault in vaults) {
      vaultItems.add(vault.name);
    }
    int selectedIdx = 0;
    if (activeVaultId != null) {
      final foundIdx = vaults.indexWhere((v) => 'v_${v.id}' == activeVaultId);
      if (foundIdx != -1) {
        selectedIdx = foundIdx + 1;
      }
    }

    // Varlık ve limit bilgileri (Global Filtreye Göre)
    final realBalance = ref.watch(homeRealBalanceProvider);
    final minBalance = ref.watch(homeMinBalanceProvider);
    final maxBalance = ref.watch(homeMaxBalanceProvider);
    final bool hasFlexibleRange = minBalance != realBalance || maxBalance != realBalance;

    // Telefon boyutlarına göre ölçeklendirme çarpanları (Zirve responsive tasarımı)
    final scalingFactor = (MediaQuery.of(context).size.height / 812.0).clamp(0.85, 1.0);
    final screenWidth = MediaQuery.of(context).size.width;
    final fullWidth = screenWidth - (AppSizes.paddingMedium * 2);
    final widgetHeight = fullWidth * 0.70;

    // Günlük İstatistik Hesaplamaları (Bugünkü Gelir / Gider / Net)
    final allTransactions = ref.watch(vaultTransactionsProvider);
    final rates = ref.watch(exchangeRatesProvider).value ?? [];
    final vault = vaults.where((v) => 'v_${v.id}' == activeVaultId).firstOrNull;
    final vaultCurrency = vault?.currency ?? 'AUTO';
    final targetCurrency = vaultCurrency == 'AUTO' ? globalCurrency : vaultCurrency;

    final txs = activeVaultId == null 
        ? allTransactions 
        : allTransactions.where((t) => t.groupIds.contains(activeVaultId)).toList();

    double dailyIncome = 0;
    double dailyExpense = 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final activeTxs = txs.where((t) => t.status != TransactionStatus.skipped && !t.isArchived).toList();
    for (final t in activeTxs) {
      final txDate = DateTime(t.date.year, t.date.month, t.date.day);
      if (txDate.isAtSameMomentAs(today)) {
        final amt = t.getConvertedAmount(targetCurrency, rates);
        final isTransfer = t.targetVaultId != null;
        if (isTransfer) {
          if (activeVaultId != null) {
            final activeDbId = int.tryParse(activeVaultId.replaceFirst('v_', ''));
            if (t.targetVaultId == activeDbId) {
              dailyIncome += amt;
            } else if (t.vaultId == activeDbId) {
              dailyExpense += amt;
            }
          }
        } else {
          if (t.isIncome) {
            dailyIncome += amt;
          } else {
            dailyExpense += amt;
          }
        }
      }
    }

    final dailyNet = dailyIncome - dailyExpense;

    return Stack(
      children: [
        Positioned.fill(
          child: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSizes.paddingSmall),

                  // 1. Karşılama ve Başlık
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
                    child: Text(
                      _getGreeting(context),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                        color: AppColors.getTextPrimary(context),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 2. Neredeyim (Bakiye Alanı - Kartsız)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
                    child: AnimatedCurrencySelector(
                      fontSize: 32, // Biraz daha büyük, kartsız olduğu için ferah duruyor
                      totalBalance: realBalance,
                      minBalance: hasFlexibleRange ? minBalance : null,
                      maxBalance: hasFlexibleRange ? maxBalance : null,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 3. Kasa Seçici (Kartsız)
                  HorizontalVaultSelector(
                    items: vaultItems,
                    selectedIndex: selectedIdx.clamp(0, vaultItems.length - 1),
                    scalingFactor: scalingFactor,
                    onChanged: (newIdx) {
                      String? newVaultId;
                      if (newIdx > 0 && newIdx < vaultItems.length) {
                        newVaultId = 'v_${vaults[newIdx - 1].id}';
                      }
                      ref.read(homeMainBalanceVaultIdProvider.notifier).state = newVaultId;
                    },
                  ),
                  const SizedBox(height: 12),

                  // 3. Genel İstatistikler
                  _buildGeneralStatsCard(context, dailyIncome, dailyExpense, dailyNet, targetCurrency),

                  // 5. Duyurular (Sadece görüntülenecek aktif duyuru varsa gösterilir)
                  if (visibleAnnouncements.isNotEmpty) ...[
                    _buildAnnouncementsCard(context, visibleAnnouncements),
                  ],

                  const SizedBox(height: 16), // Bölümler arası tutarlı boşluk (Stat/Duyuru -> Detaylar)

                  // 6. 3 Temel Widget (Dikey Akış - Kartsız)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // A. Yaklaşan Ödemeler
                        _buildSectionHeader(
                          context,
                          isTr ? 'Yaklaşan Ödemeler' : 'Upcoming Payments',
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: fullWidth,
                          height: widgetHeight,
                          child: DueDateRadarWidget(
                            size: HomeWidgetSize.large,
                            selectedVaultId: activeVaultId,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // B. Harcama Analitiği
                        _buildSectionHeader(
                          context,
                          isTr ? 'Harcama Analitiği' : 'Spending Analytics',
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: fullWidth,
                          height: widgetHeight,
                          child: SpendingGiantsWidget(
                            size: HomeWidgetSize.large,
                            selectedVaultId: activeVaultId,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // C. Son İşlemler
                        _buildSectionHeader(
                          context,
                          isTr ? 'Son İşlemler' : 'Recent Transactions',
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: fullWidth,
                          height: widgetHeight,
                          child: TimelineActivityWidget(
                            size: HomeWidgetSize.large,
                            selectedVaultId: activeVaultId,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Alt boşluk (Bottom navbar altına taşmamak için)
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGeneralStatsCard(
    BuildContext context,
    double income,
    double expense,
    double net,
    String currencySymbol,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = Localizations.localeOf(context).languageCode;
    final isTr = locale == 'tr';
    final netColor = net >= 0 ? AppColors.getIncome(context) : AppColors.getExpense(context);
    final scalingFactor = (MediaQuery.of(context).size.height / 812.0).clamp(0.85, 1.0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium, vertical: 6),
      child: CustomCard(
        scalingFactor: scalingFactor,
        child: Row(
          children: [
            Expanded(
              child: _buildStatColumn(
                context,
                isTr ? 'Gelir /gün' : "Income /day",
                income,
                AppColors.getIncome(context),
                Icons.arrow_downward_rounded,
                currencySymbol,
              ),
            ),
            Container(
              width: 1,
              height: 36,
              color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
            ),
            Expanded(
              child: _buildStatColumn(
                context,
                isTr ? 'Gider /gün' : "Expense /day",
                expense,
                AppColors.getExpense(context),
                Icons.arrow_upward_rounded,
                currencySymbol,
              ),
            ),
            Container(
              width: 1,
              height: 36,
              color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
            ),
            Expanded(
              child: _buildStatColumn(
                context,
                isTr ? 'Net /gün' : "Net /day",
                net,
                netColor,
                net >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                currencySymbol,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(
    BuildContext context,
    String label,
    double amount,
    Color color,
    IconData icon,
    String currencySymbol,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 10, color: color.withValues(alpha: 0.8)),
            const SizedBox(width: 4),
            Text(
              label.toSafeUpperCase(context),
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                color: AppColors.getTextSecondary(context),
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 20, // Sabit yükseklik, birim veya rakam uzunluğuna göre kart boyunun değişmesini engeller.
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Text(
              CurrencyUtils.formatAmount(amount, currencySymbol: currencySymbol),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnnouncementsCard(BuildContext context, List<Announcement> announcements) {
    if (announcements.isEmpty) return const SizedBox.shrink();

    final activeColor = AppColors.getPrimary(context);
    final locale = Localizations.localeOf(context).languageCode;
    final List<String> items = announcements.map((a) => a.getLocalizedContent(locale)).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium, vertical: 6),
      child: GlassSurface(
        borderRadius: 20,
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.campaign_rounded,
              color: activeColor,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: items.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final text = entry.value;
                  return Padding(
                    padding: EdgeInsets.only(
                      top: idx == 0 ? 2.0 : 6.0,
                      bottom: idx == items.length - 1 ? 0.0 : 6.0,
                    ),
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.getTextPrimary(context),
                        height: 1.45,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 0, bottom: 8),
      child: Text(
        title.toSafeUpperCase(context),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: AppColors.getTextFaint(context),
          letterSpacing: 2,
        ),
      ),
    );
  }
}
