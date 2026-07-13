import 'package:flutter/material.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../shared/widgets/custom_button.dart';

enum TemplateUpdateOption {
  cancel,
  updateAllWithNewValues,
  approveAndKeepHistory,
}

class TemplateUpdateWarningSheet extends StatelessWidget {
  final int unreviewedCount;
  final String templateTitle;
  final Color templateColor;

  const TemplateUpdateWarningSheet({
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
            Icons.info_outline_rounded,
            size: 48 * sf,
            color: Colors.blueAccent,
          ),
          SizedBox(height: 16 * sf),
          Text(
            '"$templateTitle" şablonunu güncelliyorsunuz. Ancak bu şablona ait henüz incelemediğiniz $unreviewedCount adet işlem kaydı bulunuyor.',
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
            'Bu işlemleri eski değerleriyle (eski tutar, kategori vb.) onaylayıp geçmiş kaydı olarak korumak mı istersiniz, yoksa yeni şablon değerleriyle güncellemek mi?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13 * sf,
              fontWeight: FontWeight.w500,
              color: AppColors.getTextSecondary(context),
              height: 1.4,
            ),
          ),
          SizedBox(height: 24 * sf),
          
          // Seçenek 1: Hepsini Onayla ve Koruyarak Şablonu Güncelle (Önerilen)
          CustomButton(
            label: "Eski İşlemleri Onayla ve Koru",
            onTap: () => Navigator.pop(context, TemplateUpdateOption.approveAndKeepHistory),
            activeColor: AppColors.getAccentDeep(context, templateColor),
            height: 52 * sf,
          ),
          SizedBox(height: 12 * sf),

          // Seçenek 2: Yeni değerlerle güncelle
          CustomButton(
            label: "Yeni Değerlerle Güncelle",
            onTap: () => Navigator.pop(context, TemplateUpdateOption.updateAllWithNewValues),
            isPrimary: false,
            activeColor: AppColors.getAccentDeep(context, templateColor),
            height: 52 * sf,
          ),
          SizedBox(height: 12 * sf),

          // Seçenek 3: İptal
          CustomButton(
            label: "Vazgeç",
            onTap: () => Navigator.pop(context, TemplateUpdateOption.cancel),
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
