import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/settings_provider.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../shared/widgets/clickable_action.dart';
import '../../../../shared/widgets/custom_switch.dart';
import '../../../../shared/widgets/custom_animated_icon.dart';
import '../../../home/home_providers.dart';
import '../settings_list_items.dart';
import '../../../../l10n/app_localizations.dart';

final _notifExpandedProvider = StateProvider.autoDispose<bool>((ref) => false);

class NotificationSetting extends ConsumerWidget {
  const NotificationSetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEnabled = ref.watch(settingsProvider.select((s) => s.isNotificationsEnabled));
    final activeColor = SettingsListItems.getSettingColor(context, SettingType.notification, ref.watch(rotaryColorProvider));
    final isExpanded = ref.watch(_notifExpandedProvider);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClickableAction(
          onTap: () {
            HapticFeedback.selectionClick();
            ref.read(_notifExpandedProvider.notifier).state = !isExpanded;
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
                    isActive: isEnabled,
                    activeIcon: Icons.notifications_active_outlined,
                    inactiveIcon: Icons.notifications_off_outlined,
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
                        l10n.notifications,
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
                          isEnabled ? l10n.showOnPhone : l10n.appOnly,
                          key: ValueKey(isEnabled),
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
                  value: isEnabled,
                  onChanged: (val) {
                    HapticFeedback.mediumImpact();
                    ref.read(settingsProvider.notifier).toggleNotifications(val);
                  },
                  activeColor: activeColor,
                  activeIcon: Icons.notifications_active_rounded,
                  inactiveIcon: Icons.notifications_off_rounded,
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
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.getInnerSurface(context),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.notificationDesc,
                          style: TextStyle(
                            color: AppColors.getTextSecondary(context),
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),

                  ],
                ),
              ),
            )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
