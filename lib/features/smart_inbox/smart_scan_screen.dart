import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_constants.dart';
import '../../core/database/models/vault.dart';
import '../../core/providers/db_providers.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/services/subscription_service.dart';
import '../../shared/widgets/custom_card.dart';
import '../../shared/widgets/custom_notification.dart';
import '../../shared/widgets/custom_dialog.dart';
import '../transactions/transaction_builder_screen.dart';
import '../../core/utils/route_transitions.dart';
import '../subscription/widgets/pro_upgrade_sheet.dart';
import 'services/draft_service.dart';
import 'services/smart_parser_service.dart';
import '../auth/widgets/auth_background.dart';
import '../../core/utils/category_utils.dart';
import 'providers/smart_inbox_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Modular Widgets
import 'widgets/empty_state.dart';
import 'widgets/smart_input_area.dart';
import 'widgets/draft_card.dart';
import '../vaults/widgets/staggered_entry_anim.dart';

class SmartScanScreen extends ConsumerStatefulWidget {
  const SmartScanScreen({super.key});

  @override
  ConsumerState<SmartScanScreen> createState() => _SmartScanScreenState();
}

class _SmartScanScreenState extends ConsumerState<SmartScanScreen> with WidgetsBindingObserver {
  final TextEditingController _inputController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  
  // Her bir taslak kartı için seçilen kasa ID'sini tutar (-1 = Ana Kasa)
  final Map<String, int> _selectedVaultIdForDraft = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadDrafts();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _inputController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadDrafts();
    }
  }

  /// Taslakları yükle
  Future<void> _loadDrafts() async {
    await ref.read(smartInboxDraftsProvider.notifier).loadDrafts();
  }

  void _showAiLimitDialog(BuildContext context, bool isPro) {
    if (isPro) {
      showCustomDialog(
        context: context,
        accentColor: const Color(0xFFFFB300), // Altın rengi
        title: "Sınırsız Erişim Limiti",
        content: "Sistem güvenliği gereği adil kullanım limitine ulaştınız. Yarın tekrar sınırsız olarak kullanabilirsiniz.",
        actions: [
          PrecisionDialogAction(
            label: "Kapat",
            onTap: () => Navigator.pop(context),
            isPrimary: true,
          ),
        ],
      );
    } else {
      showCustomDialog(
        context: context,
        accentColor: const Color(0xFFFFB300), // Altın rengi
        title: "Standart Erişim Limiti",
        content: "Günlük standart yapay zeka analiz kotanızı doldurdunuz. Sınırsız analiz için Genişletilmiş Erişime geçin.",
        actions: [
          PrecisionDialogAction(
            label: "Daha Sonra",
            onTap: () => Navigator.pop(context),
            isPrimary: false,
          ),
          PrecisionDialogAction(
            label: "Genişletilmiş Erişime Geç",
            onTap: () {
              Navigator.pop(context);
              ProUpgradeSheet.show(context);
            },
            isPrimary: true,
          ),
        ],
      );
    }
  }

  void _showLoginRequiredDialog(BuildContext context) {
    showCustomDialog(
      context: context,
      accentColor: AppColors.primary,
      title: "Giriş Yapılması Gerekiyor",
      content: "Yapay zeka asistanını ve harcama sepetini kullanabilmek için ücretsiz bir Finarcast hesabı oluşturmanız veya giriş yapmanız gerekmektedir.",
      actions: [
        PrecisionDialogAction(
          label: "İptal",
          onTap: () => Navigator.pop(context),
          isPrimary: false,
        ),
        PrecisionDialogAction(
          label: "Giriş Yap / Üye Ol",
          onTap: () async {
            Navigator.pop(context);
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('Finarcast_is_guest_mode', false);
            ref.read(guestModeProvider.notifier).state = false;
          },
          isPrimary: true,
        ),
      ],
    );
  }

  /// Metin ile işlem analiz et
  Future<void> _parseAndAddText() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      _showLoginRequiredDialog(context);
      return;
    }

    final subService = ref.read(subscriptionServiceProvider);
    if (subService.usedAiCount >= subService.dailyAiLimit) {
      _showAiLimitDialog(context, subService.isPro);
      return;
    }

    ref.read(smartInboxLoadingProvider.notifier).state = 'Yapay zeka harcamanızı çözümlüyor...';

    try {
      final draft = await SmartParserService.parseText(text);
      await ref.read(smartInboxDraftsProvider.notifier).addDraft(draft);
      await ref.read(subscriptionServiceProvider).incrementAiUsage();
      _inputController.clear();
      
      if (mounted) {
        CustomNotification.success(context, 'Taslak harcama gelen kutusuna eklendi.');
      }
      HapticFeedback.heavyImpact();
    } catch (e) {
      if (mounted) {
        final errorMsg = e.toString().replaceAll('Exception: ', '');
        CustomNotification.error(context, errorMsg.isNotEmpty ? errorMsg : 'İşlem analiz edilirken bir hata oluştu.');
      }
    } finally {
      ref.read(smartInboxLoadingProvider.notifier).state = null;
    }
  }

  /// Fiş / Fatura okuma (OCR)
  Future<void> _pickAndParseReceipt(ImageSource source) async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      _showLoginRequiredDialog(context);
      return;
    }

    final subService = ref.read(subscriptionServiceProvider);
    if (subService.usedAiCount >= subService.dailyAiLimit) {
      _showAiLimitDialog(context, subService.isPro);
      return;
    }

    try {
      final XFile? image = await _imagePicker.pickImage(source: source, imageQuality: 85);
      if (image == null) return;

      ref.read(smartInboxLoadingProvider.notifier).state = 'Fiş taranıyor, bilgiler çıkartılıyor...';

      final bytes = await image.readAsBytes();
      final extension = image.path.split('.').last.toLowerCase();
      String mimeType = 'image/jpeg';
      if (extension == 'png') mimeType = 'image/png';
      if (extension == 'webp') mimeType = 'image/webp';

      final draft = await SmartParserService.parseReceiptImage(bytes, mimeType);
      
      if (draft != null) {
        if (draft.amount < 0) {
          if (mounted) {
            showCustomDialog(
              context: context,
              accentColor: AppColors.error,
              title: "Fiş Okunamadı",
              content: draft.note ?? "Yüklenen görselde herhangi bir fiş veya fatura bilgisi tespit edilemedi.",
              actions: [
                PrecisionDialogAction(
                  label: "Kapat",
                  onTap: () => Navigator.pop(context),
                  isPrimary: true,
                ),
              ],
            );
          }
          return;
        }

        await ref.read(smartInboxDraftsProvider.notifier).addDraft(draft);
        await ref.read(subscriptionServiceProvider).incrementAiUsage();
        if (mounted) {
          CustomNotification.success(context, 'Fiş verileri başarıyla gelen kutusuna eklendi.');
        }
        HapticFeedback.heavyImpact();
      } else {
        if (mounted) {
          CustomNotification.error(context, 'Fiş okunamadı. Lütfen bilgileri el ile girin veya daha net bir fotoğraf çekin.');
        }
      }
    } catch (e) {
      debugPrint('❌ OCR Hatası: $e');
      if (mounted) {
        final errorMsg = e.toString().replaceAll('Exception: ', '');
        CustomNotification.error(context, errorMsg.isNotEmpty ? errorMsg : 'Görsel yüklenirken bir hata oluştu.');
      }
    } finally {
      ref.read(smartInboxLoadingProvider.notifier).state = null;
    }
  }

  /// Taslağı sil
  Future<void> _deleteDraft(String id) async {
    setState(() {
      _selectedVaultIdForDraft.remove(id);
    });
    await ref.read(smartInboxDraftsProvider.notifier).deleteDraft(id);
    if (mounted) {
      CustomNotification.info(context, 'Taslak harcama silindi.');
    }
    HapticFeedback.lightImpact();
  }

  /// Taslağı onaylayıp kasaya gönder
  Future<void> _approveDraft(String id) async {
    final drafts = ref.read(smartInboxDraftsProvider);
    final vaults = ref.read(allVaultsProvider);
    final defaultVaultId = vaults.isNotEmpty ? vaults.first.id : -1;
    final vaultId = _selectedVaultIdForDraft[id] ?? defaultVaultId;
    final actualVaultId = vaultId == -1 ? null : vaultId;

    // Get category name for the draft
    final draftIndex = drafts.indexWhere((d) => d.id == id);
    String categoryName = 'Diğer';
    if (draftIndex != -1) {
      final draft = drafts[draftIndex];
      final customCategories = ref.read(customCategoriesProvider);
      categoryName = CategoryUtils.getCategoryName(
        categoryId: draft.categoryId,
        context: context,
        customCategories: customCategories,
        fallbackTitle: draft.title,
      );
    }

    setState(() {
      _selectedVaultIdForDraft.remove(id);
    });

    final success = await DraftService.promoteToTransaction(id, actualVaultId, categoryName);
    if (success) {
      await ref.read(smartInboxDraftsProvider.notifier).loadDrafts();
      if (mounted) {
        CustomNotification.success(context, 'İşlem kasaya başarıyla işlendi!');
      }
      HapticFeedback.heavyImpact();
    } else {
      await ref.read(smartInboxDraftsProvider.notifier).loadDrafts();
      if (mounted) {
        CustomNotification.error(context, 'İşlem onaylanırken bir hata oluştu.');
      }
    }
  }

  /// Detaylı harcama sayfasına yönlendir (✏️ Edit)
  void _navigateToDetailedAdd(DraftTransaction draft) {
    Navigator.push(
      context,
      SlideUpPageRoute(
        child: TransactionBuilderScreen(
          initialName: draft.title,
          initialAmount: draft.amount,
          initialMinAmount: draft.minAmount,
          initialMaxAmount: draft.maxAmount,
          initialIsIncome: draft.isIncome,
          initialNote: draft.note,
          initialCategoryId: draft.categoryId,
          initialRecurrenceDate: draft.date,
          initialCurrency: draft.currency,
          initialIsNotificationEnabled: draft.isNotificationEnabled,
          initialNotificationReminderDays: draft.notificationReminderDays,
          initialNotificationHour: draft.notificationHour,
          initialNotificationMinute: draft.notificationMinute,
          initialPeriodType: draft.periodType,
          initialRecurrenceDay: draft.recurrenceDay,
          initialRecurrenceDuration: draft.recurrenceDuration,
          initialVaultIds: _selectedVaultIdForDraft[draft.id] != null && _selectedVaultIdForDraft[draft.id] != -1
              ? [_selectedVaultIdForDraft[draft.id]!] 
              : null,
          onSuccess: () {
            ref.read(smartInboxDraftsProvider.notifier).deleteDraft(draft.id);
            Navigator.pop(context);
          },
        ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final drafts = ref.watch(smartInboxDraftsProvider);
    final vaults = ref.watch(allVaultsProvider);
    final loadingMessage = ref.watch(smartInboxLoadingProvider);
    
    // Taslaklar için varsayılan kasayı (İlk Kasa) ata veya AI tarafından çıkarılan kasa adıyla eşleştir
    for (final draft in drafts) {
      if (!_selectedVaultIdForDraft.containsKey(draft.id)) {
        int matchedId = vaults.isNotEmpty ? vaults.first.id : -1; // Varsayılan: İlk Kasa
        if (draft.vaultName != null && draft.vaultName!.trim().isNotEmpty) {
          final cleanDraft = draft.vaultName!.toLowerCase()
              .replaceAll('kasa', '')
              .replaceAll('hesap', '')
              .replaceAll('ı', 'i')
              .replaceAll('ş', 's')
              .replaceAll('ğ', 'g')
              .replaceAll('ü', 'u')
              .replaceAll('ö', 'o')
              .replaceAll('ç', 'c')
              .trim();
          if (cleanDraft.isNotEmpty) {
            for (final vault in vaults) {
              final cleanVault = vault.name.toLowerCase()
                  .replaceAll('kasa', '')
                  .replaceAll('hesap', '')
                  .replaceAll('ı', 'i')
                  .replaceAll('ş', 's')
                  .replaceAll('ğ', 'g')
                  .replaceAll('ü', 'u')
                  .replaceAll('ö', 'o')
                  .replaceAll('ç', 'c')
                  .trim();
              if (cleanVault.contains(cleanDraft) || cleanDraft.contains(cleanVault)) {
                matchedId = vault.id;
                break;
              }
            }
          }
        }
        _selectedVaultIdForDraft[draft.id] = matchedId;
      }
    }

    final currencySymbol = ref.watch(settingsProvider).currencySymbol;
    final topPadding = MediaQuery.of(context).padding.top;

    final listPadding = EdgeInsets.fromLTRB(
      16,
      topPadding + 140.0,
      16,
      32,
    );

    return Stack(
      children: [
        const Positioned.fill(
          child: AuthBackground(useSystemBackground: false),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              // 1. ANA İÇERİK BÖLGESİ
              Positioned.fill(
                child: SafeArea(
                  bottom: false,
                  child: drafts.isEmpty
                      ? const SmartInboxEmptyState()
                      : _buildDraftsList(drafts, vaults, currencySymbol, listPadding),
                ),
              ),

              // 2. STATİK GİRİŞ ALANI (Başlığın altında konumlanır)
              Positioned(
                top: topPadding + 74.0,
                left: 0,
                right: 0,
                child: SmartInputArea(
                  controller: _inputController,
                  onCameraPressed: () => _pickAndParseReceipt(ImageSource.camera),
                  onGalleryPressed: () => _pickAndParseReceipt(ImageSource.gallery),
                  onSendPressed: _parseAndAddText,
                ),
              ),

              // 3. ÖZEL BAŞLIK ALANI (Kasalar sayfasıyla birebir uyumlu)
              Positioned(
                left: 20,
                top: topPadding + 10,
                child: Text(
                  Localizations.localeOf(context).languageCode == 'tr' ? 'Smart Scan' : 'Smart Scan',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.5,
                  ),
                ),
              ),

              // 3. LOADING OVERLAY
              if (loadingMessage != null)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.7),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: CustomCard(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: 24),
                              Text(
                                loadingMessage,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDraftsList(List<DraftTransaction> drafts, List<Vault> vaults, String currencySymbol, EdgeInsets padding) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: padding,
      children: [
        if (drafts.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Text(
                  'ONAY BEKLEYEN İŞLEMLER (${drafts.length})',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: AppColors.getTextFaint(context),
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    ref.read(smartInboxDraftsProvider.notifier).clearAllDrafts();
                    setState(() {
                      _selectedVaultIdForDraft.clear();
                    });
                  },
                  child: Text(
                    'Tümünü Temizle',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.getExpense(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
          ),
          ...drafts.map((draft) {
            final defaultVaultId = vaults.isNotEmpty ? vaults.first.id : -1;
            final selectedVaultId = _selectedVaultIdForDraft[draft.id] ?? defaultVaultId;
            final index = drafts.indexOf(draft);
            return StaggeredEntryAnim(
              key: ValueKey(draft.id),
              index: index,
              animate: true,
              child: DismissibleDraftCard(
                draft: draft,
                vaults: vaults,
                currencySymbol: currencySymbol,
                selectedVaultId: selectedVaultId,
                onVaultSelected: (vaultId) {
                  setState(() {
                    _selectedVaultIdForDraft[draft.id] = vaultId;
                  });
                },
                onEdit: () => _navigateToDetailedAdd(draft),
                onApprove: () => _approveDraft(draft.id),
                onDelete: () => _deleteDraft(draft.id),
              ),
            );
          }),
          const SizedBox(height: 32),
        ],
      ],
    );
  }
}
