import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Kullanıcının oluşturduğu özel alt kategorileri SharedPreferences ile saklar.
/// Bu kategoriler kişiye özeldir ve çevrilmez — kullanıcı ne yazdıysa o kalır.
class CustomCategoryService {
  static const String _storageKey = 'custom_subcategories';

  /// Tüm özel alt kategorileri getirir.
  /// Her giriş: {"parentId": "exp_grocery", "id": "exp_grocery_custom_171...", "name": "Baharat"}
  static Future<List<Map<String, String>>> getAllCustomSubcategories() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey) ?? [];
    return raw.map((jsonStr) {
      final decoded = json.decode(jsonStr) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, v.toString()));
    }).toList();
  }

  /// Belirli bir ana kategoriye ait özel alt kategorileri getirir.
  static Future<List<Map<String, String>>> getCustomSubcategoriesFor(String parentId) async {
    final all = await getAllCustomSubcategories();
    return all.where((entry) => entry['parentId'] == parentId).toList();
  }

  /// Yeni bir özel alt kategori ekler.
  /// [parentId] — Ana kategorinin ID'si (örn: "exp_grocery")
  /// [name] — Kullanıcının yazdığı isim (çevrilmez, kişiye özel)
  /// Dönen değer: oluşturulan alt kategorinin benzersiz ID'si
  static Future<String> addCustomSubcategory(String parentId, String name) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey) ?? [];

    final id = '${parentId}_custom_${DateTime.now().millisecondsSinceEpoch}';
    final entry = json.encode({
      'parentId': parentId,
      'id': id,
      'name': name.trim(),
    });

    raw.add(entry);
    await prefs.setStringList(_storageKey, raw);
    return id;
  }

  /// Belirli bir özel alt kategoriyi siler.
  static Future<void> removeCustomSubcategory(String subcategoryId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey) ?? [];

    raw.removeWhere((jsonStr) {
      final decoded = json.decode(jsonStr) as Map<String, dynamic>;
      return decoded['id'] == subcategoryId;
    });

    await prefs.setStringList(_storageKey, raw);
  }

  /// Tüm özel alt kategorileri temizler (Reset için).
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
