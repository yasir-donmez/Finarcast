import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/providers/settings_provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/sync_coordinator.dart';
import '../../../../core/services/subscription_service.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../shared/widgets/clickable_action.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../../../shared/widgets/custom_switch.dart';
import '../../../../shared/widgets/custom_animated_icon.dart';
import '../../../../shared/widgets/custom_dialog.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_notification.dart';
import '../../../home/home_providers.dart';
import '../settings_list_items.dart';
import '../../../subscription/widgets/pro_upgrade_sheet.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/animated_premium_badge.dart';

final _syncExpandedProvider = StateProvider.autoDispose<bool>((ref) => false);

class SyncSetting extends ConsumerStatefulWidget {
  const SyncSetting({super.key});

  @override
  ConsumerState<SyncSetting> createState() => _SyncSettingState();
}

class _SyncSettingState extends ConsumerState<SyncSetting> {
  String? _lastSyncTime;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _loadLastSyncTime();
  }

  Future<void> _loadLastSyncTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _lastSyncTime = prefs.getString('last_sync_time');
      });
    } catch (_) {}
  }

  String _formatLastSyncTime(String? isoString) {
    final l10n = AppLocalizations.of(context)!;
    if (isoString == null) return l10n.noSyncYet;
    final dateTime = DateTime.tryParse(isoString)?.toLocal();
    if (dateTime == null) return l10n.noSyncYet;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final syncDay = DateTime(dateTime.year, dateTime.month, dateTime.day);

    final timeStr = DateFormat('HH:mm').format(dateTime);

    if (syncDay == today) {
      return l10n.syncToday(timeStr);
    } else if (syncDay == yesterday) {
      return l10n.syncYesterday(timeStr);
    } else {
      return "${DateFormat('dd.MM.yyyy').format(dateTime)} $timeStr";
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSyncEnabled = ref.watch(settingsProvider.select((s) => s.isSyncEnabled));
    final isLoggedIn = ref.watch(authServiceProvider).currentUser != null;
    final activeColor = SettingsListItems.getSettingColor(context, SettingType.sync, ref.watch(rotaryColorProvider));
    final isExpanded = ref.watch(_syncExpandedProvider);
    final subscription = ref.watch(subscriptionServiceProvider);
    final isPro = subscription.isPro;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClickableAction(
          onTap: () {
            HapticFeedback.selectionClick();
            ref.read(_syncExpandedProvider.notifier).state = !isExpanded;
            if (!isExpanded) {
              _loadLastSyncTime(); // Panel açıldığında en güncel zamanı çek
            }
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
                  child: CustomAnimatedIcon(
                    isActive: isPro && isLoggedIn && isSyncEnabled,
                    activeIcon: Icons.cloud_done_outlined,
                    inactiveIcon: Icons.cloud_off_outlined,
                    color: activeColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.cloudSync,
                        style: TextStyle(
                          color: AppColors.getTextPrimary(context),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        layoutBuilder: (currentChild, previousChildren) => Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            ...previousChildren,
                            if (currentChild != null) currentChild,
                          ],
                        ),
                        transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                        child: !isPro
                            ? const AnimatedPremiumBadge(
                                key: ValueKey('premium-badge'),
                              )
                            : Text(
                                !isLoggedIn
                                    ? l10n.loginRequiredLabel
                                    : (isSyncEnabled ? l10n.active : l10n.disabled),
                                key: ValueKey('$isLoggedIn-$isSyncEnabled'),
                                style: TextStyle(
                                  color: AppColors.getTextSecondary(context).withValues(alpha: 0.5),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
                CustomSwitch(
                  value: isPro && isLoggedIn && isSyncEnabled,
                  onChanged: (val) async {
                    HapticFeedback.mediumImpact();
                    if (!isPro) {
                      _showPremiumRequiredDialog(context, l10n);
                      return;
                    }
                    if (!isLoggedIn) {
                      _showLoginRequiredDialog(context, activeColor, l10n);
                      return;
                    }
                    await ref.read(settingsProvider.notifier).toggleSync(val);
                    _loadLastSyncTime();
                  },
                  activeColor: activeColor,
                  activeIcon: Icons.cloud_done_rounded,
                  inactiveIcon: Icons.cloud_off_rounded,
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
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: CustomCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (isPro && isLoggedIn && isSyncEnabled) ...[
                                Row(
                                  children: [
                                    Icon(Icons.sync_outlined, size: 16, color: activeColor),
                                    const SizedBox(width: 8),
                                    Text(
                                      l10n.syncStatus,
                                      style: TextStyle(
                                        color: AppColors.getTextPrimary(context),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  l10n.lastSyncLabel(_formatLastSyncTime(_lastSyncTime)),
                                  style: TextStyle(
                                    color: AppColors.getTextSecondary(context),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.syncBackgroundDesc,
                                  style: TextStyle(
                                    color: AppColors.getTextSecondary(context).withValues(alpha: 0.6),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    height: 1.4,
                                  ),
                                ),
                              ] else ...[
                                Text(
                                  l10n.syncCloudDesc,
                                  style: TextStyle(
                                    color: AppColors.getTextSecondary(context),
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      if (isPro && isLoggedIn && isSyncEnabled) ...[
                        const SizedBox(height: 16),
                        CustomButton(
                          label: _isSyncing ? l10n.syncing : l10n.syncNow,
                          height: 48,
                          fontSize: 13,
                          onTap: () async {
                            if (_isSyncing) return;
                            HapticFeedback.mediumImpact();
                            setState(() => _isSyncing = true);
                            final success = await SyncCoordinator.syncNow(l10n);
                            await _loadLastSyncTime();
                            setState(() => _isSyncing = false);
                            if (context.mounted) {
                              final result = SyncCoordinator.lastResult;
                              if (success && result != null && result.isFullySuccessful) {
                                CustomNotification.success(context, result.getLocalizedSummary(l10n));
                              } else if (result != null && result.hasPartialErrors) {
                                CustomNotification.success(context, l10n.syncPartialSuccess(result.getLocalizedSummary(l10n)));
                              } else {
                                final errorDetail = SyncCoordinator.lastError ?? l10n.syncConnectionError;
                                CustomNotification.error(context, l10n.syncFailed(errorDetail));
                              }
                            }
                          },
                          activeColor: activeColor,
                        ),
                      ],
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  void _showLoginRequiredDialog(BuildContext context, Color activeColor, AppLocalizations l10n) {
    showCustomDialog(
      context: context,
      accentColor: activeColor,
      title: l10n.loginRequiredTitle,
      content: l10n.loginRequiredSyncDesc,
      actions: [
        PrecisionDialogAction(
          label: l10n.cancel,
          onTap: () => Navigator.pop(context),
          isPrimary: false,
        ),
        PrecisionDialogAction(
          label: l10n.authLogin,
          onTap: () async {
            Navigator.pop(context);
            await ref.read(authControllerProvider.notifier).exitGuestMode();
          },
          isPrimary: true,
        ),
      ],
    );
  }

  void _showPremiumRequiredDialog(BuildContext context, AppLocalizations l10n) {
    showCustomDialog(
      context: context,
      accentColor: const Color(0xFFFFB300), // Altın rengi
      title: l10n.premiumRequired,
      content: l10n.premiumSyncDesc,
      actions: [
        PrecisionDialogAction(
          label: l10n.later,
          onTap: () => Navigator.pop(context),
          isPrimary: false,
        ),
        PrecisionDialogAction(
          label: l10n.upgradeToPro,
          onTap: () {
            Navigator.pop(context);
            ProUpgradeSheet.show(context);
          },
          isPrimary: true,
        ),
      ],
    );
  }
}
