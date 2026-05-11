import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';

import '../../core/theme/app_constants.dart';
import '../../core/database/database_service.dart';
import '../../core/database/models/transaction_record.dart';
import '../../core/database/models/vault.dart';
import '../../core/services/custom_category_service.dart';

import 'widgets/transaction_vault_selector.dart';
import 'widgets/transaction_currency_selector.dart';
import 'widgets/transaction_type_toggle.dart';
import 'widgets/transaction_amount_input.dart';
import 'widgets/transaction_category_data.dart';
import 'widgets/transaction_category_selector.dart';
import 'widgets/transaction_period_selector.dart';
import '../../shared/widgets/precision_toggle.dart';
import '../../shared/widgets/precision_card.dart';
import '../../shared/widgets/precision_input.dart';
import '../../shared/widgets/precision_button.dart';
import '../../core/providers/settings_provider.dart';

class AddTransactionSheet extends ConsumerStatefulWidget {
  final int? initialId;
  final String? initialName;
  final double? initialAmount;
  final double? initialMinAmount;
  final double? initialMaxAmount;
  final bool? initialIsIncome;
  final List<int>? initialVaultIds;
  final String? initialCategoryId;
  final String? initialNote;
  final String? initialCurrency;
  
  // --- Tekrarlama (Periyot) Alanları ---
  final int? initialPeriodType;
  final int? initialRecurrenceDay;
  final DateTime? initialRecurrenceDate;
  final int? initialRecurrenceDuration;
  final VoidCallback? onSuccess;

  const AddTransactionSheet({
    super.key,
    this.initialId,
    this.initialName,
    this.initialAmount,
    this.initialMinAmount,
    this.initialMaxAmount,
    this.initialIsIncome,
    this.initialVaultIds,
    this.initialCategoryId,
    this.initialNote,
    this.initialCurrency,
    this.initialPeriodType,
    this.initialRecurrenceDay,
    this.initialRecurrenceDate,
    this.initialRecurrenceDuration,
    this.onSuccess,
  });

