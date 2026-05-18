import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/auth_service.dart';
import '../../../dashboard/dashboard_providers.dart';
import '../profile_list_items.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/precision_dialog.dart';
import '../../../auth/screens/auth_screen.dart';

class AuthSetting extends ConsumerWidget {
  const AuthSetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);
    final user = authService.currentUser;
    final activeColor = ProfileListItems.getSettingColor(context, SettingType.auth, ref.watch(rotaryColorProvider));
    final l10n = AppLocalizations.of(context)!;

    if (user == null) {
      return ProfileListItems.buildSetting(
        icon: Icons.login_outlined,
        title: "Giriş Yap / Kayıt Ol",
        trailing: "Oturum Açın",
        onTap: () {
          // Giriş ekranına kesin yönlendirme yapalım
          Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const AuthScreen()),
            (route) => false,
          );
        },
        activeColor: activeColor,
        context: context,
      );
    }

    return ProfileListItems.buildSetting(
      icon: Icons.account_circle_outlined,
      title: "Oturum Ayarları",
      trailing: user.email?.split('@').first ?? "Hesabım",
      onTap: () => _showAuthOptions(context, ref, user.email ?? "", activeColor, l10n),
      activeColor: activeColor,
      context: context,
    );
  }

  void _showAuthOptions(BuildContext context, WidgetRef ref, String email, Color activeColor, AppLocalizations l10n) {
    showPrecisionDialog(
      context: context,
      title: "Oturum Bilgileri",
      content: "Bağlı Hesap: $email\n\nOturumu kapatmak istediğinize emin misiniz?",
      actions: [
        PrecisionDialogAction(
          label: l10n.cancel,
          onTap: () => Navigator.pop(context),
        ),
        PrecisionDialogAction(
          label: "Çıkış Yap",
          onTap: () async {
            await ref.read(authServiceProvider).signOut();
            if (context.mounted) Navigator.pop(context);
          },
          isPrimary: true,
        ),
      ],
    );
  }
}
