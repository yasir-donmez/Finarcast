import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/settings_provider.dart';
import '../../../../shared/widgets/custom_bottom_sheet.dart';
import '../../../../shared/widgets/wheel_picker.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../dashboard/dashboard_providers.dart';
import '../profile_list_items.dart';

class LanguageSetting extends ConsumerWidget {
  const LanguageSetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageCode = ref.watch(settingsProvider.select((s) => s.languageCode));
    final activeColor = ProfileListItems.getSettingColor(context, SettingType.language, ref.watch(rotaryColorProvider));
    final l10n = AppLocalizations.of(context)!;

    return ProfileListItems.buildSetting(
      icon: Icons.language_rounded,
      title: l10n.language,
      trailing: _getLanguageName(languageCode),
      onTap: () => _showLanguagePicker(context, ref, languageCode, activeColor, l10n),
      activeColor: activeColor,
      context: context,
    );
  }

  void _showLanguagePicker(BuildContext context, WidgetRef ref, String currentCode, Color activeColor, AppLocalizations l10n) {
    final List<String> languages = ["Türkçe", "English", "Deutsch", "Español", "Français", "Português", "Italiano", "日本語", "中文", "한국어"];
    final List<String> codes = ["tr", "en", "de", "es", "fr", "pt", "it", "ja", "zh", "ko"];
    int initialIndex = codes.indexOf(currentCode);
    if (initialIndex == -1) initialIndex = 0;

    int tempIndex = initialIndex;

    CustomBottomSheet.show(
      context: context,
      title: l10n.selectLanguage,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          WheelPicker.strings(
            items: languages,
            initialItem: initialIndex,
            onSelectedItemChanged: (index) => tempIndex = index,
          ),
          const SizedBox(height: 24),
          CustomButton(
            label: l10n.ok,
            onTap: () {
              ref.read(settingsProvider.notifier).setLanguage(codes[tempIndex]);
              Navigator.pop(context);
            },
            activeColor: activeColor,
          ),
        ],
      ),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'tr': return 'Türkçe';
      case 'en': return 'English';
      case 'de': return 'Deutsch';
      case 'es': return 'Español';
      case 'fr': return 'Français';
      case 'pt': return 'Português';
      case 'it': return 'Italiano';
      case 'ja': return '日本語';
      case 'zh': return '中文';
      case 'ko': return '한국어';
      default: return 'Türkçe';
    }
  }
}
