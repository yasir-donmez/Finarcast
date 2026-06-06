
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../core/theme/app_constants.dart';
import '../../core/utils/string_utils.dart';
import '../../core/database/database_service.dart';
import '../../core/database/models/transaction_record.dart';
import '../../core/database/models/vault.dart';
import '../../core/services/custom_category_service.dart';
import '../../core/providers/settings_provider.dart';
import '../home/home_providers.dart';
import '../../core/services/notification_service.dart';
import '../../core/utils/currency_utils.dart';
import '../../core/services/currency_service.dart';
import '../auth/widgets/auth_background.dart';
import '../../core/services/subscription_service.dart';
import '../subscription/widgets/pro_upgrade_sheet.dart';

import 'widgets/transaction_vault_selector.dart';
import 'widgets/transaction_currency_selector.dart';
import 'widgets/transaction_type_toggle.dart';
import 'widgets/transaction_amount_input.dart';
import 'widgets/transaction_category_data.dart';
import 'widgets/transaction_category_selector.dart';
import 'widgets/transaction_period_selector.dart';
import 'widgets/transaction_reminder_days_selector.dart';
import 'widgets/transaction_reminder_time_selector.dart';
import '../../shared/widgets/custom_switch.dart';
import '../../shared/widgets/custom_card.dart';
import '../../shared/widgets/custom_text_field.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_bottom_sheet.dart';
import '../../shared/widgets/glass_surface.dart';
import '../../shared/widgets/custom_notification.dart';
import '../../shared/widgets/custom_dialog.dart';

class TransactionBuilderScreen extends ConsumerStatefulWidget {
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

