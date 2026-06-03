import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/settings_provider.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/inline_picker.dart';
import '../../../../shared/widgets/clickable_action.dart';
import '../../../home/home_providers.dart';
import '../settings_list_items.dart';
import '../../../../core/services/subscription_service.dart';
import '../../../../shared/widgets/custom_dialog.dart';
import '../../../subscription/widgets/pro_upgrade_sheet.dart';

final _retentionExpandedProvider = StateProvider.autoDispose<bool>((ref) => false);

class RetentionSetting extends ConsumerWidget {
  const RetentionSetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final retentionDays = ref.watch(settingsProvider.select((s) => s.dataRetentionDays));
    final activeColor = SettingsListItems.getSettingColor(context, SettingType.retention, ref.watch(rotaryColorProvider));
    final l10n = AppLocalizations.of(context)!;
    final isExpanded = ref.watch(_retentionExpandedProvider);

    final options = [
      {'label': l10n.oneMonth, 'days': 30},
      {'label': l10n.threeMonths, 'days': 90},
      {'label': l10n.sixMonths, 'days': 180},
      {'label': l10n.oneYear, 'days': 365},
      {'label': l10n.infinite, 'days': -1},
    ];

    final currentIndex = options.indexWhere((opt) => opt['days'] == retentionDays);
    final currentLabel = currentIndex != -1 ? options[currentIndex]['label'] as String : '--';

    final subscription = ref.watch(subscriptionServiceProvider);
    final isPro = subscription.isPro;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClickableAction(
          onTap: () {
            HapticFeedback.selectionClick();
            ref.read(_retentionExpandedProvider.notifier).state = !isExpanded;
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
                  child: Icon(Icons.visibility_off_outlined, color: activeColor, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.dataRetention,
                        style: TextStyle(
                          color: AppColors.getTextPrimary(context),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (!isPro) ...[
                        const SizedBox(height: 2),
                        const Text(
                          "Premium",
                          style: TextStyle(
                            color: Colors.amber,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ] else
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
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.getInnerSurface(context),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          l10n.dataRetentionDetail,
                          style: TextStyle(
                            color: AppColors.getTextSecondary(context),
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Text(
                            l10n.retentionPeriodLabel,
                            style: TextStyle(
                              color: AppColors.getTextPrimary(context),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Stack(
                            children: [
                              InlinePicker(
                                width: 100,
                                height: 60,
                                items: options.map((opt) => opt['label'] as String).toList(),
                                selectedIndex: currentIndex != -1 ? currentIndex : 1,
                                onChanged: (index) {
                                  ref.read(settingsProvider.notifier).setDataRetention(options[index]['days'] as int);
                                },
                              ),
                              if (!isPro)
                                Positioned.fill(
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      HapticFeedback.heavyImpact();
                                      _showPremiumRequiredDialog(context, l10n);
                                    },
                                  ),
                                ),
                            ],
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

  void _showPremiumRequiredDialog(BuildContext context, AppLocalizations l10n) {
    showCustomDialog(
      context: context,
      accentColor: const Color(0xFFFFB300), // Altın rengi
      title: l10n.premiumRequired,
      content: l10n.premiumRetentionDesc,
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
