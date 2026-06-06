import 'package:flutter/material.dart';
import '../../features/transactions/widgets/transaction_category_data.dart';
import '../../l10n/app_localizations.dart';
import '../database/models/custom_category.dart';
import 'icon_utils.dart';

class CategoryUtils {
  /// Dynamically resolves the name of a category or subcategory.
  static String getCategoryName({
    required String? categoryId,
    required BuildContext context,
    required List<CustomCategory> customCategories,
    String? fallbackTitle,
  }) {
    if (categoryId == null || categoryId.isEmpty) {
      return fallbackTitle ?? AppLocalizations.of(context)?.other ?? 'Diğer';
    }

    // 1. Check custom categories
    for (final c in customCategories) {
      if (c.uniqueId == categoryId) {
        return c.name;
      }
    }

    // 2. If it's a custom category but wasn't found in the list (e.g. user is not Premium or it was deleted),
    // fall back to the parent category!
    if (categoryId.contains('_custom_')) {
      final parentId = categoryId.split('_custom_')[0];
      return getCategoryName(
        categoryId: parentId,
        context: context,
        customCategories: customCategories,
        fallbackTitle: fallbackTitle,
      );
    }

    final l10n = AppLocalizations.of(context);
    if (l10n == null) return fallbackTitle ?? 'Diğer';

    // 3. Check built-in expense categories
    final expenses = TransactionCategoryData.getExpenseCategories(context, l10n);
    for (final cat in expenses) {
      if (cat['id'] == categoryId) {
        return cat['name'] as String;
      }
      final subs = cat['subModels'] as List?;
      if (subs != null) {
        for (final sub in subs) {
          if (sub['id'] == categoryId) {
            return sub['name'] as String;
          }
        }
      }
    }

    // 4. Check built-in income categories
    final incomes = TransactionCategoryData.getIncomeCategories(context, l10n);
    for (final cat in incomes) {
      if (cat['id'] == categoryId) {
        return cat['name'] as String;
      }
      final subs = cat['subModels'] as List?;
      if (subs != null) {
        for (final sub in subs) {
          if (sub['id'] == categoryId) {
            return sub['name'] as String;
          }
        }
      }
    }

    // 5. Fallback to title
    return fallbackTitle ?? l10n.other;
  }

  /// Dynamically resolves the IconData of a category or subcategory, checking custom categories first.
  static IconData getCategoryIcon({
    required String? categoryId,
    required List<CustomCategory> customCategories,
    String? iconCode,
  }) {
    if (categoryId != null && categoryId.isNotEmpty) {
      // 1. Check custom categories
      for (final c in customCategories) {
        if (c.uniqueId == categoryId) {
          return IconData(c.iconCode, fontFamily: 'MaterialIcons');
        }
      }

      // 2. If it's a custom category but not found, fall back to parent
      if (categoryId.contains('_custom_')) {
        final parentId = categoryId.split('_custom_')[0];
        return getCategoryIcon(
          categoryId: parentId,
          customCategories: customCategories,
          iconCode: null,
        );
      }
    }

    if (iconCode != null && iconCode.isNotEmpty) {
      final int? codepoint = int.tryParse(iconCode);
      if (codepoint != null) {
        return IconData(codepoint, fontFamily: 'MaterialIcons');
      }
    }

    // 3. Fallback to built-in IconUtils resolver
    return IconUtils.getIcon(iconCode ?? categoryId);
  }

  /// Dynamically resolves the Color of a category or subcategory, checking custom categories first.
  static Color getCategoryColor({
    required String? categoryId,
    required List<CustomCategory> customCategories,
  }) {
    if (categoryId != null && categoryId.isNotEmpty) {
      // 1. Check custom categories
      for (final c in customCategories) {
        if (c.uniqueId == categoryId) {
          // Custom category's color is the parent category's color
          final parentId = categoryId.split('_custom_')[0];
          return IconUtils.getColor(parentId);
        }
      }

      // 2. If it's a custom category but not found, fall back to parent
      if (categoryId.contains('_custom_')) {
        final parentId = categoryId.split('_custom_')[0];
        return getCategoryColor(
          categoryId: parentId,
          customCategories: customCategories,
        );
      }
    }

    // 3. Fallback to built-in IconUtils resolver
    return IconUtils.getColor(categoryId);
  }
}
