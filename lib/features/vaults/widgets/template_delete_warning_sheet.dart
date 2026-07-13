import 'package:flutter/material.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../shared/widgets/custom_button.dart';

enum TemplateDeleteOption {
  cancel,
  deleteWithTransactions,
  approveAndKeepHistory,
}

class TemplateDeleteWarningSheet extends StatelessWidget {
  final int unreviewedCount;
  final String templateTitle;
  final Color templateColor;

  const TemplateDeleteWarningSheet({
    super.key,
    required this.unreviewedCount,
    required this.templateTitle,
    required this.templateColor,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final sf = (screenHeight / 812.0).clamp(0.85, 1.0);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20 * sf, vertical: 12 * sf),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 48 * sf,
            color: Colors.amber,
          ),
          SizedBox(height: 16 * sf),
          Text(
            '"$templateTitle" şablonunu silmek üzeresiniz. Ancak bu şablona ait henüz incelemediğiniz $unreviewedCount adet işlem kaydı bulunuyor.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15 * sf,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextPrimary(context),
              height: 1.4,
            ),
          ),
          SizedBox(height: 12 * sf),
          Text(
            'Bu işlemleri onaylayıp geçmiş kaydı olarak korumak mı istersiniz, yoksa şablonla birlikte tamamen silmek mi istersiniz?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13 * sf,
              fontWeight: FontWeight.w500,
              color: AppColors.getTextSecondary(context),
              height: 1.4,
            ),
          ),
          SizedBox(height: 24 * sf),
          
          // Seçenek 1: Hepsini Onayla ve Şablonu Sil (Birincil / Önerilen Aksiyon)
          CustomButton(
            label: "İşlemleri Onayla ve Şablonu Sil",
            onTap: () => Navigator.pop(context, TemplateDeleteOption.approveAndKeepHistory),
            activeColor: AppColors.getAccentDeep(context, templateColor),
            height: 52 * sf,
          ),
          SizedBox(height: 12 * sf),

          // Seçenek 2: Şablonla Birlikte Hepsini Sil (İkincil Aksiyon)
          CustomButton(
            label: "İşlemleri ve Şablonu Birlikte Sil",
            onTap: () => Navigator.pop(context, TemplateDeleteOption.deleteWithTransactions),
            isPrimary: false,
            activeColor: AppColors.error,
            height: 52 * sf,
          ),
          SizedBox(height: 12 * sf),

          // Seçenek 3: Vazgeç
          CustomButton(
            label: "Vazgeç",
            onTap: () => Navigator.pop(context, TemplateDeleteOption.cancel),
            isPrimary: false,
            activeColor: AppColors.getTextSecondary(context),
            height: 52 * sf,
          ),
          SizedBox(height: 8 * sf),
        ],
      ),
    );
  }
}
