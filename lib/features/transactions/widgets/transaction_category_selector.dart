import 'package:flutter/material.dart';
import '../../../core/theme/app_constants.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/custom_animated_icon.dart';

class TransactionCategorySelector extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final int selectedCategoryIndex;
  final int selectedSubModelIndex;
  final int expandedCategoryIndex;
  final Function(int categoryIndex, int subIndex, int expandedIndex) onChanged;
  final Function(String parentCategoryId)? onAddCustomSubcategory;
  final Function(String subcategoryId)? onRemoveCustomSubcategory;
  final bool isPro;

  const TransactionCategorySelector({
    super.key,
    required this.categories,
    required this.selectedCategoryIndex,
    required this.selectedSubModelIndex,
    required this.expandedCategoryIndex,
    required this.onChanged,
    this.onAddCustomSubcategory,
    this.onRemoveCustomSubcategory,
    this.isPro = true,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    
    // Güvenlik kontrolü
    final safeSelectedIndex = selectedCategoryIndex >= 0 && selectedCategoryIndex < categories.length 
        ? selectedCategoryIndex 
        : 0;
        
    final selectedCat = categories[safeSelectedIndex];
    final List<Map<String, dynamic>> subModels =
        (selectedCat['subModels'] as List<Map<String, dynamic>>?) ?? [];
    final bool isExpanded = expandedCategoryIndex == safeSelectedIndex;
    // Alt kategoriler varsa VEYA "+" butonu göstereceğiz (her zaman açılabilir)
    final bool hasSubModels = subModels.isNotEmpty || onAddCustomSubcategory != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- ANA KATEGORİ ŞERİDİ (Yatay) ---
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isSelected = index == safeSelectedIndex;
              final isExpandedLocal = index == expandedCategoryIndex;
              final catColor = cat['color'] as Color;

              // Seçili alt model varsa, onun bilgilerini göster
              final bool showSubInfo =
                  isSelected &&
                  selectedSubModelIndex >= 0 &&
                  selectedSubModelIndex <
                      ((cat['subModels'] as List?)?.length ?? 0);

              final displayIcon = showSubInfo
                  ? (cat['subModels'] as List)[selectedSubModelIndex]['icon'] as IconData
                  : cat['icon'] as IconData;
              final displayName = showSubInfo
                  ? (cat['subModels'] as List)[selectedSubModelIndex]['name'] as String
                  : cat['name'] as String;

              return GestureDetector(
                onTap: () {
                  int newExp = expandedCategoryIndex;
                  int newSel = safeSelectedIndex;
                  int newSub = selectedSubModelIndex;

                  if (isSelected) {
                    newExp = isExpandedLocal ? -1 : index;
                  } else {
                    newSel = index;
                    newSub = -1;
                    newExp = -1;
                  }
                  onChanged(newSel, newSub, newExp);
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedScale(
                        scale: isSelected ? 1.1 : 1.0,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutBack,
                        child: AnimatedRotation(
                          turns: isSelected ? 0.02 : 0.0,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.elasticOut,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? catColor.withValues(alpha: 0.15)
                                  : (isDark ? Colors.white : Colors.black).withValues(alpha: 0.03),
                              border: Border.all(
                                color: isSelected
                                    ? catColor.withValues(alpha: 0.4)
                                    : (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
                                width: 1.5,
                              ),
                              boxShadow: const [],
                            ),
                             child: CustomAnimatedIcon(
                               activeIcon: displayIcon,
                               inactiveIcon: cat['icon'] as IconData,
                               isActive: showSubInfo,
                               color: isSelected
                                   ? AppColors.getAccentDeep(context, catColor)
                                   : AppColors.getTextSecondary(context).withValues(alpha: 0.5),
                               size: isSelected ? 28 : 24,
                               duration: const Duration(milliseconds: 600),
                             ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 70,
                        child: Text(
                          displayName,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                            color: isSelected
                                ? AppColors.getTextPrimary(context)
                                : AppColors.getTextSecondary(context).withValues(alpha: 0.8),
                            letterSpacing: -0.2,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(
                        height: 16,
                        child: AnimatedRotation(
                          turns: isExpandedLocal ? 1.0 : 0.5,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOutCubic,
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 14,
                            color: isSelected 
                                ? catColor 
                                : AppColors.getTextSecondary(context).withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // --- ALT KATEGORİ ŞERİDİ ---
        AnimatedSize(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          child: isExpanded && hasSubModels
              ? AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: isExpanded ? 1.0 : 0.0,
                  child: Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 8),
                    height: 36,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      clipBehavior: Clip.none,
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
                      // +1 for the "Add New" button at the end
                      itemCount: subModels.length + (onAddCustomSubcategory != null ? 1 : 0),
                      itemBuilder: (context, subIndex) {
                        final Color parentColor = selectedCat['color'] as Color;

                        // Son eleman = "＋ Yeni Ekle" butonu
                        if (onAddCustomSubcategory != null && subIndex == subModels.length) {
                          Widget addButton = GestureDetector(
                            onTap: () => onAddCustomSubcategory!(selectedCat['id'] as String),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: parentColor.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(AppSizes.radiusRound),
                                border: Border.all(
                                  color: parentColor.withValues(alpha: 0.25),
                                  width: 1,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.add_rounded,
                                    size: 14,
                                    color: parentColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    l10n.addCustomCategory,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: parentColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );

                          if (!isPro) {
                            addButton = Stack(
                              fit: StackFit.passthrough,
                              clipBehavior: Clip.none,
                              children: [
                                addButton,
                                Positioned(
                                  top: -2,
                                  right: -2,
                                  child: Container(
                                    padding: const EdgeInsets.all(2.5),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFFFB300), // Altın sarısı
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.star_rounded,
                                      color: Colors.white,
                                      size: 8,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }

                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: addButton,
                          );
                        }

                        // Normal alt kategori chip'i
                        final sub = subModels[subIndex];
                        final isSubSelected = subIndex == selectedSubModelIndex;
                        final bool isCustom = sub['isCustom'] == true;

                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () {
                              final newSub = isSubSelected ? -1 : subIndex;
                              onChanged(safeSelectedIndex, newSub, expandedCategoryIndex);
                            },
                            onLongPress: isCustom && onRemoveCustomSubcategory != null
                                ? () => onRemoveCustomSubcategory!(sub['id'] as String)
                                : null,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSubSelected
                                    ? parentColor.withValues(alpha: 0.2)
                                    : (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(AppSizes.radiusRound),
                                border: Border.all(
                                  color: isSubSelected
                                      ? parentColor.withValues(alpha: 0.5)
                                      : Colors.transparent,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    sub['icon'] as IconData,
                                    size: 14,
                                    color: isSubSelected
                                        ? parentColor
                                        : AppColors.getTextSecondary(context),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    sub['name'] as String,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: isSubSelected ? FontWeight.w900 : FontWeight.w600,
                                      color: isSubSelected
                                          ? AppColors.getTextPrimary(context)
                                          : AppColors.getTextSecondary(context),
                                    ),
                                  ),
                                  // Özel kategorilerde silme ikonu (sadece seçiliyken)
                                  if (isCustom && isSubSelected && onRemoveCustomSubcategory != null) ...[
                                    const SizedBox(width: 4),
                                    GestureDetector(
                                      onTap: () => onRemoveCustomSubcategory!(sub['id'] as String),
                                      child: Icon(
                                        Icons.close_rounded,
                                        size: 12,
                                        color: parentColor.withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