  @override
  ConsumerState<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<AddTransactionSheet> {
  int _tabIndex = 0;

  List<Vault> _vaults = [];
  List<int> _selectedVaultIds = [];
  List<Map<String, String>> _customSubs = [];

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _minController = TextEditingController();
  final TextEditingController _maxController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final FocusNode _amountFocusNode = FocusNode();

  bool _isFlexibleAmount = false;

  int _selectedCategoryIndex = 0;
  int _expandedCategoryIndex = -1;
  int _selectedSubModelIndex = -1;
  String _selectedCurrency = '₺';

  late TransactionPeriodData _periodData;

  bool _isPrefilled = false;
  String? _errorMessage;

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _periodData = TransactionPeriodData(
      periodType: 0,
      selectedDay: 1,
      selectedDateForRecurrence: DateTime.now(),
      duration: 0,
    );
    _loadVaults();
    _loadCustomCategories();
    _selectedCurrency = ref.read(settingsProvider).currencySymbol;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isFlexibleAmount && mounted) {
        _amountFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _minController.dispose();
    _maxController.dispose();
    _noteController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isPrefilled) {
      _prefillIfEditing();
      _isPrefilled = true;
    }
  }

  void _prefillIfEditing() {
    if (widget.initialId != null) {
      _tabIndex = widget.initialIsIncome == true ? 1 : 0;
      if (widget.initialAmount != null) {
        _amountController.text = widget.initialAmount!.toStringAsFixed(0);
      }
      if (widget.initialMinAmount != null) {
        _minController.text = widget.initialMinAmount!.toStringAsFixed(0);
        _isFlexibleAmount = true;
      }
      if (widget.initialMaxAmount != null) {
        _maxController.text = widget.initialMaxAmount!.toStringAsFixed(0);
        _isFlexibleAmount = true;
      }
      if (widget.initialNote != null) {
        _noteController.text = widget.initialNote!;
      }
      if (widget.initialCurrency != null) {
        _selectedCurrency = widget.initialCurrency!;
      }
      if (widget.initialVaultIds != null) {
        _selectedVaultIds = List<int>.from(widget.initialVaultIds!);
      }
      
      // --- Eski Periyot Ayarlarını Form'a Yükle ---
      if (widget.initialPeriodType != null && widget.initialPeriodType != 0) {
        _periodData = TransactionPeriodData(
          periodType: widget.initialPeriodType!,
          selectedDay: widget.initialRecurrenceDay ?? 1,
          selectedDateForRecurrence: widget.initialRecurrenceDate ?? DateTime.now(),
          duration: widget.initialRecurrenceDuration ?? 0,
          // expandedPeriodCategory null bırakılabilir, alt bileşen periodType'a göre kendi çıkarımını yapar
        );
      }
      
      if (widget.initialCategoryId != null) {
        final categories = _getMergedCategories();
            
        for (int i = 0; i < categories.length; i++) {
          final cat = categories[i];
          if (cat['id'] == widget.initialCategoryId) {
            _selectedCategoryIndex = i;
            _selectedSubModelIndex = -1;
            break;
          }
          final subModels = cat['subModels'] as List?;
          if (subModels != null) {
            for (int j = 0; j < subModels.length; j++) {
              if (subModels[j]['id'] == widget.initialCategoryId) {
                _selectedCategoryIndex = i;
                _selectedSubModelIndex = j;
                break;
              }
            }
          }
        }
      }
    }
  }

  Future<void> _loadVaults() async {
    final v = await DatabaseService.getAllVaults();
    if (mounted) {
      setState(() {
        _vaults = v;
      });
    }
  }

  Future<void> _loadCustomCategories() async {
    final customs = await CustomCategoryService.getAllCustomSubcategories();
    if (mounted) {
      setState(() {
        _customSubs = customs;
      });
    }
  }

  List<Map<String, dynamic>> _getMergedCategories() {
    final base = _tabIndex == 0 
        ? TransactionCategoryData.getExpenseCategories(context, l10n)
        : TransactionCategoryData.getIncomeCategories(context, l10n);
    return TransactionCategoryData.mergeCustomSubcategories(base, _customSubs);
  }

  Future<void> _showAddCustomCategoryDialog(String parentCategoryId) async {
    final controller = TextEditingController();
    final parentCat = _getMergedCategories().firstWhere(
      (c) => c['id'] == parentCategoryId,
      orElse: () => <String, dynamic>{},
    );
    if (parentCat.isEmpty) return;

    final parentColor = parentCat['color'] as Color;
    final parentIcon = parentCat['icon'] as IconData;
    final parentName = parentCat['name'] as String;

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: parentColor.withValues(alpha: 0.15),
                ),
                child: Icon(parentIcon, color: parentColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.addCustomCategory,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.getTextPrimary(ctx),
                      ),
                    ),
                    Text(
                      parentName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: parentColor.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            maxLength: 30,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextPrimary(ctx),
            ),
            decoration: InputDecoration(
              hintText: l10n.customCategoryHint,
              hintStyle: TextStyle(
                color: AppColors.getTextSecondary(ctx).withValues(alpha: 0.5),
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Icon(parentIcon, color: parentColor.withValues(alpha: 0.5), size: 20),
              filled: true,
              fillColor: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: parentColor.withValues(alpha: 0.4), width: 1.5),
              ),
              counterStyle: TextStyle(
                color: AppColors.getTextSecondary(ctx).withValues(alpha: 0.4),
                fontSize: 11,
              ),
            ),
            onSubmitted: (val) {
              if (val.trim().isNotEmpty) Navigator.pop(ctx, val.trim());
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                l10n.cancel,
                style: TextStyle(
                  color: AppColors.getTextSecondary(ctx),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            FilledButton(
              onPressed: () {
                final val = controller.text.trim();
                if (val.isNotEmpty) Navigator.pop(ctx, val);
              },
              style: FilledButton.styleFrom(
                backgroundColor: parentColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                l10n.save,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      await CustomCategoryService.addCustomSubcategory(parentCategoryId, result);
      await _loadCustomCategories();

      // Yeni eklenen alt kategoriyi otomatik seç
      final merged = _getMergedCategories();
      final parentIndex = merged.indexWhere((c) => c['id'] == parentCategoryId);
      if (parentIndex != -1) {
        final subs = merged[parentIndex]['subModels'] as List;
        setState(() {
          _selectedCategoryIndex = parentIndex;
          _selectedSubModelIndex = subs.length - 1; // Son eklenen
          _expandedCategoryIndex = parentIndex;
        });
      }
      HapticFeedback.mediumImpact();
    }
  }

  Future<void> _handleRemoveCustomCategory(String subcategoryId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            l10n.deleteCustomCategory,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.getTextPrimary(ctx),
            ),
          ),
          content: Text(
            l10n.deleteCustomCategoryConfirm,
            style: TextStyle(
              color: AppColors.getTextSecondary(ctx),
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                l10n.cancel,
                style: TextStyle(
                  color: AppColors.getTextSecondary(ctx),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.getExpense(ctx),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                l10n.yes,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await CustomCategoryService.removeCustomSubcategory(subcategoryId);
      await _loadCustomCategories();
      setState(() {
        _selectedSubModelIndex = -1;
      });
      HapticFeedback.lightImpact();
    }
  }

  Future<void> _saveTransaction() async {
    final amountStr = _amountController.text.trim();
    final minStr = _minController.text.trim();
    final maxStr = _maxController.text.trim();

    String sanitize(String input) {
      if (input.isEmpty) return '0';
      final clean = input.trim();
      if (clean.contains(',')) {
        return clean.replaceAll('.', '').replaceAll(',', '.');
      } else {
        if (RegExp(r'\.\d{3}$').hasMatch(clean)) {
          return clean.replaceAll('.', '');
        }
        return clean;
      }
    }

    final amount = double.tryParse(sanitize(amountStr)) ?? 0.0;
    final minAmount = double.tryParse(sanitize(minStr)) ?? 0.0;
    final maxAmount = double.tryParse(sanitize(maxStr)) ?? 0.0;
    // --- Validasyon Kontrolleri ---
    if (!_isFlexibleAmount && amount <= 0) {
      _showValidationError('Lütfen geçerli bir tutar girin.');
      return;
    }

    if (_isFlexibleAmount) {
      if (maxAmount <= 0) {
        _showValidationError('Maksimum tutar 0\'dan büyük olmalıdır.');
        return;
      }
      if (minAmount >= maxAmount) {
        _showValidationError('Minimum tutar maksimumdan küçük olmalıdır.');
        return;
      }
    }

    // Eğer esnek tutar aktifse ana amount 0 kaydedilir (model otomatik ortalamayı hesaplasın diye)
    final finalAmount = _isFlexibleAmount ? 0.0 : amount;
    final finalMin = _isFlexibleAmount ? minAmount : null;
    final finalMax = _isFlexibleAmount ? maxAmount : null;
    
    final categories = _getMergedCategories();
        
    final cat = categories[_selectedCategoryIndex];
    final String categoryId = _selectedSubModelIndex != -1 
        ? (cat['subModels'] as List)[_selectedSubModelIndex]['id'] as String
        : cat['id'] as String;

    if (widget.initialId != null) {
      final old = await DatabaseService.getTransaction(widget.initialId!);
      if (old != null) {
        final catName = _selectedSubModelIndex != -1 
            ? (cat['subModels'] as List)[_selectedSubModelIndex]['name'] as String
            : cat['name'] as String;
            
        old.title = catName;
        old.amount = finalAmount;
        old.minAmount = finalMin;
        old.maxAmount = finalMax;
        old.isIncome = _tabIndex == 1;
        old.vaultIds = _selectedVaultIds;
        old.categoryId = categoryId;
        
        // --- Periyot Verilerini Eksiksiz Kaydet ---
        old.periodType = _periodData.periodType;
        old.recurrenceDay = _periodData.selectedDay;
        old.recurrenceDate = _periodData.selectedDateForRecurrence;
        old.recurrenceDuration = _periodData.duration;
        
        old.note = _noteController.text.isNotEmpty ? _noteController.text : null;
        old.currency = _selectedCurrency;
        
        await DatabaseService.updateTransaction(old);
      }
    } else {
      final catName = _selectedSubModelIndex != -1 
          ? (cat['subModels'] as List)[_selectedSubModelIndex]['name'] as String
          : cat['name'] as String;

      DateTime initialDate = DateTime.now();
      
      // Eğer periyodik bir işlemse ve belirli bir gün seçilmişse başlangıç tarihini ona göre ayarla
      if (_periodData.periodType != 0) {
        final now = DateTime.now();
        if ([2, 3, 6, 7].contains(_periodData.periodType)) {
          // Ayın belirli bir günü seçilmişse
          final day = _periodData.selectedDay;
          if (now.day <= day) {
            initialDate = DateTime(now.year, now.month, day, now.hour, now.minute);
          } else {
            // Bu ayın günü geçtiyse sonraki aya at (isteğe bağlı, ama genelde gelecek planlanır)
            initialDate = DateTime(now.year, now.month + 1, day, now.hour, now.minute);
          }
        }
      }

      final tx = TransactionRecord()
        ..title = catName
        ..amount = finalAmount
        ..minAmount = finalMin
        ..maxAmount = finalMax
        ..isIncome = _tabIndex == 1
        ..date = initialDate
        ..vaultIds = _selectedVaultIds
        ..categoryId = categoryId
        
        // --- Periyot Verilerini Eksiksiz Kaydet ---
        ..periodType = _periodData.periodType
        ..recurrenceDay = _periodData.selectedDay
        ..recurrenceDate = _periodData.selectedDateForRecurrence
        ..recurrenceDuration = _periodData.duration
        
        ..note = _noteController.text.isNotEmpty ? _noteController.text : null
        ..currency = _selectedCurrency;
      
      await DatabaseService.addTransaction(tx);
    }
    
    if (mounted) {
      if (widget.onSuccess != null) {
        widget.onSuccess!();
      } else {
        Navigator.pop(context);
      }
    }
    HapticFeedback.heavyImpact();
  }

  void _showValidationError(String message) {
    HapticFeedback.vibrate();
    setState(() => _errorMessage = message);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final scalingFactor = (screenHeight / 812.0).clamp(0.85, 1.0);
    final activeCategories = _getMergedCategories();

    return RepaintBoundary(
      child: Column(
        children: [
        TransactionTypeToggle(
            tabIndex: _tabIndex,
            onTabChanged: (index) {
              HapticFeedback.selectionClick();
              setState(() {
                _tabIndex = index;
                _selectedCategoryIndex = 0;
                _expandedCategoryIndex = -1;
                _selectedSubModelIndex = -1;
              });
            },
          ),

          const SizedBox(height: AppSizes.paddingMedium),

          TransactionAmountInput(
            isFlexibleAmount: _isFlexibleAmount,
            currency: _selectedCurrency, // <-- Eklendi: Kullanıcının seçtiği birim buraya akıyor
            amountController: _amountController,
            minController: _minController,
            maxController: _maxController,
            amountFocusNode: _amountFocusNode,
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
            child: PrecisionCard(
              scalingFactor: scalingFactor,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.linear_scale_rounded, 
                        size: 20, 
                        color: AppColors.getPrimary(context).withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        l10n.flexibleAmount,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.getTextPrimary(context),
                        ),
                      ),
                    ],
                  ),
                  PrecisionToggle(
                    value: _isFlexibleAmount,
                    activeColor: AppColors.getPrimary(context),
                    activeIcon: Icons.pause_rounded,
                    inactiveIcon: Icons.stop_rounded,
                    scalingFactor: scalingFactor * 0.9,
                    onChanged: (val) {
                      HapticFeedback.mediumImpact();
                      setState(() {
                        _isFlexibleAmount = val;
                        if (!val) {
                          _amountFocusNode.requestFocus();
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSizes.paddingLarge),

          TransactionCategorySelector(
            categories: activeCategories,
            selectedCategoryIndex: _selectedCategoryIndex,
            selectedSubModelIndex: _selectedSubModelIndex,
            expandedCategoryIndex: _expandedCategoryIndex,
            onChanged: (catIndex, subIndex, expIndex) {
              HapticFeedback.lightImpact();
              setState(() {
                _selectedCategoryIndex = catIndex;
                _selectedSubModelIndex = subIndex;
                _expandedCategoryIndex = expIndex;
              });
            },
            onAddCustomSubcategory: _showAddCustomCategoryDialog,
            onRemoveCustomSubcategory: _handleRemoveCustomCategory,
          ),

          const SizedBox(height: AppSizes.paddingLarge),

          // --- HESAP PARAMETRELERİ (KASA & PARA BİRİMİ) ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
            child: PrecisionCard(
              scalingFactor: scalingFactor,
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  // KASA
                    TransactionVaultSelector(
                      vaults: _vaults,
                      selectedVaultIds: _selectedVaultIds,
                      scalingFactor: scalingFactor,
                      onChanged: (ids) {
                        setState(() {
                          _selectedVaultIds = ids;
                          // Akıllı Birim Geçişi: Eğer bir kasa seçildiyse ve o kasanın özel bir birimi varsa ona geç
                          if (ids.isNotEmpty) {
                            final selectedVault = _vaults.firstWhere((v) => v.id == ids.first);
                            if (selectedVault.currency != 'AUTO') {
                              _selectedCurrency = selectedVault.currency;
                            }
                          }
                        });
                      },
                    ),
                  Divider(
                    height: 1,
                    thickness: 0.5,
                    indent: 16,
                    endIndent: 16,
                    color: (Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white 
                        : Colors.black).withValues(alpha: 0.08),
                  ),
                  // PARA BİRİMİ
                  TransactionCurrencySelector(
                    selectedCurrency: _selectedCurrency,
                    scalingFactor: scalingFactor,
                    onChanged: (val) {
                      setState(() => _selectedCurrency = val);
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSizes.paddingMedium),

                  // --- DETAYLAR (NOT & PERİYOT) ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
                    child: PrecisionCard(
                      scalingFactor: scalingFactor,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.notes_rounded, 
                                size: 20, 
                                color: AppColors.getPrimary(context).withValues(alpha: 0.7),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                l10n.description.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.getTextPrimary(context).withValues(alpha: 0.8),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          PrecisionInput(
                            controller: _noteController,
                            hintText: 'İşleme dair not bırakın...',
                            icon: Icons.edit_note_rounded,
                          ),
                          const SizedBox(height: 12),
                          Divider(
                            height: 24,
                            thickness: 0.5,
                            color: (Theme.of(context).brightness == Brightness.dark 
                                ? Colors.white 
                                : Colors.black).withValues(alpha: 0.08),
                          ),
                          const SizedBox(height: 12),
                          TransactionPeriodSelector(
                            initialData: _periodData,
                            scalingFactor: scalingFactor,
                            onChanged: (data) {
                              HapticFeedback.mediumImpact();
                              setState(() => _periodData = data);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

          const SizedBox(height: AppSizes.paddingMedium),

          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
            child: PrecisionButton(
              label: l10n.save,
              onTap: () {
                setState(() => _errorMessage = null);
                FocusManager.instance.primaryFocus?.unfocus();
                _saveTransaction();
              },
              activeColor: AppColors.getPrimary(context),
              height: 64,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
