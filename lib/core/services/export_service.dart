import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:isar_community/isar.dart';

import '../database/database_service.dart';
import '../database/models/custom_category.dart';
import '../database/models/vault.dart';
import '../utils/category_utils.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/custom_notification.dart';

class ExportService {
  static Future<void> exportTransactionsToCsv(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode.toLowerCase();
    
    // 10 dil için başlıklar (Localization headers for 10 languages)
    final headersMap = {
      'tr': ['Tarih', 'Başlık', 'Tutar', 'Para Birimi', 'Kategori', 'Kasa', 'İşlem Türü', 'Durum', 'Açıklama'],
      'en': ['Date', 'Title', 'Amount', 'Currency', 'Category', 'Vault', 'Type', 'Status', 'Description'],
      'de': ['Datum', 'Titel', 'Betrag', 'Währung', 'Kategorie', 'Konto', 'Typ', 'Status', 'Beschreibung'],
      'es': ['Fecha', 'Título', 'Monto', 'Moneda', 'Categoría', 'Cuenta', 'Tipo', 'Estado', 'Descripción'],
      'fr': ['Date', 'Titre', 'Montant', 'Devise', 'Catégorie', 'Compte', 'Type', 'Statut', 'Description'],
      'it': ['Data', 'Titolo', 'Importo', 'Valuta', 'Categoria', 'Conto', 'Tipo', 'Stato', 'Descrizione'],
      'pt': ['Data', 'Título', 'Valor', 'Moeda', 'Categoria', 'Carteira', 'Tipo', 'Status', 'Descrição'],
      'ja': ['日付', 'タイトル', '金額', '通貨', 'カテゴリー', 'ウォレット', 'タイプ', 'ステータス', '説明'],
      'ko': ['날짜', '제목', '금액', '통화', '카테고리', '자산', '유형', '상태', '설명'],
      'zh': ['日期', '标题', '金额', '货币', '类别', '账户', '类型', '状态', '描述'],
    };

    // 10 dil için veri etiketleri (Value labels for 10 languages)
    final labelsMap = {
      'tr': {'income': 'Gelir', 'expense': 'Gider', 'transfer': 'Transfer', 'skipped': 'Atlandı', 'confirmed': 'Gerçekleşti', 'exportSubject': 'Finarcast Finansal Veri Aktarımı'},
      'en': {'income': 'Income', 'expense': 'Expense', 'transfer': 'Transfer', 'skipped': 'Skipped', 'confirmed': 'Confirmed', 'exportSubject': 'Finarcast Financial Data Export'},
      'de': {'income': 'Einnahme', 'expense': 'Ausgabe', 'transfer': 'Umbuchung', 'skipped': 'Übersprungen', 'confirmed': 'Bestätigt', 'exportSubject': 'Finarcast Finanzdatenexport'},
      'es': {'income': 'Ingreso', 'expense': 'Gasto', 'transfer': 'Transferencia', 'skipped': 'Omitido', 'confirmed': 'Confirmado', 'exportSubject': 'Exportación de Datos Financieros de Finarcast'},
      'fr': {'income': 'Revenu', 'expense': 'Dépense', 'transfer': 'Transfert', 'skipped': 'Ignoré', 'confirmed': 'Confirmé', 'exportSubject': 'Exportation de Données Financières Finarcast'},
      'it': {'income': 'Entrata', 'expense': 'Uscita', 'transfer': 'Trasferimento', 'skipped': 'Saltato', 'confirmed': 'Confermato', 'exportSubject': 'Esportazione Dati Finanziari Finarcast'},
      'pt': {'income': 'Receita', 'expense': 'Despesa', 'transfer': 'Transferência', 'skipped': 'Ignorado', 'confirmed': 'Confirmado', 'exportSubject': 'Exportação de Dados Financeiros Finarcast'},
      'ja': {'income': '収入', 'expense': '支出', 'transfer': '振替', 'skipped': 'スキップ', 'confirmed': '確定', 'exportSubject': 'Finarcast財務データエクスポート'},
      'ko': {'income': '수입', 'expense': '지출', 'transfer': '이체', 'skipped': '건너뜀', 'confirmed': '확정', 'exportSubject': 'Finarcast 재무 데이터 내보내기'},
      'zh': {'income': '收入', 'expense': '支出', 'transfer': '转账', 'skipped': '跳过', 'confirmed': '已确认', 'exportSubject': 'Finarcast 财务数据导出'},
    };

    final headers = headersMap[lang] ?? headersMap['en']!;
    final labels = labelsMap[lang] ?? labelsMap['en']!;

    try {
      HapticFeedback.selectionClick();
      
      // 1. Verileri Çek
      final transactions = await DatabaseService.getAllTransactions();
      if (!context.mounted) return;
      
      if (transactions.isEmpty) {
        CustomNotification.error(context, l10n.noTransactionsToExport);
        return;
      }
      
      final customCategories = await DatabaseService.isar.customCategorys.where().findAll();
      final vaults = await DatabaseService.isar.vaults.where().findAll();
      if (!context.mounted) return;
      
      final vaultMap = {for (var v in vaults) v.id: v.name};
      
      final buffer = StringBuffer();
      
      // Excel için separatör belirteci (Excel'in tüm dillerde sütunları doğru ayırmasını sağlar)
      buffer.writeln('sep=,');
      
      // CSV Başlık Satırı (CSV Header line)
      buffer.writeln(headers.map((h) => '"$h"').join(','));
      
      final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
      
      // 3. Verileri Satır Satır CSV formatına dönüştür
      for (final tx in transactions) {
        final dateStr = dateFormat.format(tx.date);
        final titleEscaped = tx.title.replaceAll('"', '""');
        final amountStr = tx.effectiveAmount.toStringAsFixed(2);
        final currencyStr = tx.currency ?? '';
        
        final catName = CategoryUtils.getCategoryName(
          categoryId: tx.categoryId,
          context: context,
          customCategories: customCategories,
          fallbackTitle: tx.title,
        );
        final catEscaped = catName.replaceAll('"', '""');
        
        final isTransfer = tx.targetVaultId != null;
        String vaultStr;
        if (isTransfer) {
          final src = vaultMap[tx.vaultId] ?? '';
          final dest = vaultMap[tx.targetVaultId] ?? '';
          vaultStr = '$src -> $dest';
        } else {
          vaultStr = vaultMap[tx.vaultId] ?? '';
        }
        final vaultEscaped = vaultStr.replaceAll('"', '""');
        
        String typeStr;
        if (isTransfer) {
          typeStr = labels['transfer']!;
        } else if (tx.isIncome) {
          typeStr = labels['income']!;
        } else {
          typeStr = labels['expense']!;
        }
        
        final statusStr = tx.status == 2 
            ? labels['skipped']! 
            : labels['confirmed']!;
            
        final noteEscaped = (tx.note ?? '').replaceAll('"', '""');
        
        buffer.writeln('"$dateStr","$titleEscaped",$amountStr,"$currencyStr","$catEscaped","$vaultEscaped","$typeStr","$statusStr","$noteEscaped"');
      }
      
      // 4. Geçici Dosyaya Kaydet
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/finarcast_export.csv');
      
      // Excel'in karakterleri (UTF-8 BOM) doğru okuması için BOM ekleyelim
      final bytes = utf8.encode(buffer.toString());
      final bomBytes = [0xEF, 0xBB, 0xBF, ...bytes];
      await file.writeAsBytes(bomBytes);
      
      if (!context.mounted) return;
      
      // 5. Paylaşım Ekranını Aç
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'text/csv')],
          subject: labels['exportSubject']!,
        ),
      );
      
    } catch (e) {
      debugPrint('Dışa aktarım hatası: $e');
      if (context.mounted) {
        CustomNotification.error(context, '${l10n.errorOccurred('Export Error')}: $e');
      }
    }
  }
}
