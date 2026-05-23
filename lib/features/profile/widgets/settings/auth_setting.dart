import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/auth_service.dart';
import '../../../dashboard/dashboard_providers.dart';
import '../profile_list_items.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/custom_dialog.dart';
import '../../../auth/screens/auth_screen.dart';
import '../../../../shared/widgets/custom_bottom_sheet.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../core/theme/app_constants.dart';

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
      onTap: () => _showAuthOptions(context, ref, user.email ?? "", activeColor, l10n),
      activeColor: activeColor,
      context: context,
    );
  }

  void _showAuthOptions(BuildContext context, WidgetRef ref, String email, Color activeColor, AppLocalizations l10n) {
    CustomBottomSheet.show(
      context: context,
      title: "Oturum Yönetimi",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          // E-posta Bilgisi ve Doğrulama Durumu Kartı
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: activeColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: activeColor.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Icon(Icons.email_rounded, color: activeColor, size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Giriş Yapılan Hesap",
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.getTextSecondary(context).withValues(alpha: 0.6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        email,
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.getTextPrimary(context),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Çıkış Yap Butonu
          CustomButton(
            label: "Oturumu Kapat",
            onTap: () {
              Navigator.pop(context); // Close BottomSheet
              showCustomDialog(
                context: context,
                accentColor: Colors.redAccent,
                title: "Çıkış Yap",
                content: "Oturumu kapatmak istediğinize emin misiniz?",
                actions: [
                  PrecisionDialogAction(
                    label: l10n.cancel,
                    onTap: () => Navigator.pop(context),
                    isPrimary: false,
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
            },
            isPrimary: true,
            activeColor: activeColor,
          ),
          const SizedBox(height: 12),

          // Hesabı Sil Butonu
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.pop(context); // Close BottomSheet
                showCustomDialog(
                  context: context,
                  accentColor: Colors.redAccent,
                  title: "Hesabımı Sil",
                  content: "Hesabınızı ve buluttaki tüm verilerinizi kalıcı olarak silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.",
                  actions: [
                    PrecisionDialogAction(
                      label: l10n.cancel,
                      onTap: () => Navigator.pop(context),
                      isPrimary: false,
                    ),
                    PrecisionDialogAction(
                      label: "Hesabımı Sil",
                      onTap: () async {
                        await ref.read(authServiceProvider).signOut();
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Hesap silme talebiniz alındı ve oturumunuz kapatıldı.'),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      },
                      isPrimary: true,
                    ),
                  ],
                );
              },
              child: Text(
                "Hesabımı Kalıcı Olarak Sil",
                style: TextStyle(
                  color: Colors.redAccent.withValues(alpha: 0.8),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
