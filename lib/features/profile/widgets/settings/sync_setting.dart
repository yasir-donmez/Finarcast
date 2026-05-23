import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/providers/settings_provider.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/sync_coordinator.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../shared/widgets/clickable_action.dart';
import '../../../../shared/widgets/custom_switch.dart';
import '../../../../shared/widgets/custom_animated_icon.dart';
import '../../../../shared/widgets/custom_dialog.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_notification.dart';
import '../../../dashboard/dashboard_providers.dart';
import '../profile_list_items.dart';
import '../../../auth/screens/auth_screen.dart';

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
    if (isoString == null) return "Henüz eşitleme yapılmadı";
    final dateTime = DateTime.tryParse(isoString)?.toLocal();
    if (dateTime == null) return "Henüz eşitleme yapılmadı";

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final syncDay = DateTime(dateTime.year, dateTime.month, dateTime.day);

    final timeStr = DateFormat('HH:mm').format(dateTime);

    if (syncDay == today) {
      return "Bugün $timeStr";
    } else if (syncDay == yesterday) {
      return "Dün $timeStr";
    } else {
      return "${DateFormat('dd.MM.yyyy').format(dateTime)} $timeStr";
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSyncEnabled = ref.watch(settingsProvider.select((s) => s.isSyncEnabled));
    final isLoggedIn = ref.watch(authServiceProvider).currentUser != null;
    final activeColor = ProfileListItems.getSettingColor(context, SettingType.sync, ref.watch(rotaryColorProvider));
    final isExpanded = ref.watch(_syncExpandedProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClickableAction(
          onTap: () {
            HapticFeedback.selectionClick();
            if (!isLoggedIn) {
              _showLoginRequiredDialog(context, activeColor);
              return;
            }
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
                    color: !isLoggedIn 
                        ? AppColors.getTextSecondary(context).withValues(alpha: 0.05)
                        : activeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: CustomAnimatedIcon(
                    isActive: isLoggedIn && isSyncEnabled,
                    activeIcon: Icons.cloud_done_outlined,
                    inactiveIcon: !isLoggedIn ? Icons.lock_outline_rounded : Icons.cloud_off_outlined,
                    color: !isLoggedIn 
                        ? AppColors.getTextSecondary(context).withValues(alpha: 0.4) 
                        : activeColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Bulut Senkronizasyonu",
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
                        child: Text(
                          !isLoggedIn
                              ? "Giriş gerekli"
                              : (isSyncEnabled ? "Aktif" : "Kapalı"),
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
                  value: isLoggedIn && isSyncEnabled,
                  onChanged: (val) async {
                    HapticFeedback.mediumImpact();
                    if (!isLoggedIn) {
                      _showLoginRequiredDialog(context, activeColor);
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
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.getInnerSurface(context),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isLoggedIn && isSyncEnabled) ...[
                              Row(
                                children: [
                                  Icon(Icons.sync_outlined, size: 16, color: activeColor),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Senkronizasyon Durumu",
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
                                "Son Eşitleme: ${_formatLastSyncTime(_lastSyncTime)}",
                                style: TextStyle(
                                  color: AppColors.getTextSecondary(context),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Verileriniz arka planda otomatik olarak buluta yedeklenmektedir.",
                                style: TextStyle(
                                  color: AppColors.getTextSecondary(context).withValues(alpha: 0.6),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  height: 1.4,
                                ),
                              ),
                            ] else ...[
                              Text(
                                "Verileriniz Supabase bulut altyapısı ile anlık olarak yedeklenir. "
                                "Uygulamayı silseniz bile hesabınıza giriş yaparak verilerinizi geri getirebilirsiniz.",
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
                      if (isLoggedIn && isSyncEnabled) ...[
                        const SizedBox(height: 16),
                        CustomButton(
                          label: _isSyncing ? "VERİLER EŞİTLENİYOR..." : "ŞİMDİ SENKRONİZE ET",
                          height: 48,
                          fontSize: 13,
                          onTap: () async {
                            if (_isSyncing) return;
                            HapticFeedback.mediumImpact();
                            setState(() => _isSyncing = true);
                            await SyncCoordinator.syncNow();
                            await _loadLastSyncTime();
                            setState(() => _isSyncing = false);
                            if (context.mounted) {
                              CustomNotification.success(context, "Verileriniz başarıyla senkronize edildi.");
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

  void _showLoginRequiredDialog(BuildContext context, Color activeColor) {
    showCustomDialog(
      context: context,
      accentColor: activeColor,
      title: "Giriş Gerekli",
      content: "Bulut senkronizasyonunu aktifleştirerek verilerinizi yedeklemek için giriş yapmanız gerekmektedir.",
      actions: [
        PrecisionDialogAction(
          label: "İptal",
          onTap: () => Navigator.pop(context),
          isPrimary: false,
        ),
        PrecisionDialogAction(
          label: "Giriş Yap",
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const AuthScreen()),
              (route) => false,
            );
          },
          isPrimary: true,
        ),
      ],
    );
  }
}
