import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../../core/theme/app_constants.dart';
import '../../../core/services/notification_service.dart';
import '../../../l10n/app_localizations.dart';
import '../vaults_providers.dart';
import '../../dashboard/dashboard_providers.dart';
import '../../transactions/add_transaction_screen.dart';
import '../../../shared/widgets/precision_surface.dart';
import 'precision_transaction_card.dart';

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

  String _getRecurrenceText(int periodType) {
    switch (periodType) {
      case 0: return "Tek Seferlik";
      case 8: return "Günlük";
      case 9: return "2 Günde Bir";
      case 10: return "3 Günde Bir";
      case 1: return "Haftalık";
      case 4: return "2 Haftada Bir";
      case 5: return "3 Haftada Bir";
      case 2: return "Aylık";
      case 6: return "3 Ayda Bir";
      case 7: return "6 Ayda Bir";
      case 3: return "Yıllık";
      default: return "Tek Seferlik";
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = ref.watch(rotaryColorProvider);
    final allTransactions = ref.watch(vaultTransactionsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    
    // Sadece bildirimleri açık olan aktif işlemleri filtrele
    final notifications = allTransactions.where((tx) => tx.isNotificationEnabled).toList();

    // Zamanı geçmiş (tetiklenmiş) alarmları filtrele
    final now = DateTime.now();
    final triggeredNotifications = <Map<String, dynamic>>[];

    for (final tx in notifications) {
      final reminderTime = calculateTransactionReminderDateTime(tx);
      if (reminderTime.isBefore(now)) {
        triggeredNotifications.add({'tx': tx, 'time': reminderTime});
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
              color: Colors.redAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.redAccent.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.redAccent,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "SİSTEM BİLDİRİM İZİNLERİ KAPALI!\nLütfen telefon ayarlarınızdan Finarcast'e bildirim izni verin, aksi halde alarmlarınız çalışmayacaktır.",
                    style: TextStyle(
                      color: isDark ? Colors.redAccent.shade100 : Colors.red.shade900,
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
            title: "Geçmiş Bildirim Yok",
            subtitle: "Daha önce tetiklenmiş herhangi bir işlem alarmı geçmişi bulunmuyor.",
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: activeColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_off_rounded,
              size: 28,
              color: activeColor.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: AppColors.getTextPrimary(context),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              color: (isDark ? Colors.white : Colors.black).withValues(alpha: isDark ? 0.45 : 0.65),
            ),
          ),
        ],
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
    final dateStr = "${reminderTime.day} ${_getMonthName(reminderTime.month)}";
    final categoryName = localizedCategoryName(tx.categoryId, l10n) ?? tx.name;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: PrecisionSurface(
        padding: const EdgeInsets.all(14),
        borderRadius: 16,
        isGlass: true,
        blur: 10,
        child: InkWell(
          onTap: () => _navigateToEdit(tx),
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              // Sol Kategori İkonu
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: tx.color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: tx.color.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Icon(
                  tx.icon,
                  color: tx.color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              
              // Orta Metin Alanı
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            tx.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.getTextPrimary(context),
                            ),
                          ),
                        ),
                        Text(
                          timeStr,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: activeColor.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "$categoryName • ${_getRecurrenceText(tx.periodType)} • $dateStr",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.getTextSecondary(context),
                            ),
                          ),
                        ),
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
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToEdit(TransactionUI tx) {
    if (tx.dbId == null) return;
    
    // Düzenleme ekranını aç
    final currentVaultIds = tx.groupIds
        .map((vId) => int.parse(vId.replaceFirst('v_', '')))
        .toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionScreen(
          initialId: tx.dbId,
          initialName: tx.name,
          initialAmount: tx.amount,
          initialMinAmount: tx.minAmount,
          initialMaxAmount: tx.maxAmount,
          initialIsIncome: tx.isIncome,
          initialVaultIds: currentVaultIds,
          initialCategoryId: tx.categoryId,
          initialNote: tx.note,
          initialCurrency: tx.currency,
          initialPeriodType: tx.periodType,
          initialRecurrenceDay: tx.recurrenceDay,
          initialRecurrenceDate: tx.recurrenceDate,
          initialRecurrenceDuration: tx.recurrenceDuration,
          initialIsNotificationEnabled: tx.isNotificationEnabled,
          initialNotificationReminderDays: tx.notificationReminderDays,
          initialNotificationHour: tx.notificationHour,
          initialNotificationMinute: tx.notificationMinute,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      "Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran", 
      "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık"
    ];
    if (month >= 1 && month <= 12) {
      return months[month - 1];
    }
    return "";
  }
}
