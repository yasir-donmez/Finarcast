import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/settings_provider.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/inline_picker.dart';
import '../../../../shared/widgets/clickable_action.dart';
import '../profile_list_items.dart';
import '../../../dashboard/dashboard_providers.dart';

final _purgeExpandedProvider = StateProvider.autoDispose<bool>((ref) => false);

class PurgeSetting extends ConsumerWidget {
  const PurgeSetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permanentDays = ref.watch(settingsProvider.select((s) => s.permanentDeletionDays));
    final l10n = AppLocalizations.of(context)!;
    final expenseColor = ProfileListItems.getSettingColor(context, SettingType.purge, ref.watch(rotaryColorProvider));
    final isExpanded = ref.watch(_purgeExpandedProvider);

    final options = [
      {'label': l10n.oneMonth, 'days': 30},
      {'label': l10n.threeMonths, 'days': 90},
      {'label': l10n.sixMonths, 'days': 180},
      {'label': l10n.oneYear, 'days': 365},
      {'label': l10n.infinite, 'days': -1},
    ];

    final currentIndex = options.indexWhere((opt) => opt['days'] == permanentDays);
    final currentLabel = currentIndex != -1 ? options[currentIndex]['label'] as String : '--';

    // Çeviri kontrolü (fallback)
    String title = "Kalıcı Veri Silme";
    try {
      // ignore: undefined_getter
      title = (l10n as dynamic).permanentDataDeletion ?? title;
    } catch (_) {}

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClickableAction(
          onTap: () {
            HapticFeedback.selectionClick();
            ref.read(_purgeExpandedProvider.notifier).state = !isExpanded;
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: expenseColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.delete_forever_outlined, color: expenseColor, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
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
                          currentLabel,
                          key: ValueKey(currentLabel),
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
                AnimatedRotation(
                  turns: isExpanded ? 0.25 : 0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutBack,
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: expenseColor.withValues(alpha: isExpanded ? 1.0 : 0.3),
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
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: expenseColor.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: expenseColor.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: expenseColor, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "Dikkat: Bu süre sonunda verileriniz cihazınızdan tamamen silinir ve bir daha geri getirilemez.",
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
                      Row(
                        children: [
                          Text(
                            "Temizleme Süresi:",
                            style: TextStyle(
                              color: AppColors.getTextPrimary(context),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          InlinePicker(
                            width: 100,
                            height: 60,
                            items: options.map((opt) => opt['label'] as String).toList(),
                            selectedIndex: currentIndex != -1 ? currentIndex : 4,
                            onChanged: (index) {
                              ref.read(settingsProvider.notifier).setPermanentDeletion(options[index]['days'] as int);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
