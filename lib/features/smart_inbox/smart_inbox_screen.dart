import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_constants.dart';
import '../../core/database/models/vault.dart';
import '../../core/providers/db_providers.dart';
import '../../core/providers/settings_provider.dart';
import '../../shared/widgets/custom_card.dart';
import '../../shared/widgets/custom_notification.dart';
import '../transactions/add_transaction_screen.dart';
import 'services/draft_service.dart';
import 'services/smart_parser_service.dart';
import '../auth/widgets/auth_background.dart';
import '../vaults/widgets/header_delegate.dart';
import '../../core/utils/category_utils.dart';

// Modular Widgets
import 'widgets/empty_state.dart';
import 'widgets/smart_input_area.dart';
import 'widgets/clipboard_banner.dart';
import 'widgets/draft_card.dart';

class SmartInboxScreen extends ConsumerStatefulWidget {
  const SmartInboxScreen({super.key});

  @override
  ConsumerState<SmartInboxScreen> createState() => _SmartInboxScreenState();
}

class _SmartInboxScreenState extends ConsumerState<SmartInboxScreen> with WidgetsBindingObserver {
  List<DraftTransaction> _drafts = [];
  final TextEditingController _inputController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  
  bool _isLoading = false;
  String _loadingMessage = '';
  
  // Her bir taslak kartı için seçilen kasa ID'sini tutar (-1 = Ana Kasa)
  final Map<String, int> _selectedVaultIdForDraft = {};
  
