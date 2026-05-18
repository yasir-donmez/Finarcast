import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/precision_dialog.dart';
import '../../../../l10n/app_localizations.dart';
import '../profile_list_items.dart';
import '../../../../core/providers/db_providers.dart';
import '../../../../core/providers/settings_provider.dart';
import '../../../../core/database/database_service.dart';
import '../../../../shared/widgets/precision_notification.dart';
import '../../../dashboard/dashboard_providers.dart';

class ResetSetting extends ConsumerWidget {
  const ResetSetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return ProfileListItems.buildSetting(
      icon: Icons.delete_forever_outlined,
      title: "Verileri Sıfırla",
      onTap: () => _showResetDialog(context, l10n, ref),
      activeColor: ProfileListItems.getSettingColor(context, SettingType.reset, ref.watch(rotaryColorProvider)),
      context: context,
      isAction: true,
    );
  }

  void _showResetDialog(BuildContext context, AppLocalizations l10n, WidgetRef ref) {
    showPrecisionDialog(
      context: context,
      title: "Verileri Sıfırla?",
      content: "Tüm finansal verileriniz ve ayarlarınız kalıcı olarak silinecek. Bu işlem geri alınamaz.",
      actions: [
        PrecisionDialogAction(
          label: "İptal",
          onTap: () => Navigator.pop(context),
          isPrimary: false,
        ),
        PrecisionDialogAction(
          label: "Hepsini Sil",
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
              PrecisionNotification.success(context, "Tüm veriler ve ayarlar başarıyla sıfırlandı.");
            }
          },
        ),
      ],
    );
  }
}
