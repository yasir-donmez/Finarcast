import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/settings_provider.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../shared/widgets/precision_action.dart';
import '../../../../shared/widgets/precision_toggle.dart';
import '../../../../shared/widgets/precision_animated_icon.dart';
import '../../../dashboard/dashboard_providers.dart';

// Genişleme durumunu yöneten basit bir provider
final _locationExpandedProvider = StateProvider.autoDispose<bool>((ref) => false);

class LocationSetting extends ConsumerWidget {
  const LocationSetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLocationEnabled = ref.watch(settingsProvider.select((s) => s.isLocationEnabled));
    final activeColor = ref.watch(rotaryColorProvider);
    final isExpanded = ref.watch(_locationExpandedProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PrecisionAction(
          onTap: () {
            HapticFeedback.selectionClick();
            ref.read(_locationExpandedProvider.notifier).state = !isExpanded;
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
                    isActive: isLocationEnabled,
                    activeIcon: Icons.location_on_rounded,
                    inactiveIcon: Icons.location_off_rounded,
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
                        "Konum Servisleri",
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
                          isLocationEnabled ? "Aktif" : "Kapalı",
                          key: ValueKey(isLocationEnabled),
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
                  value: isLocationEnabled,
                  onChanged: (val) {
                    HapticFeedback.mediumImpact();
                    ref.read(settingsProvider.notifier).toggleLocation(val);
                  },
                  activeColor: activeColor,
                  activeIcon: Icons.location_on_rounded,
                  inactiveIcon: Icons.location_off_rounded,
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
                      "Harcamalarınızın nerede yapıldığını otomatik olarak kaydeder. "
                      "Bu sayede harcama alışkanlıklarınızı harita üzerinden analiz edebilirsiniz.",
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
