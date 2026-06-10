import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_constants.dart';
import '../../core/database/models/vault.dart';
import '../../core/providers/db_providers.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/providers/auth_provider.dart';
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
import '../../l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
    if (isPro) {
      showCustomDialog(
        context: context,
        accentColor: const Color(0xFFFFB300), // Altın rengi
        title: l10n.unlimitedAccessLimit,
        content: l10n.unlimitedAccessLimitDesc,
        actions: [
          PrecisionDialogAction(
            label: l10n.close,
            onTap: () => Navigator.pop(context),
            isPrimary: true,
          ),
        ],
      );
    } else {
      showCustomDialog(
        context: context,
        accentColor: const Color(0xFFFFB300), // Altın rengi
        title: l10n.standardAccessLimit,
        content: l10n.standardAccessLimitDesc,
        actions: [
          PrecisionDialogAction(
            label: l10n.later,
            onTap: () => Navigator.pop(context),
            isPrimary: false,
          ),
          PrecisionDialogAction(
            label: l10n.upgradeToExtendedAccess,
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
    final l10n = AppLocalizations.of(context)!;
    showCustomDialog(
      context: context,
      accentColor: AppColors.primary,
      title: l10n.loginRequired,
      content: l10n.loginRequiredDesc,
      actions: [
        PrecisionDialogAction(
          label: l10n.cancel,
          onTap: () => Navigator.pop(context),
          isPrimary: false,
        ),
        PrecisionDialogAction(
          label: l10n.loginOrSignUp,
          onTap: () async {
            Navigator.pop(context);
            await ref.read(authControllerProvider.notifier).exitGuestMode();
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

    final l10n = AppLocalizations.of(context)!;
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

    ref.read(smartInboxLoadingProvider.notifier).state = l10n.aiAnalyzingExpense;

    try {
      final draft = await SmartParserService.parseText(text, l10n);
      await ref.read(smartInboxDraftsProvider.notifier).addDraft(draft);
      await ref.read(subscriptionServiceProvider).incrementAiUsage();
      _inputController.clear();
      
      if (mounted) {
        CustomNotification.success(context, l10n.draftAddedToInbox);
      }
      HapticFeedback.heavyImpact();
    } catch (e) {
      if (mounted) {
        final errorMsg = e.toString().replaceAll('Exception: ', '');
        CustomNotification.error(context, errorMsg.isNotEmpty ? errorMsg : l10n.analysisError);
      }
    } finally {
      ref.read(smartInboxLoadingProvider.notifier).state = null;
    }
  }

  /// Fiş / Fatura okuma (OCR)
  Future<void> _pickAndParseReceipt(ImageSource source) async {
    final l10n = AppLocalizations.of(context)!;
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

      ref.read(smartInboxLoadingProvider.notifier).state = l10n.scanningReceipt;

      final bytes = await image.readAsBytes();
      final extension = image.path.split('.').last.toLowerCase();
      String mimeType = 'image/jpeg';
      if (extension == 'png') mimeType = 'image/png';
      if (extension == 'webp') mimeType = 'image/webp';

      final draft = await SmartParserService.parseReceiptImage(bytes, mimeType, l10n);
      
      if (draft != null) {
        if (draft.amount < 0) {
          if (mounted) {
            showCustomDialog(
              context: context,
              accentColor: AppColors.error,
              title: l10n.receiptUnreadable,
              content: draft.note ?? l10n.receiptUnreadableDesc,
              actions: [
                PrecisionDialogAction(
                  label: l10n.close,
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
          CustomNotification.success(context, l10n.receiptAddedToInbox);
        }
        HapticFeedback.heavyImpact();
      } else {
        if (mounted) {
          CustomNotification.error(context, l10n.receiptReadError);
        }
      }
    } catch (e) {
      debugPrint('❌ OCR Hatası: $e');
      if (mounted) {
        final errorMsg = e.toString().replaceAll('Exception: ', '');
        CustomNotification.error(context, errorMsg.isNotEmpty ? errorMsg : l10n.imageUploadError);
      }
    } finally {
      ref.read(smartInboxLoadingProvider.notifier).state = null;
    }
  }

  /// Taslağı sil
  Future<void> _deleteDraft(String id) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _selectedVaultIdForDraft.remove(id);
    });
    await ref.read(smartInboxDraftsProvider.notifier).deleteDraft(id);
    if (mounted) {
      CustomNotification.info(context, l10n.draftDeleted);
    }
    HapticFeedback.lightImpact();
  }

  /// Taslağı onaylayıp kasaya gönder
  Future<void> _approveDraft(String id) async {
    final l10n = AppLocalizations.of(context)!;
    final drafts = ref.read(smartInboxDraftsProvider);
    final vaults = ref.read(allVaultsProvider);
    final defaultVaultId = vaults.isNotEmpty ? vaults.first.id : -1;
    final vaultId = _selectedVaultIdForDraft[id] ?? defaultVaultId;
    final actualVaultId = vaultId == -1 ? null : vaultId;

    // Get category name for the draft
    final draftIndex = drafts.indexWhere((d) => d.id == id);
    String categoryName = l10n.otherCategory;
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
        CustomNotification.success(context, l10n.transactionProcessedSuccess);
      }
      HapticFeedback.heavyImpact();
    } else {
      await ref.read(smartInboxDraftsProvider.notifier).loadDrafts();
      if (mounted) {
        CustomNotification.error(context, l10n.transactionApprovalError);
      }
    }
  }

  /// Detaylı harcama sayfasına yönlendir (✏️ Edit)
  void _navigateToDetailedAdd(DraftTransaction draft) {
    final l10n = AppLocalizations.of(context)!;
    final displayTitle = draft.title == '__EMPTY_DRAFT__'
        ? ''
        : (draft.title == '__RECEIPT_EXPENSE__' ? l10n.receiptExpense : draft.title);

    Navigator.push(
      context,
      SlideUpPageRoute(
        child: TransactionBuilderScreen(
          initialName: displayTitle,
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
          initialTotalInstallments: draft.remainingInstallments,
          initialBuilderType: draft.periodType > 0
              ? TransactionBuilderType.recurring
              : TransactionBuilderType.oneTime,
          initialVaultId: _selectedVaultIdForDraft[draft.id] != null && _selectedVaultIdForDraft[draft.id] != -1
              ? _selectedVaultIdForDraft[draft.id]! 
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
                  AppLocalizations.of(context)!.smartScanTitle,
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
                  AppLocalizations.of(context)!.pendingApprovalCount(drafts.length),
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
                    AppLocalizations.of(context)!.clearAll,
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