  const TransactionBuilderScreen({
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
  ConsumerState<TransactionBuilderScreen> createState() =>
      _TransactionBuilderScreenState();
}

class _TransactionBuilderScreenState extends ConsumerState<TransactionBuilderScreen> {
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
      selectedDateForRecurrence: widget.initialRecurrenceDate ?? DateTime.now(),
      duration: 0,
    );
    _loadVaults();
    _loadCustomCategories();
    _selectedCurrency = ref.read(settingsProvider).currencySymbol;
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

  String _formatAmount(double val, String currencySymbol) {
    final locale = Localizations.localeOf(context).toString();
    final code = AppCurrency.getCode(currencySymbol);
    final bool isZeroDecimal = (code == 'JPY' || code == 'KRW');

    int decimals = isZeroDecimal ? 0 : 2;
    if (val == val.toInt()) decimals = 0;

    final format = NumberFormat.decimalPattern(locale);
    final decimalSep = format.symbols.DECIMAL_SEP;

    // Convert raw double to a simple localized string (e.g. 213412.5 -> "213412,5")
    String rawText = val.toStringAsFixed(decimals).replaceAll('.', decimalSep);

    // Trigger the input formatter programmatically
    final formatter = LocaleCurrencyFormatter(locale);
    return formatter.formatEditUpdate(
      TextEditingValue.empty,
      TextEditingValue(text: rawText),
    ).text;
  }

  void _prefillIfEditing() {
    // 1. DÜZENLEME MODU (Mevcut İşlem)
    if (widget.initialId != null) {
      _tabIndex = widget.initialIsIncome == true ? 1 : 0;
      if (widget.initialCurrency != null) {
        _selectedCurrency = widget.initialCurrency!;
      }
      if (widget.initialAmount != null) {
        _amountController.text = _formatAmount(widget.initialAmount!, _selectedCurrency);
      }
      if (widget.initialMinAmount != null) {
        _minController.text = _formatAmount(widget.initialMinAmount!, _selectedCurrency);
        _isFlexibleAmount = true;
      }
      if (widget.initialMaxAmount != null) {
        _maxController.text = _formatAmount(widget.initialMaxAmount!, _selectedCurrency);
        _isFlexibleAmount = true;
      }
      if (widget.initialNote != null) {
        _noteController.text = widget.initialNote!;
      }
      if (widget.initialVaultIds != null) {
        _selectedVaultIds = List<int>.from(widget.initialVaultIds!);
      }
      if (widget.initialPeriodType != null && widget.initialPeriodType != 0) {
        _periodData = TransactionPeriodData(
          periodType: widget.initialPeriodType!,
          selectedDay: widget.initialRecurrenceDay ?? 1,
          selectedDateForRecurrence:
              widget.initialRecurrenceDate ?? DateTime.now(),
          duration: widget.initialRecurrenceDuration ?? 0,
        );
      }

      _isNotificationEnabled = widget.initialIsNotificationEnabled ?? false;
      _notificationReminderDays = widget.initialNotificationReminderDays ?? 0;
      if (widget.initialNotificationHour != null &&
          widget.initialNotificationMinute != null) {
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
                _expandedCategoryIndex = i;
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
      if (widget.initialCurrency != null) {
        _selectedCurrency = widget.initialCurrency!;
      }
      if (widget.initialAmount != null && widget.initialAmount! > 0) {
        _amountController.text = _formatAmount(widget.initialAmount!, _selectedCurrency);
      }
      if (widget.initialMinAmount != null && widget.initialMinAmount! > 0) {
        _minController.text = _formatAmount(widget.initialMinAmount!, _selectedCurrency);
        _isFlexibleAmount = true;
      }
      if (widget.initialMaxAmount != null && widget.initialMaxAmount! > 0) {
        _maxController.text = _formatAmount(widget.initialMaxAmount!, _selectedCurrency);
        _isFlexibleAmount = true;
      }
      if (widget.initialNote != null) {
        _noteController.text = widget.initialNote!;
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
      if (widget.initialNotificationReminderDays != null) {
        _notificationReminderDays = widget.initialNotificationReminderDays!;
      }
      if (widget.initialNotificationHour != null &&
          widget.initialNotificationMinute != null) {
        _notificationTime = TimeOfDay(
          hour: widget.initialNotificationHour!,
          minute: widget.initialNotificationMinute!,
        );
      }
      if (widget.initialPeriodType != null && widget.initialPeriodType != 0) {
        _periodData = TransactionPeriodData(
          periodType: widget.initialPeriodType!,
          selectedDay: widget.initialRecurrenceDay ?? 1,
          selectedDateForRecurrence:
              widget.initialRecurrenceDate ?? DateTime.now(),
          duration: widget.initialRecurrenceDuration ?? 0,
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
                _expandedCategoryIndex = i;
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
        if (_selectedVaultIds.isEmpty && v.isNotEmpty) {
          _selectedVaultIds = [v.first.id];
        }
      });
    }
  }

  Future<void> _loadCustomCategories() async {
    final customs = await CustomCategoryService.getAllCustomSubcategories();
    if (mounted) setState(() => _customSubs = customs);
  }

  List<Map<String, dynamic>> _getMergedCategories() {
    final base = _tabIndex == 0
        ? TransactionCategoryData.getExpenseCategories(context, l10n)
        : TransactionCategoryData.getIncomeCategories(context, l10n);
    final isPro = ref.watch(subscriptionServiceProvider).isPro;
    if (!isPro) return base;
    return TransactionCategoryData.mergeCustomSubcategories(base, _customSubs);
  }

  Future<void> _showAddCustomCategoryDialog(String parentCategoryId) async {
    final isPro = ref.read(subscriptionServiceProvider).isPro;
    if (!isPro) {
      ProUpgradeSheet.show(context);
      return;
    }

    final controller = TextEditingController();
    final parentCat = _getMergedCategories().firstWhere(
      (c) => c['id'] == parentCategoryId,
      orElse: () => <String, dynamic>{},
    );
    if (parentCat.isEmpty) return;

    final parentColor = parentCat['color'] as Color;
    final parentIcon = parentCat['icon'] as IconData;
    final parentName = parentCat['name'] as String;
    final bool showIconPicker =
        parentCategoryId == 'exp_other' || parentCategoryId == 'inc_other';

    IconData selectedIcon = parentIcon;

    final result = await CustomBottomSheet.show<Map<String, dynamic>>(
      context: context,
      title: l10n.addCustomCategory,
      child: StatefulBuilder(
        builder: (context, setDialogState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
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
            Icons.savings_rounded,
            Icons.receipt_long_rounded,
            Icons.card_giftcard_rounded,
            Icons.build_rounded,
            Icons.memory_rounded,
            Icons.landscape_rounded,
          ];

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Üst Bilgi (Kategori İsmi)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: parentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(selectedIcon, color: parentColor, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      parentName.toSafeUpperCase(context),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: parentColor,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Giriş Alanı
              TextField(
                controller: controller,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                maxLength: 30,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  hintText: l10n.customCategoryHint,
                  hintStyle: TextStyle(
                    color: AppColors.getTextFaint(context),
                    fontWeight: FontWeight.w600,
                  ),
                  counterText: '',
                  filled: true,
                  fillColor: (isDark ? Colors.white : Colors.black).withValues(
                    alpha: 0.03,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: parentColor.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                ),
              ),

              if (showIconPicker) ...[
                const SizedBox(height: 32),
                Row(
                  children: [
                    Text(
                      l10n.selectIcon,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: AppColors.getTextFaint(context),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      l10n.optionsCount(iconOptions.length),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: parentColor.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 160,
                  child: GridView.builder(
                    padding: EdgeInsets.zero,
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                    ),
                    itemCount: iconOptions.length,
                    itemBuilder: (context, index) {
                      final icon = iconOptions[index];
                      final isSelected = selectedIcon == icon;
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setDialogState(() => selectedIcon = icon);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? parentColor.withValues(alpha: 0.2)
                                : (isDark ? Colors.white : Colors.black)
                                    .withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? parentColor
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            icon,
                            color: isSelected
                                ? parentColor
                                : parentColor.withValues(alpha: 0.25),
                            size: 22,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Onay Butonu
              CustomButton(
                label: l10n.ok,
                onTap: () {
                  if (controller.text.trim().isNotEmpty) {
                    Navigator.pop(context, {
                      'name': controller.text.trim(),
                      'iconCode': selectedIcon.codePoint.toString(),
                    });
                  }
                },
                isPrimary: true,
                activeColor: parentColor,
                height: 56,
              ),
              const SizedBox(height: 12),
            ],
          );
        },
      ),
    );

    if (result != null && result['name'] != null) {
      final int? code = int.tryParse(result['iconCode'] as String);
      if (code != null) {
        await CustomCategoryService.addCustomSubcategory(
          parentCategoryId,
          result['name'] as String,
          code,
        );
        await _loadCustomCategories();
      }
    }
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

  Future<void> _handleRemoveCustomCategory(String subcategoryId) async {
    final confirmed = await showCustomDialog<bool>(
      context: context,
      accentColor: AppColors.getExpense(context),
      title: l10n.deleteCustomCategory,
      content: l10n.deleteCustomCategoryConfirm,
      actions: [
        PrecisionDialogAction(
          label: l10n.cancel,
          onTap: () => Navigator.pop(context, false),
          isPrimary: false,
        ),
        PrecisionDialogAction(
          label: l10n.yes,
          onTap: () => Navigator.pop(context, true),
          isPrimary: true,
        ),
      ],
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

      double parseLocaleDouble(String input) {
        if (input.isEmpty) return 0.0;
        final locale = Localizations.localeOf(context).toString();
        final format = NumberFormat.decimalPattern(locale);
        final decimalSep = format.symbols.DECIMAL_SEP;
        final groupSep = format.symbols.GROUP_SEP;

        // Remove all grouping separators
        String clean = input.replaceAll(groupSep, '');
        // Replace decimal separator with standard '.' if it is not '.'
        if (decimalSep != '.') {
          clean = clean.replaceAll(decimalSep, '.');
        }

        return double.tryParse(clean) ?? 0.0;
      }

      final amount = parseLocaleDouble(amountStr);
      final minAmount = parseLocaleDouble(minStr);
      final maxAmount = parseLocaleDouble(maxStr);

      if (!_isFlexibleAmount && amount <= 0) {
        _showValidationError(l10n.invalidAmountError);
        return;
      }

      if (_isFlexibleAmount) {
        if (maxAmount <= 0) {
          _showValidationError(l10n.maxAmountMustBePositive);
          return;
        }
        if (minAmount >= maxAmount) {
          _showValidationError(l10n.minMustBeLessThanMax);
          return;
        }
      }

      if (_selectedVaultIds.isEmpty) {
        final vaults = await DatabaseService.getAllVaults();
        if (vaults.isNotEmpty) {
          setState(() {
            _selectedVaultIds = [vaults.first.id];
          });
        } else {
          _showValidationError(l10n.selectAtLeastOneVault);
          return;
        }
      }

      // Doviz kuru kontrolü
      final baseCurrency = ref.read(settingsProvider).currencySymbol;

      // Yardımcı: Kur var mı kontrol et, yoksa otomatik çekmeyi dene
      Future<bool> ensureRate(String currencySymbol) async {
        final code = CurrencyUtils.symbolToCode(currencySymbol);
        var rates = await DatabaseService.getAllExchangeRates();
        var hasRate = rates.any((r) => r.currencyCode == code && r.rate > 0);
        if (!hasRate) {
          // Kurlar yok, otomatik çekmeyi dene
          final success = await CurrencyService.updateRates();
          if (success) {
            rates = await DatabaseService.getAllExchangeRates();
            hasRate = rates.any((r) => r.currencyCode == code && r.rate > 0);
          }
        }
        return hasRate;
      }

      // 1. İşlemin kendi para birimi için kontrol
      if (_selectedCurrency != baseCurrency) {
        final hasRate = await ensureRate(_selectedCurrency);
        if (!hasRate) {
          _showValidationError(l10n.exchangeRatesNotLoaded);
          return;
        }
      }

      // 2. İşlemin eklendiği kasaların para birimi için kontrol
      for (final vaultId in _selectedVaultIds) {
        final vault = _vaults.where((v) => v.id == vaultId).firstOrNull;
        if (vault != null) {
          final vaultCurrency = vault.currency == 'AUTO' ? baseCurrency : vault.currency;
          if (vaultCurrency != baseCurrency) {
            final hasRate = await ensureRate(vaultCurrency);
            if (!hasRate) {
              _showValidationError(l10n.vaultCurrencyRateNotLoaded(vault.currency));
              return;
            }
          }
        }
      }

      final finalAmount = _isFlexibleAmount ? 0.0 : amount;
      final finalMin = _isFlexibleAmount ? minAmount : null;
      final finalMax = _isFlexibleAmount ? maxAmount : null;

      final categories = _getMergedCategories();
      final cat = categories[_selectedCategoryIndex];
      final subModel = _selectedSubModelIndex != -1
          ? (cat['subModels'] as List)[_selectedSubModelIndex]
          : null;
      final String categoryId = subModel != null
          ? subModel['id'] as String
          : cat['id'] as String;

      final isCustom = subModel != null && subModel['isCustom'] == true;
      final String? iconCodeStr = isCustom && subModel['icon'] is IconData
          ? (subModel['icon'] as IconData).codePoint.toString()
          : null;

      if (widget.initialId != null) {
        final old = await DatabaseService.getTransaction(widget.initialId!);
        if (old != null) {
          final catName = subModel != null
              ? subModel['name'] as String
              : cat['name'] as String;

          old.title = catName;
          old.amount = finalAmount;
          old.minAmount = finalMin;
          old.maxAmount = finalMax;
          old.isIncome = _tabIndex == 1;
          old.vaultIds = _selectedVaultIds;
          old.categoryId = categoryId;
          old.iconCode = iconCodeStr;
          old.periodType = _periodData.periodType;
          old.recurrenceDay = _periodData.selectedDay;
          old.recurrenceDate = _periodData.selectedDateForRecurrence;
          old.recurrenceDuration = _periodData.duration;
          old.note = _noteController.text.isNotEmpty
              ? _noteController.text
              : null;
          old.currency = _selectedCurrency;
          old.date = _periodData.selectedDateForRecurrence;

          old.isNotificationEnabled = _isNotificationEnabled;
          if (_isNotificationEnabled) {
            old.hasNotification = true;
          } else {
            if (!old.hasNotification) {
              old.hasNotification = false;
            }
          }
          old.notificationReminderDays = _notificationReminderDays;
          old.notificationHour = _notificationTime.hour;
          old.notificationMinute = _notificationTime.minute;

          await DatabaseService.updateTransaction(old);
        }
      } else {
        final catName = subModel != null
            ? subModel['name'] as String
            : cat['name'] as String;

        DateTime initialDate = _periodData.selectedDateForRecurrence;

        final tx = TransactionRecord()
          ..title = catName
          ..amount = finalAmount
          ..minAmount = finalMin
          ..maxAmount = finalMax
          ..isIncome = _tabIndex == 1
          ..date = initialDate
          ..vaultIds = _selectedVaultIds
          ..categoryId = categoryId
          ..iconCode = iconCodeStr
          ..periodType = _periodData.periodType
          ..recurrenceDay = _periodData.selectedDay
          ..recurrenceDate = _periodData.selectedDateForRecurrence
          ..recurrenceDuration = _periodData.duration
          ..note = _noteController.text.isNotEmpty ? _noteController.text : null
          ..currency = _selectedCurrency
          ..isNotificationEnabled = _isNotificationEnabled
          ..hasNotification = _isNotificationEnabled
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
      _showValidationError(l10n.transactionSaveError(e.toString()));
    }
  }

  void _onCurrencyChanged(String newCurrency) {
    if (newCurrency == _selectedCurrency) return;
    FocusManager.instance.primaryFocus?.unfocus();

    double? parseLocaleDouble(String input) {
      if (input.isEmpty) return null;
      final locale = Localizations.localeOf(context).toString();
      final format = NumberFormat.decimalPattern(locale);
      final decimalSep = format.symbols.DECIMAL_SEP;
      final groupSep = format.symbols.GROUP_SEP;

      String clean = input.replaceAll(groupSep, '');
      if (decimalSep != '.') {
        clean = clean.replaceAll(decimalSep, '.');
      }

      return double.tryParse(clean);
    }

    void formatFieldForNewCurrency(TextEditingController controller) {
      final text = controller.text.trim();
      if (text.isEmpty) return;

      final val = parseLocaleDouble(text);
      if (val != null) {
        controller.text = _formatAmount(val, newCurrency);
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
    final double safeTop = MediaQuery.of(context).viewPadding.top;

    return Stack(
      children: [
        const Positioned.fill(
          child: AuthBackground(useSystemBackground: false),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
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
                double t = totalRange > 0
                    ? ((currentH - minH) / totalRange).clamp(0.0, 1.0)
                    : 0.0;

                // NaN kontrolü
                if (t.isNaN) t = 0.0;

                final double revT = 1.0 - t;
                final double buttonAnim = t;

                return Stack(
                  fit: StackFit.expand,
                  clipBehavior: Clip.none,
                  children: [
                    // Solid Background Layer: Glass surface with dynamic opacity
                    Positioned.fill(
                      child: GlassSurface(
                        borderRadius: 0,
                        showShadow: false,
                        opacityMultiplier: revT,
                        borderColor: (isDark ? Colors.white : Colors.black).withValues(
                          alpha: revT > 0.95 ? (revT - 0.95) * 2 : 0.0,
                        ),
                        showTopBorder: false,
                        showLeftBorder: false,
                        showRightBorder: false,
                        child: const SizedBox.expand(),
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
                                (widget.initialId != null
                                        ? l10n.edit
                                        : l10n.addTransaction)
                                    .toSafeUpperCase(context),
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
                          if (buttonAnim > 0.01)
                            Positioned(
                              top: safeTop + 10,
                              left: 20 - ((1.0 - t) * 80),
                              child: Opacity(
                                opacity: buttonAnim,
                                child: Transform.scale(
                                  scale: buttonAnim,
                                  alignment: Alignment.centerLeft,
                                  child: _HeaderBackButton(activeColor: activeColor),
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
                    FocusManager.instance.primaryFocus?.unfocus();
                    setState(() {
                      _tabIndex = index;
                      _selectedCategoryIndex = 0;
                      _expandedCategoryIndex = -1;
                      _selectedSubModelIndex = -1;
                    });
                  },
                ),
                const SizedBox(height: 12),
                TransactionAmountInput(
                  isFlexibleAmount: _isFlexibleAmount,
                  currency: _selectedCurrency,
                  amountController: _amountController,
                  minController: _minController,
                  maxController: _maxController,
                  amountFocusNode: _amountFocusNode,
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingMedium,
                  ),
                  child: CustomCard(
                    scalingFactor: scalingFactor,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.linear_scale_rounded,
                              size: 20,
                              color: AppColors.getAccentDeep(context, activeColor).withValues(alpha: 0.7),
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
                        CustomSwitch(
                          value: _isFlexibleAmount,
                          activeColor: AppColors.getAccentDeep(context, activeColor),
                          activeIcon: Icons.pause_rounded,
                          inactiveIcon: Icons.stop_rounded,
                          scalingFactor: scalingFactor * 0.9,
                          onChanged: (val) {
                            HapticFeedback.mediumImpact();
                            FocusManager.instance.primaryFocus?.unfocus();
                            setState(() {
                              _isFlexibleAmount = val;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TransactionCategorySelector(
                  categories: activeCategories,
                  selectedCategoryIndex: _selectedCategoryIndex,
                  selectedSubModelIndex: _selectedSubModelIndex,
                  expandedCategoryIndex: _expandedCategoryIndex,
                  isPro: ref.watch(subscriptionServiceProvider).isPro,
                  onChanged: (catIndex, subIndex, expIndex) {
                    HapticFeedback.lightImpact();
                    FocusManager.instance.primaryFocus?.unfocus();
                    setState(() {
                      _selectedCategoryIndex = catIndex;
                      _selectedSubModelIndex = subIndex;
                      _expandedCategoryIndex = expIndex;
                    });
                  },
                  onAddCustomSubcategory: _showAddCustomCategoryDialog,
                  onRemoveCustomSubcategory: _handleRemoveCustomCategory,
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingMedium,
                  ),
                  child: CustomCard(
                    scalingFactor: scalingFactor,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TransactionVaultSelector(
                          vaults: _vaults,
                          selectedVaultIds: _selectedVaultIds,
                          scalingFactor: scalingFactor,
                          onChanged: (ids) {
                            FocusManager.instance.primaryFocus?.unfocus();
                            setState(() {
                              _selectedVaultIds = ids;
                              if (ids.isNotEmpty) {
                                final sv = _vaults.firstWhere(
                                  (v) => v.id == ids.first,
                                );
                                if (sv.currency != 'AUTO') {
                                  _onCurrencyChanged(sv.currency);
                                }
                              }
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        TransactionCurrencySelector(
                          selectedCurrency: _selectedCurrency,
                          scalingFactor: scalingFactor,
                          onChanged: _onCurrencyChanged,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingMedium,
                  ),
                  child: CustomCard(
                    scalingFactor: scalingFactor,
                    padding: const EdgeInsets.all(16),
                    child: TransactionPeriodSelector(
                      initialData: _periodData,
                      scalingFactor: scalingFactor,
                      onChanged: (data) {
                        HapticFeedback.mediumImpact();
                        FocusManager.instance.primaryFocus?.unfocus();
                        setState(() => _periodData = data);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingMedium,
                  ),
                  child: CustomCard(
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
                              color: AppColors.getAccentDeep(context, activeColor).withValues(alpha: 0.7),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              l10n.description.toSafeUpperCase(context),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: AppColors.getTextPrimary(
                                  context,
                                ).withValues(alpha: 0.8),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          controller: _noteController,
                          hintText: l10n.transactionNoteHint,
                          icon: Icons.edit_note_rounded,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingMedium,
                  ),
                  child: CustomCard(
                    scalingFactor: scalingFactor,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.notifications_active_rounded,
                                  size: 20,
                                  color: AppColors.getAccentDeep(context, activeColor).withValues(alpha: 0.7),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  l10n.reminder.toSafeUpperCase(context),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.getTextPrimary(
                                      context,
                                    ).withValues(alpha: 0.8),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            CustomSwitch(
                              value: _isNotificationEnabled,
                              activeColor: AppColors.getAccentDeep(context, activeColor),
                              activeIcon: Icons.notifications_active_rounded,
                              inactiveIcon: Icons.notifications_off_rounded,
                              scalingFactor: scalingFactor * 0.9,
                              onChanged: (val) async {
                                if (val) {
                                  final granted = await NotificationService()
                                      .requestPermissions();
                                  if (!granted && context.mounted) {
                                    CustomNotification.warning(
                                      context,
                                      l10n.notificationPermissionDenied,
                                    );
                                    return;
                                  }
                                }
                                HapticFeedback.mediumImpact();
                                FocusManager.instance.primaryFocus?.unfocus();
                                setState(() {
                                  _isNotificationEnabled = val;
                                });
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
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: SlideTransition(
                                      position:
                                          Tween<Offset>(
                                            begin: const Offset(0, 0.05),
                                            end: Offset.zero,
                                          ).animate(
                                            CurvedAnimation(
                                              parent: animation,
                                              curve: Curves.easeOutQuart,
                                            ),
                                          ),
                                      child: child,
                                    ),
                                  );
                                },
                            child: _isNotificationEnabled
                                ? Column(
                                    key: const ValueKey('reminder_enabled'),
                                    children: [
                                      const SizedBox(height: 16),
                                      Divider(
                                        height: 1,
                                        thickness: 0.5,
                                        color:
                                            (isDark
                                                    ? Colors.white
                                                    : Colors.black)
                                                .withValues(alpha: 0.08),
                                      ),
                                      const SizedBox(height: 16),
                                      TransactionReminderDaysSelector(
                                        selectedDays: _notificationReminderDays,
                                        scalingFactor: scalingFactor,
                                        onChanged: (days) => setState(
                                          () =>
                                              _notificationReminderDays = days,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      TransactionReminderTimeSelector(
                                        selectedTime: _notificationTime,
                                        scalingFactor: scalingFactor,
                                        onChanged: (time) => setState(
                                          () => _notificationTime = time,
                                        ),
                                      ),
                                    ],
                                  )
                                : const SizedBox.shrink(
                                    key: ValueKey('reminder_disabled'),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingMedium,
                  ),
                  child: CustomButton(
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
    ),
      ],
    );
  }
}

class _HeaderBackButton extends StatelessWidget {
  final Color activeColor;

  const _HeaderBackButton({required this.activeColor});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    bool isPressed = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return GestureDetector(
          onTapDown: (_) => setState(() => isPressed = true),
          onTapUp: (_) => setState(() => isPressed = false),
          onTapCancel: () => setState(() => isPressed = false),
          onTap: () => Navigator.pop(context),
          child: AnimatedScale(
            scale: isPressed ? 0.95 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: GlassSurface(
              borderRadius: 999, // Tam dairesel geri butonu
              padding: const EdgeInsets.all(13),
              showShadow: true,
              backgroundColor: isPressed
                  ? (isDark
                      ? AppColors.getThemeSurface(context, 2).withValues(alpha: 0.75)
                      : Colors.grey[200]!.withValues(alpha: 0.85))
                  : (isDark
                      ? Colors.black.withValues(alpha: 0.35)
                      : Colors.white.withValues(alpha: 0.65)),
              borderColor: isPressed
                  ? activeColor.withValues(alpha: 0.3)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isPressed ? 0.03 : 0.08),
                  blurRadius: isPressed ? 4 : 8,
                  offset: Offset(0, isPressed ? 1 : 2),
                ),
              ],
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 24,
                color: isPressed
                    ? activeColor
                    : AppColors.getTextPrimary(context).withValues(alpha: 0.8),
              ),
            ),
          ),
        );
      },
    );
  }
}
