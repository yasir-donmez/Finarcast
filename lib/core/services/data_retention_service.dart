import '../database/database_service.dart';

/// Süresi dolan işlemleri arşivleme servisi
/// Uygulama açılışında çağrılır.
class DataRetentionService {
  /// dataRetentionDays ayarına göre eski işlemleri arşivle.
  /// Arşivlenen işlemler aktif listede görünmez ama analizde kullanılır.
  static Future<void> archiveExpiredTransactions() async {
    final settings = await DatabaseService.getSettings();
    final retentionDays = settings.dataRetentionDays;

    // -1 = sonsuz, hiçbir şey arşivleme
    if (retentionDays == -1) return;

    final cutoff = DateTime.now().subtract(Duration(days: retentionDays));
    final allTx = await DatabaseService.getAllTransactions();

    final toArchive = allTx.where((tx) {
      if (tx.isArchived) return false; // Zaten arşivlenmiş

      // Tarihi cutoff'tan önce olan her işlemi arşivle (tüm tipler için güvenlidir)
      return tx.date.isBefore(cutoff);
    }).toList();

    if (toArchive.isEmpty) return;

    for (final tx in toArchive) {
      tx.isArchived = true;
    }

    await DatabaseService.updateAllTransactions(toArchive);

    // --- KALICI SİLME İŞLEMİ ---
    final permanentDeletionDays = settings.permanentDeletionDays;
    if (permanentDeletionDays == -1) return;

    final deleteCutoff = DateTime.now().subtract(Duration(days: permanentDeletionDays));
    
    // Sadece tek seferlik (templateId == null) işlemler silinebilir.
    // Tekrarlı işlem kayıtlarının silinmesi MaterializationService tarafından yeniden üretilmelerine yol açar.
    final toDelete = allTx.where((tx) {
      if (tx.templateId != null) return false;

      // Silme süresinden eski olmalı
      return tx.date.isBefore(deleteCutoff);
    }).toList();

    if (toDelete.isNotEmpty) {
      final idsToDelete = toDelete.map((tx) => tx.id).toList();
      await DatabaseService.deleteTransactions(idsToDelete);
    }
  }
}
