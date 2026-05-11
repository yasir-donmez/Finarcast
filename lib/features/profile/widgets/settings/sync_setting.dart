import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/settings_provider.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../shared/widgets/precision_action.dart';
import '../../../../shared/widgets/precision_toggle.dart';
import '../../../../shared/widgets/precision_animated_icon.dart';
import '../../../dashboard/dashboard_providers.dart';

final _syncExpandedProvider = StateProvider.autoDispose<bool>((ref) => false);

class SyncSetting extends ConsumerWidget {
  const SyncSetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSyncEnabled = ref.watch(settingsProvider.select((s) => s.isSyncEnabled));
    final activeColor = ref.watch(rotaryColorProvider);
    final isExpanded = ref.watch(_syncExpandedProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PrecisionAction(
          onTap: () {
            HapticFeedback.selectionClick();
            ref.read(_syncExpandedProvider.notifier).state = !isExpanded;
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
                  child: PrecisionAnimatedIcon(
                    isActive: isSyncEnabled,
                    activeIcon: Icons.cloud_done_rounded,
                    inactiveIcon: Icons.cloud_sync_rounded,
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
                          isSyncEnabled ? "Aktif" : "Kapalı",
                          key: ValueKey(isSyncEnabled),
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
                PrecisionToggle(
                  value: isSyncEnabled,
                  onChanged: (val) {
                    HapticFeedback.mediumImpact();
                    ref.read(settingsProvider.notifier).toggleSync(val);
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
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.getInnerSurface(context),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "Verileriniz Supabase bulut altyapısı ile anlık olarak yedeklenir. "
                      "Uygulamayı silseniz bile hesabınıza giriş yaparak verilerinizi geri getirebilirsiniz.",
                      style: TextStyle(
                        color: AppColors.getTextSecondary(context),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
