import 'package:flutter/material.dart';
import '../../../core/theme/app_constants.dart';
import '../../../shared/widgets/clickable_action.dart';
import '../../../shared/widgets/custom_switch.dart';
import '../../../shared/widgets/custom_animated_icon.dart';

enum SettingType {
  membership,
  theme,
  colorTheme,
  background,
  language,
  currency,
  exchangeRate,
  notification,
  location,
  auth,
  retention,
  purge,
  sync,
  backup,
  export,
  reset,
  contact,
  about,
}

class ProfileListItems {
  static Color getSettingColor(BuildContext context, SettingType type, Color primaryColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (isDark) {
      // Karanlık modda en önemli ayarlar kendi renginde, diğer hepsi birincil renge (primaryColor)
      switch (type) {
        case SettingType.membership:
          return const Color(0xFFFFB300); // Lüks Altın/Amber
        case SettingType.reset:
        case SettingType.purge:
          return const Color(0xFFFF5252); // Dikkat Çekici Kırmızı (Tehlikeli eylem)
        default:
          return primaryColor; // Diğer tüm ayarlar tek renk (bütünleşik tasarım)
      }
    }

    // Aydınlık modda her ayar grubu kendi uyumlu renk paletinde (bütünsel ve temiz görünüm)
    switch (type) {
        // --- 1. Üyelik ve Hesap Grubu (Prestijli Sıcak Renkler) ---
        case SettingType.membership:
          return const Color(0xFFFF8F00); // Lüks Amber/Altın
        case SettingType.auth:
          return const Color(0xFFE65100); // Derin Turuncu-Kahve (Hesap Güvenliği)

        // --- 2. Görünüm ve Stil Grubu (Tasarım ve Estetik - Kreatif Mor/Eflatun Tonları) ---
        case SettingType.theme:
          return const Color(0xFF5E35B1); // Koyu Eflatun
        case SettingType.colorTheme:
          return const Color(0xFF7E57C2); // Orta Eflatun
        case SettingType.background:
          return const Color(0xFF9575CD); // Yumuşak Violet

        // --- 3. Tercihler Grubu (Sistem Ayarları - Temiz ve Huzurlu Mavi/Camgöbeği Tonları) ---
        case SettingType.language:
          return const Color(0xFF1565C0); // Koyu Mavi
        case SettingType.currency:
          return const Color(0xFF1976D2); // Sistem Mavisi
        case SettingType.exchangeRate:
          return const Color(0xFF0288D1); // Açık Mavi
        case SettingType.notification:
          return const Color(0xFF0097A7); // Camgöbeği
        case SettingType.location:
          return const Color(0xFF00897B); // Teal

        // --- 4. Veri ve Eşitleme Grubu (Güvenli Veri Akışı - Doğa Dostu Yeşil/Çam Tonları) ---
        case SettingType.sync:
          return const Color(0xFF2E7D32); // Koyu Orman Yeşili
        case SettingType.backup:
          return const Color(0xFF43A047); // Canlı Yeşil
        case SettingType.export:
          return const Color(0xFF4CAF50); // Yaprak Yeşili
        case SettingType.retention:
          return const Color(0xFF81C784); // Yumuşak Yeşil

        // --- Tehlikeli/Kritik Veri Eylemleri (Evrensel Kırmızı Alarm Tonları) ---
        case SettingType.purge:
          return const Color(0xFFE53935); // Uyarı Kırmızısı
        case SettingType.reset:
          return const Color(0xFFC62828); // Kritik Sıfırlama Kırmızısı

        // --- 5. Destek Grubu (Yardımsever Sıcak Mercan/Turuncu Tonları) ---
        case SettingType.contact:
          return const Color(0xFFF4511E); // Sıcak Mercan
        case SettingType.about:
          return const Color(0xFFFF7043); // Soft Turuncu
      }
  }

  static Widget buildSectionTitle(String title, Color activeColor, {Key? key}) {
    return Builder(
      builder: (context) {
        return Padding(
          key: key,
          padding: const EdgeInsets.only(left: 0, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: AppColors.getTextFaint(context),
              letterSpacing: 2,
            ),
          ),
        );
      }
    );
  }

  static Widget buildSetting({
    required IconData icon,
    required String title,
    String? trailing,
    required VoidCallback onTap,
    required Color activeColor,
    required BuildContext context,
    bool isAction = false,
    BorderRadius? borderRadius,
  }) {
    return ClickableAction(
      onTap: onTap,
      borderRadius: borderRadius,
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
              child: Icon(icon, size: 22, color: activeColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: AppColors.getTextPrimary(context),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (trailing != null) ...[
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                layoutBuilder: (currentChild, previousChildren) => Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    ...previousChildren,
                    if (currentChild != null) currentChild,
                  ],
                ),
                transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                child: Text(
                  trailing,
                  key: ValueKey(trailing),
                  style: TextStyle(
                    color: activeColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            if (trailing == null && !isAction)
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.getTextSecondary(context).withValues(alpha: 0.3),
              ),
            if (isAction)
              Icon(
                Icons.arrow_outward_rounded,
                color: activeColor.withValues(alpha: 0.5),
                size: 18,
              ),
          ],
        ),
      ),
    );
  }

  static Widget buildToggle({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color activeColor,
    required BuildContext context,
    IconData? activeIcon,
    IconData? inactiveIcon,
  }) {
    return Padding(
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
              activeIcon: activeIcon ?? icon,
              inactiveIcon: inactiveIcon ?? icon,
              isActive: value,
              color: activeColor.withValues(alpha: value ? 1.0 : 0.4),
              size: 22,
              duration: const Duration(milliseconds: 400),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: AppColors.getTextPrimary(context),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          CustomSwitch(
            value: value,
            onChanged: onChanged,
            activeColor: activeColor,
            activeIcon: activeIcon,
            inactiveIcon: inactiveIcon,
          ),
        ],
      ),
    );
  }

  static Widget buildDivider(bool isDark) {
    return Divider(
      height: 1,
      indent: 72,
      endIndent: 20,
      color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
    );
  }
}
