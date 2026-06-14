import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/custom_dialog.dart';
import '../../../../l10n/app_localizations.dart';
import '../settings_list_items.dart';
import '../../../../core/providers/db_providers.dart';
import '../../../../core/providers/settings_provider.dart';
import '../../../../core/database/database_service.dart';
import '../../../../shared/widgets/custom_notification.dart';
import '../../../home/home_providers.dart';
import '../../../home/providers/home_widget_layout_provider.dart';
import '../../../vaults/widgets/in_app_notifications_sheet.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../../../shared/widgets/clickable_action.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/services/sync_coordinator.dart';

final _resetExpandedProvider = StateProvider.autoDispose<bool>((ref) => false);
final _deleteCloudSelectedProvider = StateProvider.autoDispose<bool>((ref) => true);

class ResetSetting extends ConsumerWidget {
  const ResetSetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final activeColor = SettingsListItems.getSettingColor(context, SettingType.reset, ref.watch(rotaryColorProvider));
    final isExpanded = ref.watch(_resetExpandedProvider);
    final user = Supabase.instance.client.auth.currentUser;
    final isLoggedIn = user != null;
    final shouldDeleteCloud = ref.watch(_deleteCloudSelectedProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClickableAction(
          onTap: () {
            HapticFeedback.selectionClick();
            ref.read(_resetExpandedProvider.notifier).state = !isExpanded;
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
                  child: Icon(Icons.delete_forever_outlined, color: activeColor, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    l10n.reset,
                    style: TextStyle(
                      color: activeColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
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
                      // Uyarı Kartı
                      CustomCard(
                        backgroundColor: activeColor.withValues(alpha: 0.05),
                        borderColor: activeColor.withValues(alpha: 0.1),
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: activeColor, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                l10n.resetDataDesc,
                                style: TextStyle(
                                  color: AppColors.getTextPrimary(context),
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Eğer kullanıcı giriş yapmışsa bulut yedekleme seçeneği
                      if (isLoggedIn) ...[
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            ref.read(_deleteCloudSelectedProvider.notifier).state = !shouldDeleteCloud;
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: activeColor.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: shouldDeleteCloud ? activeColor.withValues(alpha: 0.2) : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  shouldDeleteCloud ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                                  color: shouldDeleteCloud ? activeColor : AppColors.getTextSecondary(context).withValues(alpha: 0.5),
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    l10n.resetCloudBackup,
                                    style: TextStyle(
                                      color: AppColors.getTextPrimary(context),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Sıfırlama Butonu
                      CustomButton(
                        label: isLoggedIn 
                            ? (shouldDeleteCloud ? l10n.resetDeviceAndCloud : l10n.resetOnlyDevice)
                            : l10n.deleteAll,
                        onTap: () => _confirmReset(context, ref, isLoggedIn, shouldDeleteCloud, user?.id, activeColor, l10n),
                        isPrimary: true,
                        activeColor: activeColor,
                        height: 52,
                        fontSize: 14,
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  void _confirmReset(
    BuildContext context, 
    WidgetRef ref, 
    bool isLoggedIn, 
    bool shouldDeleteCloud, 
    String? userId, 
    Color activeColor,
    AppLocalizations l10n,
  ) {
    showCustomDialog(
      context: context,
      accentColor: activeColor,
      title: l10n.resetDataTitle,
      content: isLoggedIn && shouldDeleteCloud 
          ? '${l10n.resetDataDesc} (Supabase bulut verileri dahil.)'
          : l10n.resetDataDesc,
      actions: [
        PrecisionDialogAction(
          label: l10n.cancel,
          onTap: () => Navigator.pop(context),
          isPrimary: false,
        ),
        PrecisionDialogAction(
          label: l10n.deleteAll,
          onTap: () async {
            HapticFeedback.vibrate();
            
            // Bulut sıfırlama seçildiyse ve giriş yapılmışsa önce bulutu temizle
            if (isLoggedIn && shouldDeleteCloud && userId != null) {
              try {
                await SyncCoordinator.clearRemoteData(userId);
              } catch (e) {
                debugPrint('Bulut sıfırlama hatası: $e');
              }
            }
            
            // Yerel verileri temizle
            await DatabaseService.clearAllData();
            
            // Sağlayıcıları sıfırla
            ref.invalidate(transactionsStreamProvider);
            ref.invalidate(vaultsStreamProvider);
            ref.invalidate(settingsProvider);
            ref.invalidate(widgetLayoutProvider);
            ref.invalidate(dismissedNotificationsProvider);
            
            if (context.mounted) {
              Navigator.pop(context); // Diyalogu kapat
              CustomNotification.success(context, l10n.resetSuccess);
            }
          },
        ),
      ],
    );
  }
}