  // Panodan otomatik yakalanan taslak harcama
  DraftTransaction? _detectedClipboardDraft;
  String? _rawClipboardText;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadDrafts();
    _checkClipboard();
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
      _checkClipboard();
    }
  }

  /// Taslakları yükle
  Future<void> _loadDrafts() async {
    final list = await DraftService.getDrafts();
    if (mounted) {
      setState(() {
        _drafts = list;
      });
    }
  }

  /// Pano (Clipboard) taraması
  Future<void> _checkClipboard() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      final text = clipboardData?.text;
      if (text != null && text.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        final lastChecked = prefs.getString('last_checked_clipboard') ?? '';
        if (text == lastChecked) return;

        final parsed = await SmartParserService.checkAndParseClipboard(text);
        if (parsed != null && parsed.amount > 0) {
          if (mounted) {
            setState(() {
              _detectedClipboardDraft = parsed;
              _rawClipboardText = text;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Pano denetimi hatası: $e');
    }
  }

  /// Pano taslağını onaylama
  Future<void> _approveClipboardDraft() async {
    if (_detectedClipboardDraft == null || _rawClipboardText == null) return;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_checked_clipboard', _rawClipboardText!);

    await DraftService.addDraft(_detectedClipboardDraft!);
    
    setState(() {
      _detectedClipboardDraft = null;
      _rawClipboardText = null;
    });
    
    await _loadDrafts();
    
    if (mounted) {
      CustomNotification.success(context, 'Harcama sepetinize başarıyla eklendi!');
    }
    HapticFeedback.mediumImpact();
  }

  /// Pano taslağını yoksayma
  Future<void> _rejectClipboardDraft() async {
    if (_rawClipboardText == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_checked_clipboard', _rawClipboardText!);
    
    setState(() {
      _detectedClipboardDraft = null;
      _rawClipboardText = null;
    });
    HapticFeedback.lightImpact();
  }

  /// Metin ile işlem analiz et
  Future<void> _parseAndAddText() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _loadingMessage = 'Yapay zeka harcamanızı çözümlüyor...';
    });

    try {
      final draft = await SmartParserService.parseText(text);
      await DraftService.addDraft(draft);
      _inputController.clear();
      await _loadDrafts();
      
      if (mounted) {
        CustomNotification.success(context, 'Taslak harcama sepete eklendi.');
      }
      HapticFeedback.heavyImpact();
    } catch (e) {
      if (mounted) {
        final errorMsg = e.toString().replaceAll('Exception: ', '');
        CustomNotification.error(context, errorMsg.isNotEmpty ? errorMsg : 'İşlem analiz edilirken bir hata oluştu.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Fiş / Fatura okuma (OCR)
  Future<void> _pickAndParseReceipt(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: source, imageQuality: 85);
      if (image == null) return;

      setState(() {
        _isLoading = true;
        _loadingMessage = 'Fiş taranıyor, bilgiler çıkartılıyor...';
      });

      final bytes = await image.readAsBytes();
      final extension = image.path.split('.').last.toLowerCase();
      String mimeType = 'image/jpeg';
      if (extension == 'png') mimeType = 'image/png';
      if (extension == 'webp') mimeType = 'image/webp';

      final draft = await SmartParserService.parseReceiptImage(bytes, mimeType);
      
      if (draft != null) {
        await DraftService.addDraft(draft);
        await _loadDrafts();
        if (mounted) {
          CustomNotification.success(context, 'Fiş verileri başarıyla sepetinize eklendi.');
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
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Mikrofon özelliği hakkında geri bildirim göster
  void _showMicFeatureFeedback() {
    CustomNotification.success(context, 'Ses kaydetme özelliği çok yakında!');
    HapticFeedback.mediumImpact();
  }

  /// Taslağı sil
  Future<void> _deleteDraft(String id) async {
    setState(() {
      _drafts.removeWhere((d) => d.id == id);
      _selectedVaultIdForDraft.remove(id);
    });
    await DraftService.deleteDraft(id);
    await _loadDrafts();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Taslak harcama silindi.'),
          duration: Duration(seconds: 1),
        ),
      );
    }
    HapticFeedback.lightImpact();
  }

  /// Taslağı onaylayıp kasaya gönder
  Future<void> _approveDraft(String id) async {
    final vaultId = _selectedVaultIdForDraft[id] ?? -1;
    final actualVaultId = vaultId == -1 ? null : vaultId;

    // Get category name for the draft
    final draftIndex = _drafts.indexWhere((d) => d.id == id);
    String categoryName = 'Diğer';
    if (draftIndex != -1) {
      final draft = _drafts[draftIndex];
      final customCategories = ref.read(customCategoriesProvider);
      categoryName = CategoryUtils.getCategoryName(
        categoryId: draft.categoryId,
        context: context,
        customCategories: customCategories,
        fallbackTitle: draft.title,
      );
    }

    setState(() {
      _drafts.removeWhere((d) => d.id == id);
      _selectedVaultIdForDraft.remove(id);
    });

    final success = await DraftService.promoteToTransaction(id, actualVaultId, categoryName);
    if (success) {
      await _loadDrafts();
      if (mounted) {
        CustomNotification.success(context, 'İşlem kasaya başarıyla işlendi!');
      }
      HapticFeedback.heavyImpact();
    } else {
      await _loadDrafts();
      if (mounted) {
        CustomNotification.error(context, 'İşlem onaylanırken bir hata oluştu.');
      }
    }
  }

  /// Detaylı harcama sayfasına yönlendir (✏️ Edit)
  void _navigateToDetailedAdd(DraftTransaction draft) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionScreen(
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
            DraftService.deleteDraft(draft.id);
            Navigator.pop(context);
            _loadDrafts();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vaults = ref.watch(allVaultsProvider);
    
    // Taslaklar için varsayılan kasayı (-1 = Ana Kasa) ata veya AI tarafından çıkarılan kasa adıyla eşleştir
    for (final draft in _drafts) {
      if (!_selectedVaultIdForDraft.containsKey(draft.id)) {
        int matchedId = -1; // Varsayılan: Ana Kasa
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

    return Stack(
      children: [
        const Positioned.fill(
          child: AuthBackground(useSystemBackground: false),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: _drafts.isNotEmpty || _detectedClipboardDraft != null,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'SEPET',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: HeaderIconButton(
                  icon: Icons.refresh_rounded,
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    _loadDrafts();
                    _checkClipboard();
                  },
                ),
              ),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              const barHeight = 74.0;

              final listPadding = const EdgeInsets.fromLTRB(
                16,
                16 + barHeight,
                16,
                32,
              );

              return Stack(
                children: [
                  // 1. ANA İÇERİK BÖLGESİ
                  Positioned.fill(
                    child: SafeArea(
                      bottom: false,
                      child: _drafts.isEmpty && _detectedClipboardDraft == null
                          ? const SmartInboxEmptyState()
                          : _buildDraftsList(vaults, currencySymbol, listPadding),
                    ),
                  ),

                  // 2. STATİK GİRİŞ ALANI
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: SmartInputArea(
                      controller: _inputController,
                      onCameraPressed: () => _pickAndParseReceipt(ImageSource.camera),
                      onGalleryPressed: () => _pickAndParseReceipt(ImageSource.gallery),
                      onMicPressed: _showMicFeatureFeedback,
                      onSendPressed: _parseAndAddText,
                    ),
                  ),

                  // 3. LOADING OVERLAY
                  if (_isLoading)
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
                                    _loadingMessage,
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
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDraftsList(List<Vault> vaults, String currencySymbol, EdgeInsets padding) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: padding,
      children: [
        // PANODAN YAKALANAN HARCAMA (Eğer varsa)
        if (_detectedClipboardDraft != null)
          ClipboardBanner(
            draft: _detectedClipboardDraft!,
            onApprove: _approveClipboardDraft,
            onReject: _rejectClipboardDraft,
          ),

        if (_drafts.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Text(
                  'ONAY BEKLEYEN İŞLEMLER (${_drafts.length})',
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
                    setState(() {
                      _drafts.clear();
                      _selectedVaultIdForDraft.clear();
                    });
                    DraftService.saveDrafts([]);
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
          ..._drafts.map((draft) {
            final selectedVaultId = _selectedVaultIdForDraft[draft.id] ?? -1;
            return DismissibleDraftCard(
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
            );
          }),
          const SizedBox(height: 32),
        ],
      ],
    );
  }
}

