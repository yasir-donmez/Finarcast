import 'package:isar/isar.dart';
import '../database/database_service.dart';
import '../database/models/custom_category.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Kullanıcının oluşturduğu özel alt kategorileri Isar DB ile saklar.
/// Bu sayede senkronizasyon (Sync) özelliğine tam uyumludur.
class CustomCategoryService {
  static const String _storageKey = 'custom_subcategories';

  /// Tüm özel alt kategorileri getirir.
  static Future<List<Map<String, String>>> getAllCustomSubcategories() async {
    // Migration kontrolü
    await _migrateIfNeeded();
    
    final isar = DatabaseService.isar;
    final list = await isar.customCategorys.where().findAll();
    
    return list.map((c) => {
      'parentId': c.parentId,
      'id': c.uniqueId,
      'name': c.name,
      'iconCode': c.iconCode.toString(),
    }).toList();
  }

  /// Yeni bir özel alt kategori ekler.
  static Future<String> addCustomSubcategory(String parentId, String name, int iconCode) async {
    final isar = DatabaseService.isar;
    final uniqueId = '${parentId}_custom_${DateTime.now().millisecondsSinceEpoch}';
    
    final newItem = CustomCategory()
      ..uniqueId = uniqueId
      ..parentId = parentId
      ..name = name.trim()
      ..iconCode = iconCode
      ..updatedAt = DateTime.now();

    await isar.writeTxn(() async {
      await isar.customCategorys.put(newItem);
    });
    
    return uniqueId;
  }

  /// Belirli bir özel alt kategoriyi siler.
  static Future<void> removeCustomSubcategory(String subcategoryId) async {
    final isar = DatabaseService.isar;
    await isar.writeTxn(() async {
      await isar.customCategorys.where().uniqueIdEqualTo(subcategoryId).deleteFirst();
    });
  }

  /// SharedPreferences'taki eski verileri Isar'a taşır (Sadece 1 kez çalışır).
  static Future<void> _migrateIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey);
    
    if (raw != null && raw.isNotEmpty) {
      final isar = DatabaseService.isar;
      await isar.writeTxn(() async {
        for (final jsonStr in raw) {
          try {
            final decoded = json.decode(jsonStr) as Map<String, dynamic>;
            final item = CustomCategory()
              ..uniqueId = decoded['id'] ?? ''
              ..parentId = decoded['parentId'] ?? ''
              ..name = decoded['name'] ?? ''
              ..iconCode = decoded['iconCode'] ?? 0
              ..updatedAt = DateTime.now();
            
            await isar.customCategorys.put(item);
          } catch (_) {}
        }
      });
      // Taşıma bitti, SharedPreferences'ı temizle
      await prefs.remove(_storageKey);
    }
  }

  /// Tüm verileri temizler.
  static Future<void> clearAll() async {
    final isar = DatabaseService.isar;
    await isar.writeTxn(() async {
      await isar.customCategorys.clear();
    });
  }
}
