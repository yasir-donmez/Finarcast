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

class ResetSetting extends ConsumerWidget {
  const ResetSetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final activeColor = SettingsListItems.getSettingColor(context, SettingType.reset, ref.watch(rotaryColorProvider));

    return SettingsListItems.buildSetting(
      icon: Icons.delete_forever_outlined,
      title: l10n.reset,
      onTap: () => _showResetDialog(context, l10n, ref, activeColor),
      activeColor: activeColor,
      context: context,
      isAction: true,
      isDestructive: true,
    );
  }

  void _showResetDialog(BuildContext context, AppLocalizations l10n, WidgetRef ref, Color activeColor) {
    showCustomDialog(
      context: context,
      accentColor: activeColor,
      title: l10n.resetDataTitle,
      content: l10n.resetDataDesc,
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
            
            // 1. Veritabanını temizle
            await DatabaseService.clearAllData();
            
            // 2. Provider'ları invalidate et (Arayüzün yenilenmesi için)
            ref.invalidate(transactionsStreamProvider);
            ref.invalidate(vaultsStreamProvider);
            ref.invalidate(settingsProvider);
            
            if (context.mounted) {
              Navigator.pop(context);
              CustomNotification.success(context, l10n.resetSuccess);
            }
          },
        ),
      ],
    );
  }
}
