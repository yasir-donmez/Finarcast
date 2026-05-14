import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../core/theme/app_constants.dart';
import '../../core/database/database_service.dart';
import '../../core/database/models/transaction_record.dart';
import '../../core/database/models/vault.dart';
import '../../core/services/custom_category_service.dart';
import '../../core/providers/settings_provider.dart';
import '../dashboard/dashboard_providers.dart';
import '../../core/services/notification_service.dart';

import 'widgets/transaction_vault_selector.dart';
import 'widgets/transaction_currency_selector.dart';
import 'widgets/transaction_type_toggle.dart';
import 'widgets/transaction_amount_input.dart';
import 'widgets/transaction_category_data.dart';
import 'widgets/transaction_category_selector.dart';
import 'widgets/transaction_period_selector.dart';
import 'widgets/transaction_reminder_days_selector.dart';
import 'widgets/transaction_reminder_time_selector.dart';
import '../../shared/widgets/precision_toggle.dart';
import '../../shared/widgets/precision_card.dart';
import '../../shared/widgets/precision_input.dart';
import '../../shared/widgets/precision_button.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
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
  
  final int? initialPeriodType;
  final int? initialRecurrenceDay;
  final DateTime? initialRecurrenceDate;
  final int? initialRecurrenceDuration;
  
  final bool? initialIsNotificationEnabled;
  final int? initialNotificationReminderDays;
  final int? initialNotificationHour;
  final int? initialNotificationMinute;

  final VoidCallback? onSuccess;

  const AddTransactionScreen({
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
    this.initialIsNotificationEnabled,
    this.initialNotificationReminderDays,
    this.initialNotificationHour,
    this.initialNotificationMinute,
    this.onSuccess,
  });

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
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
  bool _isNotificationEnabled = false;
  int _notificationReminderDays = 0;
  TimeOfDay _notificationTime = const TimeOfDay(hour: 9, minute: 0);
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
    // 1. DÜZENLEME MODU (Mevcut İşlem)
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
      if (widget.initialPeriodType != null && widget.initialPeriodType != 0) {
        _periodData = TransactionPeriodData(
          periodType: widget.initialPeriodType!,
          selectedDay: widget.initialRecurrenceDay ?? 1,
          selectedDateForRecurrence: widget.initialRecurrenceDate ?? DateTime.now(),
          duration: widget.initialRecurrenceDuration ?? 0,
        );
      }
      
      _isNotificationEnabled = widget.initialIsNotificationEnabled ?? false;
      _notificationReminderDays = widget.initialNotificationReminderDays ?? 0;
      if (widget.initialNotificationHour != null && widget.initialNotificationMinute != null) {
        _notificationTime = TimeOfDay(
          hour: widget.initialNotificationHour!,
          minute: widget.initialNotificationMinute!,
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
    // 2. YENİ KAYIT MODU (Parametreler Varsa)
    else {
      if (widget.initialIsIncome != null) {
        _tabIndex = widget.initialIsIncome! ? 1 : 0;
      }
      if (widget.initialVaultIds != null) {
        _selectedVaultIds = List<int>.from(widget.initialVaultIds!);
      }
      if (widget.initialCurrency != null) {
        _selectedCurrency = widget.initialCurrency!;
      }
      if (widget.initialIsNotificationEnabled != null) {
        _isNotificationEnabled = widget.initialIsNotificationEnabled!;
      }
    }
  }

  Future<void> _loadVaults() async {
    final v = await DatabaseService.getAllVaults();
    if (mounted) setState(() => _vaults = v);
  }

  Future<void> _loadCustomCategories() async {
    final customs = await CustomCategoryService.getAllCustomSubcategories();
    if (mounted) setState(() => _customSubs = customs);
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

    IconData selectedIcon = parentIcon;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final List<IconData> iconOptions = [
          parentIcon,
          Icons.star_rounded,
          Icons.favorite_rounded,
          Icons.shopping_bag_rounded,
          Icons.restaurant_rounded,
          Icons.local_cafe_rounded,
          Icons.directions_car_rounded,
          Icons.home_rounded,
          Icons.medical_services_rounded,
          Icons.school_rounded,
          Icons.fitness_center_rounded,
          Icons.sports_esports_rounded,
          Icons.camera_alt_rounded,
          Icons.brush_rounded,
          Icons.construction_rounded,
          Icons.pets_rounded,
        ];

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: parentColor.withValues(alpha: 0.15)),
                    child: Icon(selectedIcon, color: parentColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.addCustomCategory, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.getTextPrimary(ctx))),
                        Text(parentName, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: parentColor.withValues(alpha: 0.8))),
                      ],
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    autofocus: true,
                    textCapitalization: TextCapitalization.sentences,
                    maxLength: 30,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.getTextPrimary(ctx)),
                    decoration: InputDecoration(
                      hintText: l10n.customCategoryHint,
                      hintStyle: TextStyle(color: AppColors.getTextSecondary(ctx).withValues(alpha: 0.5), fontWeight: FontWeight.w400),
                      prefixIcon: Icon(selectedIcon, color: parentColor.withValues(alpha: 0.5), size: 20),
                      filled: true,
                      fillColor: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: parentColor.withValues(alpha: 0.4), width: 1.5)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.maxFinite,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: iconOptions.map((icon) {
                        final isSelected = selectedIcon == icon;
                        return GestureDetector(
                          onTap: () => setDialogState(() => selectedIcon = icon),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: isSelected ? parentColor.withValues(alpha: 0.2) : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? parentColor : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Icon(icon, color: isSelected ? parentColor : AppColors.getTextSecondary(ctx).withValues(alpha: 0.4), size: 20),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
                FilledButton(
                  onPressed: () {
                    final val = controller.text.trim();
                    if (val.isNotEmpty) {
                      Navigator.pop(ctx, {'name': val, 'iconCode': selectedIcon.codePoint});
                    }
                  },
                  style: FilledButton.styleFrom(backgroundColor: parentColor),
                  child: Text(l10n.save),
                ),
              ],
            );
          }
        );
      },
    );

    if (result != null && result['name'] != null) {
      await CustomCategoryService.addCustomSubcategory(
        parentCategoryId, 
        result['name'] as String, 
        result['iconCode'] as int,
      );
      await _loadCustomCategories();
      final merged = _getMergedCategories();
      final parentIndex = merged.indexWhere((c) => c['id'] == parentCategoryId);
      if (parentIndex != -1) {
        final subs = merged[parentIndex]['subModels'] as List;
        setState(() {
          _selectedCategoryIndex = parentIndex;
          _selectedSubModelIndex = subs.length - 1;
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(l10n.deleteCustomCategory),
          content: Text(l10n.deleteCustomCategoryConfirm),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(backgroundColor: AppColors.getExpense(ctx)),
              child: Text(l10n.yes),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await CustomCategoryService.removeCustomSubcategory(subcategoryId);
      await _loadCustomCategories();
      setState(() => _selectedSubModelIndex = -1);
      HapticFeedback.lightImpact();
    }
  }

  Future<void> _saveTransaction() async {
    try {
      final amountStr = _amountController.text.trim();
      final minStr = _minController.text.trim();
      final maxStr = _maxController.text.trim();

      String sanitize(String input) {
        if (input.isEmpty) return '0';
        final clean = input.trim();
        if (clean.contains(',')) {
          return clean.replaceAll('.', '').replaceAll(',', '.');
        } else {
          if (RegExp(r'\.\d{3}$').hasMatch(clean)) return clean.replaceAll('.', '');
          return clean;
        }
      }

      final amount = double.tryParse(sanitize(amountStr)) ?? 0.0;
      final minAmount = double.tryParse(sanitize(minStr)) ?? 0.0;
      final maxAmount = double.tryParse(sanitize(maxStr)) ?? 0.0;

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
          old.periodType = _periodData.periodType;
          old.recurrenceDay = _periodData.selectedDay;
          old.recurrenceDate = _periodData.selectedDateForRecurrence;
          old.recurrenceDuration = _periodData.duration;
          old.note = _noteController.text.isNotEmpty ? _noteController.text : null;
          old.currency = _selectedCurrency;
          
          old.isNotificationEnabled = _isNotificationEnabled;
          old.notificationReminderDays = _notificationReminderDays;
          old.notificationHour = _notificationTime.hour;
          old.notificationMinute = _notificationTime.minute;
          
          await DatabaseService.updateTransaction(old);
        }
      } else {
        final catName = _selectedSubModelIndex != -1 
            ? (cat['subModels'] as List)[_selectedSubModelIndex]['name'] as String
            : cat['name'] as String;

        DateTime initialDate = DateTime.now();
        if (_periodData.periodType != 0) {
          final now = DateTime.now();
          if ([2, 3, 6, 7].contains(_periodData.periodType)) {
            final day = _periodData.selectedDay;
            if (now.day <= day) {
              initialDate = DateTime(now.year, now.month, day, now.hour, now.minute);
            } else {
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
          ..periodType = _periodData.periodType
          ..recurrenceDay = _periodData.selectedDay
          ..recurrenceDate = _periodData.selectedDateForRecurrence
          ..recurrenceDuration = _periodData.duration
          ..note = _noteController.text.isNotEmpty ? _noteController.text : null
          ..currency = _selectedCurrency
          ..isNotificationEnabled = _isNotificationEnabled
          ..notificationReminderDays = _notificationReminderDays
          ..notificationHour = _notificationTime.hour
          ..notificationMinute = _notificationTime.minute;
        
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
    } catch (e) {
      debugPrint('❌ [AddTransactionScreen] Kaydetme hatası: $e');
      _showValidationError('İşlem kaydedilirken bir hata oluştu: $e');
    }
  }

  void _onCurrencyChanged(String newCurrency) {
    if (newCurrency == _selectedCurrency) return;
    
    void formatFieldForNewCurrency(TextEditingController controller) {
      final text = controller.text.trim();
      if (text.isEmpty) return;
      
      // Sayıyı al (Formatı temizle)
      final valStr = text.replaceAll('.', '').replaceAll(',', '.');
      final val = double.tryParse(valStr);
      
      if (val != null) {
        // Kullanıcı sayının DEĞİŞMEMESİNİ istediği için convert yapmıyoruz.
        // Sadece yeni birimin format kurallarını uyguluyoruz (Örn: JPY için küsurat silme)
        final code = AppCurrency.getCode(newCurrency);
        final bool isZeroDecimal = (code == 'JPY' || code == 'KRW');
        
        int decimals = isZeroDecimal ? 0 : 2;
        if (val == val.toInt()) decimals = 0;
        
        String formatted = val.toStringAsFixed(decimals).replaceAll('.', ',');
        
        // Binlik ayırıcıları tekrar ekle
        if (formatted.contains(',')) {
          List<String> parts = formatted.split(',');
          parts[0] = parts[0].replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
          formatted = parts.join(',');
        } else {
          formatted = formatted.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
        }
        
        controller.text = formatted;
      }
    }

    setState(() {
      formatFieldForNewCurrency(_amountController);
      formatFieldForNewCurrency(_minController);
      formatFieldForNewCurrency(_maxController);
      _selectedCurrency = newCurrency;
    });
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = ref.watch(rotaryColorProvider);
    final double safeTop = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            stretch: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                final double currentH = constraints.biggest.height;
                final double minH = kToolbarHeight + safeTop;
                final double totalRange = (200 + safeTop - minH);
                
                // Güvenlik: Payda 0 ise t=0 kabul et
                double t = totalRange > 0 ? ((currentH - minH) / totalRange).clamp(0.0, 1.0) : 0.0;
                
                // NaN kontrolü
                if (t.isNaN) t = 0.0;
                
                final double revT = 1.0 - t;

                return Stack(
                  fit: StackFit.expand,
                  clipBehavior: Clip.none,
                  children: [
                    // GPU-Friendly Blur Layer
                    Positioned.fill(
                      child: Opacity(
                        opacity: revT,
                        child: ClipRect(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.getBackground(context).withValues(alpha: 0.15),
                                border: Border(
                                  bottom: BorderSide(
                                    color: (isDark ? Colors.white : Colors.black).withValues(
                                      alpha: revT > 0.95 ? (revT - 0.95) * 2 : 0.0,
                                    ),
                                    width: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Content Layer
                    Positioned.fill(
                      child: Stack(
                        fit: StackFit.expand,
                        clipBehavior: Clip.none,
                        children: [
                          // Gradient background
                          Positioned.fill(
                            child: Opacity(
                              opacity: t,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      activeColor.withValues(alpha: 0.15),
                                      activeColor.withValues(alpha: 0.03),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Title Morphing
                          Positioned(
                            top: safeTop + (kToolbarHeight - 20) / 2 + (t * 70),
                            left: 0,
                            right: 0,
                            child: IgnorePointer(
                              child: Text(
                                (widget.initialId != null ? l10n.edit : l10n.addTransaction).toUpperCase(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.getTextPrimary(context),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2.0 + (t * 2),
                                ),
                              ),
                            ),
                          ),

                          // Back Button
                          Positioned(
                            top: safeTop + 4,
                            left: 8,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(50),
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.black.withValues(alpha: 0.4)
                                        : Colors.white.withValues(alpha: 0.8),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: activeColor.withValues(alpha: 0.15),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    size: 16,
                                    color: AppColors.getTextPrimary(context),
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
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 8),
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
                  currency: _selectedCurrency,
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
                            Icon(Icons.linear_scale_rounded, size: 20, color: activeColor.withValues(alpha: 0.7)),
                            const SizedBox(width: 12),
                            Text(l10n.flexibleAmount, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.getTextPrimary(context))),
                          ],
                        ),
                        PrecisionToggle(
                          value: _isFlexibleAmount,
                          activeColor: activeColor,
                          activeIcon: Icons.pause_rounded,
                          inactiveIcon: Icons.stop_rounded,
                          scalingFactor: scalingFactor * 0.9,
                          onChanged: (val) {
                            HapticFeedback.mediumImpact();
                            setState(() {
                              _isFlexibleAmount = val;
                              if (!val) _amountFocusNode.requestFocus();
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
                  child: PrecisionCard(
                    scalingFactor: scalingFactor,
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        TransactionVaultSelector(
                          vaults: _vaults,
                          selectedVaultIds: _selectedVaultIds,
                          scalingFactor: scalingFactor,
                          onChanged: (ids) {
                            setState(() {
                              _selectedVaultIds = ids;
                              if (ids.isNotEmpty) {
                                final sv = _vaults.firstWhere((v) => v.id == ids.first);
                                if (sv.currency != 'AUTO') {
                                  _onCurrencyChanged(sv.currency);
                                }
                              }
                            });
                          },
                        ),
                        Divider(height: 1, thickness: 0.5, indent: 16, endIndent: 16, color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08)),
                        TransactionCurrencySelector(
                          selectedCurrency: _selectedCurrency,
                          scalingFactor: scalingFactor,
                          onChanged: _onCurrencyChanged,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.paddingMedium),
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
                            Icon(Icons.notes_rounded, size: 20, color: activeColor.withValues(alpha: 0.7)),
                            const SizedBox(width: 12),
                            Text(l10n.description.toUpperCase(), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.getTextPrimary(context).withValues(alpha: 0.8), letterSpacing: 0.5)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        PrecisionInput(controller: _noteController, hintText: 'İşleme dair not bırakın...', icon: Icons.edit_note_rounded),
                        const SizedBox(height: 12),
                        Divider(height: 24, thickness: 0.5, color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08)),
                        const SizedBox(height: 12),
                        TransactionPeriodSelector(
                          initialData: _periodData,
                          scalingFactor: scalingFactor,
                          onChanged: (data) {
                            HapticFeedback.mediumImpact();
                            setState(() => _periodData = data);
                          },
                        ),
                        
                        // --- BİLDİRİM AYARLARI ---
                        Divider(height: 24, thickness: 0.5, color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08)),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.notifications_active_rounded, size: 20, color: activeColor.withValues(alpha: 0.7)),
                                  const SizedBox(width: 12),
                                  Text('HATIRLATICI', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.getTextPrimary(context).withValues(alpha: 0.8), letterSpacing: 0.5)),
                                ],
                              ),
                              PrecisionToggle(
                                value: _isNotificationEnabled,
                                activeColor: activeColor,
                                activeIcon: Icons.notifications_active_rounded,
                                inactiveIcon: Icons.notifications_off_rounded,
                                scalingFactor: scalingFactor * 0.9,
                                onChanged: (val) async {
                                  if (val) {
                                    final granted = await NotificationService().requestPermissions();
                                    if (!granted && context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Bildirim izni verilmedi. Lütfen ayarlardan açın.'))
                                      );
                                      return;
                                    }
                                  }
                                  HapticFeedback.mediumImpact();
                                  setState(() => _isNotificationEnabled = val);
                                },
                              ),
                            ],
                          ),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOutQuart,
                            alignment: Alignment.topCenter,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 350),
                              transitionBuilder: (Widget child, Animation<double> animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0.05, 0),
                                      end: Offset.zero,
                                    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutQuart)),
                                    child: child,
                                  ),
                                );
                              },
                              child: _isNotificationEnabled 
                                ? Column(
                                    key: const ValueKey('reminder_enabled'),
                                    children: [
                                      Divider(height: 1, thickness: 0.5, color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08)),
                                      const SizedBox(height: 8),
                                      TransactionReminderDaysSelector(
                                        selectedDays: _notificationReminderDays,
                                        scalingFactor: scalingFactor,
                                        onChanged: (val) => setState(() => _notificationReminderDays = val),
                                      ),
                                      Divider(height: 1, thickness: 0.5, indent: 16, endIndent: 16, color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08)),
                                      TransactionReminderTimeSelector(
                                        selectedTime: _notificationTime,
                                        scalingFactor: scalingFactor,
                                        onChanged: (val) => setState(() => _notificationTime = val),
                                      ),
                                    ],
                                  )
                                : const SizedBox.shrink(key: ValueKey('reminder_disabled')),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                      child: Text(_errorMessage!, style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
                  child: PrecisionButton(
                    onTap: _saveTransaction,
                    label: l10n.save,
                    activeColor: activeColor,
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
