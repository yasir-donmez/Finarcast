import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import '../../../core/theme/app_constants.dart';
import '../../../core/services/notification_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/utils/string_utils.dart';
import '../vaults_providers.dart';
import '../../home/home_providers.dart';
import '../../transactions/transaction_builder_screen.dart';
import '../../../core/utils/route_transitions.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/clickable_action.dart';
import '../../../core/utils/category_utils.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/providers/db_providers.dart';
import 'detail_sheet.dart';
import '../../../shared/widgets/custom_bottom_sheet.dart';
import '../../../shared/widgets/custom_dialog.dart';
import '../../../core/database/database_service.dart';
import '../../../core/domain/recurrence_engine.dart';

class InAppNotificationsSheet extends ConsumerStatefulWidget {
  const InAppNotificationsSheet({super.key});

  @override
  ConsumerState<InAppNotificationsSheet> createState() => _InAppNotificationsSheetState();
}

class _InAppNotificationsSheetState extends ConsumerState<InAppNotificationsSheet> {
  bool _isSystemNotificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _checkSystemPermissions();
    // Sayfa açıldığında tüm bildirimleri görülmüş olarak işaretle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(lastCheckedNotificationsTimeProvider.notifier).updateToNow();
    });
  }

  Future<void> _checkSystemPermissions() async {
    final enabled = await NotificationService().areNotificationsEnabled();
    if (mounted) {
      setState(() {
        _isSystemNotificationsEnabled = enabled;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final activeColor = ref.watch(rotaryColorProvider);
    final templates = ref.watch(allTemplatesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final customCategories = ref.watch(customCategoriesProvider);

    final now = DateTime.now();
    final triggeredNotifications = <Map<String, dynamic>>[];

    for (final template in templates) {
      if (!template.isNotificationEnabled || template.isPaused || template.isArchived) continue;

      // Generate occurrences from template.startDate to now + 1 day
      final dates = RecurrenceEngine.occurrenceDates(
        template.recurrenceRule,
        now.add(const Duration(days: 1)),
      );

      for (final date in dates) {
        final DateTime targetDate = date.subtract(Duration(days: template.notificationReminderDays));
        final DateTime reminderTime = DateTime(
          targetDate.year,
          targetDate.month,
          targetDate.day,
          template.notificationHour,
          template.notificationMinute,
        );

        if (reminderTime.isBefore(now)) {
          final txUi = TransactionUI(
            id: 'template_notif_${template.id}_${date.year}${date.month}${date.day}',
            name: template.title,
            icon: CategoryUtils.getCategoryIcon(
              categoryId: template.categoryId,
              customCategories: customCategories,
              iconCode: template.iconCode,
            ),
            color: CategoryUtils.getCategoryColor(
              categoryId: template.categoryId,
              customCategories: customCategories,
            ),
            amount: template.amount,
            minAmount: template.minAmount,
            maxAmount: template.maxAmount,
            isIncome: template.isIncome,
            date: date,
            dbId: template.id,
            categoryId: template.categoryId,
            iconCode: template.iconCode,
            note: template.note,
            currency: template.currency,
            status: 0,
            isReviewed: false,
            templateId: template.id,
            occurrenceDate: date,
            groupIds: [if (template.vaultId != null) 'v_${template.vaultId}'],
          );

          triggeredNotifications.add({'tx': txUi, 'time': reminderTime});
        }
      }
    }

    // En yeniden en eskiye sırala
    triggeredNotifications.sort((a, b) => (b['time'] as DateTime).compareTo(a['time'] as DateTime));

    // En fazla 10 adet listele
    final displayedNotifications = triggeredNotifications.take(10).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!_isSystemNotificationsEnabled) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.error.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.error,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.systemNotificationsDisabled,
                    style: TextStyle(
                      color: AppColors.error,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],



        if (displayedNotifications.isEmpty)
          _buildEmptyState(
            activeColor: activeColor,
            isDark: isDark,
            title: l10n.noNotificationHistory,
            subtitle: l10n.noNotificationHistoryDesc,
          )
        else
          Column(
            children: displayedNotifications.map((item) {
              final tx = item['tx'] as TransactionUI;
              final reminderTime = item['time'] as DateTime;
              return _buildNotificationCard(tx, reminderTime, activeColor, l10n, context);
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildEmptyState({
    required Color activeColor,
    required bool isDark,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_off_rounded,
              size: 48,
              color: AppColors.getTextSecondary(context).withValues(alpha: 0.15),
            ),
            const SizedBox(height: 12),
            Text(
              title.toSafeUpperCase(context),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: AppColors.getTextSecondary(context).withValues(alpha: 0.8),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.getTextSecondary(context).withValues(alpha: 0.5),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
    TransactionUI tx,
    DateTime reminderTime,
    Color activeColor,
    AppLocalizations l10n,
    BuildContext context,
  ) {
    // Hatırlatma zamanının güzel bir şekilde formatlanması
    final timeStr = "${reminderTime.hour.toString().padLeft(2, '0')}:${reminderTime.minute.toString().padLeft(2, '0')}";
    final customCategories = ref.watch(customCategoriesProvider);
    final categoryName = CategoryUtils.getCategoryName(
      categoryId: tx.categoryId,
      context: context,
      customCategories: customCategories,
      fallbackTitle: tx.name,
    );

    // Kategori yolunu oluştur (Üst Kategori / Alt Kategori)
    final parentId = tx.categoryId?.split('_').take(2).join('_');
    final parentName = parentId != null
        ? CategoryUtils.getCategoryName(
            categoryId: parentId,
            context: context,
            customCategories: customCategories,
          )
        : null;

    // Eğer işlem adı kategori/alt kategori adıyla aynıysa üstte 'Kategori / Alt Kategori' gösterelim.
    // Farklı ise (özel bir isim girildiyse) özel ismi gösterelim.
    final bool isNameSameAsCategory = tx.name.toLowerCase().trim() == categoryName.toLowerCase().trim();
    final categoryAccentColor = AppColors.getAccentDeep(context, tx.color);
    
    final Widget titleWidget;
    if (isNameSameAsCategory && parentName != null && parentName != categoryName) {
      titleWidget = Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: parentName,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.getTextPrimary(context),
              ),
            ),
            TextSpan(
              text: ' / ',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.getTextSecondary(context).withValues(alpha: 0.5),
              ),
            ),
            TextSpan(
              text: categoryName,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: categoryAccentColor,
              ),
            ),
          ],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    } else {
      titleWidget = Text(
        tx.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: AppColors.getTextPrimary(context),
        ),
      );
    }

    // Tutar rengi (Gelir/Gider) ve tutar metni hesabı
    final amountColor = tx.isIncome
        ? AppColors.getIncome(context)
        : AppColors.getExpense(context);
    final String amountText = tx.minAmount != null && tx.maxAmount != null
        ? "${CurrencyUtils.formatAmount(tx.minAmount!, currencySymbol: tx.currency ?? "₺")} - ${CurrencyUtils.formatAmount(tx.maxAmount!, currencySymbol: tx.currency ?? "₺")}"
        : CurrencyUtils.formatAmount(tx.effectiveAmount, currencySymbol: tx.currency ?? "₺");

    // Kasaları ve notu yükle
    final vaults = ref.watch(allVaultsProvider);
    final attachedVaultNames = vaults
        .where((v) => tx.groupIds.contains('v_${v.id}'))
        .map((v) => v.name)
        .toList();
    final String vaultsText = attachedVaultNames.isNotEmpty
        ? attachedVaultNames.join(', ')
        : '';
    final String paymentDateStr;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final paymentDateOnly = DateTime(tx.date.year, tx.date.month, tx.date.day);
    final difference = paymentDateOnly.difference(today).inDays;

    final locale = Localizations.localeOf(context).toString();

    if (difference == 0) {
      paymentDateStr = l10n.today;
    } else if (difference == 1) {
      paymentDateStr = l10n.tomorrow;
    } else if (difference == -1) {
      paymentDateStr = l10n.yesterday;
    } else {
      paymentDateStr = DateFormat('d MMMM', locale).format(tx.date);
    }

    final String subtitleText = [
      l10n.paymentDate(paymentDateStr),
      if (vaultsText.isNotEmpty) vaultsText,
    ].join(' • ');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ClickableAction(
        onTap: () => _navigateToDetail(tx),
        borderRadius: BorderRadius.circular(12),
        scaleOnPress: 0.96,
        child: CustomCard(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          scalingFactor: 0.8,
          child: Row(
            children: [
              // Sol Kategori İkonu
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.getAccentDeep(context, tx.color).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  tx.icon,
                  color: AppColors.getAccentDeep(context, tx.color),
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              
              // Orta Metin Alanı
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleWidget,
                    const SizedBox(height: 2),
                    Text(
                      subtitleText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppColors.getTextSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Sağ Bölüm (Saat ve Tutar)
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        amountText,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                          color: amountColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        timeStr,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: AppColors.getAccentDeep(context, activeColor).withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: AppColors.getTextSecondary(context).withValues(alpha: 0.5),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToDetail(TransactionUI tx) {
    if (tx.dbId == null) return;
    
    // Önce bildirimler sayfasını kapatıyoruz
    Navigator.pop(context);

    // Async devam - context güvenli mi kontrol et
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await _openDetailSheet(tx);
    });
  }

  Future<void> _openDetailSheet(TransactionUI tx) async {
    // Kategori ismini oluştur
    final customCategories = ref.read(customCategoriesProvider);
    final categoryName = CategoryUtils.getCategoryName(
      categoryId: tx.categoryId,
      context: context,
      customCategories: customCategories,
      fallbackTitle: tx.name,
    );
    final parentId = tx.categoryId?.split('_').take(2).join('_');
    final parentName = parentId != null
        ? CategoryUtils.getCategoryName(
            categoryId: parentId,
            context: context,
            customCategories: customCategories,
          )
        : null;
    final categoryAccentColor = AppColors.getAccentDeep(context, tx.color);
    final Widget sheetTitle;
    if (parentName != null && parentName != categoryName) {
      sheetTitle = Text.rich(
        TextSpan(
          children: [
            TextSpan(text: parentName),
            TextSpan(
              text: ' / ',
              style: TextStyle(
                color: AppColors.getTextSecondary(context).withValues(alpha: 0.5),
              ),
            ),
            TextSpan(
              text: categoryName,
              style: TextStyle(
                color: categoryAccentColor,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w900,
          color: AppColors.getTextPrimary(context),
          letterSpacing: -0.8,
        ),
      );
    } else {
      sheetTitle = Text(
        categoryName,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w900,
          color: AppColors.getTextPrimary(context),
          letterSpacing: -0.8,
        ),
      );
    }

    final action = await CustomBottomSheet.show<DetailSheetAction>(
      context: context,
      title: sheetTitle,
      child: DetailSheet(
        transaction: tx,
      ),
    );

    if (!mounted) return;

    if (action == DetailSheetAction.edit) {
      final template = await DatabaseService.getTemplate(tx.dbId!);
      if (template == null) return;
      if (!mounted) return;

      final selectedVaultId = ref.read(selectedVaultProvider);
      final groups = ref.read(transactionGroupsProvider);
      final effectiveVaultId = selectedVaultId ?? (groups.isNotEmpty ? groups.first.id : null);
      int? currentVaultId = template.vaultId;

      if (currentVaultId == null && effectiveVaultId != null) {
        currentVaultId = int.tryParse(effectiveVaultId.replaceFirst('v_', ''));
      }

      Navigator.push(
        context,
        SlideUpPageRoute(
          child: TransactionBuilderScreen(
            initialId: template.id,
            initialName: template.title,
            initialAmount: template.amount,
            initialMinAmount: template.minAmount,
            initialMaxAmount: template.maxAmount,
            initialIsIncome: template.isIncome,
            initialVaultId: currentVaultId,
            initialCategoryId: template.categoryId,
            initialNote: template.note,
            initialCurrency: template.currency,
            initialPeriodType: template.periodType,
            initialRecurrenceDay: template.recurrenceDay,
            initialRecurrenceDate: template.recurrenceDate,
            initialTotalInstallments: template.totalInstallments,
            initialIsNotificationEnabled: template.isNotificationEnabled,            initialNotificationReminderDays: template.notificationReminderDays,
            initialNotificationHour: template.notificationHour,
            initialNotificationMinute: template.notificationMinute,
            isTemplateEdit: true,
          ),
          fullscreenDialog: true,
        ),
      );
    } else if (action == DetailSheetAction.delete) {
      final confirm = await showCustomDialog<bool>(
        context: context,
        accentColor: AppColors.error,
        title: AppLocalizations.of(context)!.permanentDelete,
        content: AppLocalizations.of(context)!.permanentDeleteDesc,
        actions: [
          PrecisionDialogAction(
            label: AppLocalizations.of(context)!.cancel,
            onTap: () => Navigator.pop(context, false),
            isPrimary: false,
          ),
          PrecisionDialogAction(
            label: AppLocalizations.of(context)!.ok,
            onTap: () => Navigator.pop(context, true),
            isPrimary: true,
          ),
        ],
      );
      if (confirm == true && mounted) {
        await DatabaseService.deleteTemplate(tx.dbId!);
        HapticFeedback.mediumImpact();
      }
    }
  }

}
