import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/database/database_service.dart';
import '../../../../core/database/models/vault.dart';
import '../../../../core/database/models/transaction_record.dart';
import '../../../../core/database/models/recurring_template.dart';
import '../../../../core/services/materialization_service.dart';
import '../../../../core/domain/recurrence_engine.dart';
import '../../../../core/providers/db_providers.dart';

import '../../../../shared/widgets/custom_card.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_icon_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/utils/string_utils.dart';
import '../../../../shared/widgets/custom_switch.dart';
import '../../../../shared/widgets/clickable_action.dart';
import '../../../../shared/widgets/custom_animated_icon.dart';
import '../vaults_providers.dart';

enum DetailSheetAction { edit, delete }

class DetailSheet extends ConsumerStatefulWidget {
  final TransactionUI transaction;
  final bool isTemplateMode;

  const DetailSheet({
    super.key,
    required this.transaction,
    this.isTemplateMode = false,
  });

  @override
  ConsumerState<DetailSheet> createState() => _PrecisionDetailSheetState();
}

class _PrecisionDetailSheetState extends ConsumerState<DetailSheet> {
  List<Vault> _allVaults = [];
  List<Vault> _attachedVaults = [];
  TransactionRecord? _fullRecord;
  RecurringTemplate? _template;
  RecurringTemplate? _activeTemplate;
  late bool _isNotificationEnabled;

  bool _isRecurring = false;
  int _passedOccurrences = 0;
  int? _totalLimit;
  int _remainingOccurrences = 0;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _isNotificationEnabled = false;
    _loadData();
  }

  Future<void> _loadData() async {
    final allVaults = await DatabaseService.getAllVaults();
    if (widget.transaction.dbId != null) {
      if (widget.isTemplateMode) {
        _template = await DatabaseService.getTemplate(widget.transaction.dbId!);
      } else {
        _fullRecord = await DatabaseService.getTransaction(widget.transaction.dbId!);
        if (_fullRecord == null) {
          _template = await DatabaseService.getTemplate(widget.transaction.dbId!);
        }
      }
    }
    final dbVaultId = _fullRecord?.vaultId ?? _template?.vaultId;
    final ids = dbVaultId != null 
        ? [dbVaultId] 
        : widget.transaction.groupIds.map((id) => int.tryParse(id.replaceFirst('v_', ''))).whereType<int>().toList();
    
    final template = _template ?? (_fullRecord?.templateId != null ? await DatabaseService.getTemplate(_fullRecord!.templateId!) : null);
    _activeTemplate = template;

    if (template != null) {
      _isRecurring = true;
      _isNotificationEnabled = template.isNotificationEnabled;
      final records = await DatabaseService.getRecordsForTemplate(template.id);
      _passedOccurrences = records.length;
      _totalLimit = template.totalInstallments;
      if (_totalLimit != null) {
        _remainingOccurrences = (_totalLimit! - _passedOccurrences).clamp(0, _totalLimit!);
        final dates = RecurrenceEngine.occurrenceDates(
          template.recurrenceRule,
          DateTime(DateTime.now().year + 50),
        );
        if (dates.isNotEmpty) {
          _endDate = dates.last;
        }
      } else {
        _endDate = null;
      }
    } else {
      _isRecurring = false;
      _passedOccurrences = 0;
      _totalLimit = null;
      _remainingOccurrences = 0;
      _endDate = null;
    }
    
    debugPrint('🔎 [DetailSheet] dbId: ${widget.transaction.dbId}');
    debugPrint('🔎 [DetailSheet] computed ids: $ids');
    
    if (mounted) {
      setState(() {
        _allVaults = allVaults;
        _attachedVaults = allVaults.where((v) => ids.contains(v.id)).toList();
      });
    }
  }

  Future<void> _toggleVault(Vault vault) async {
    if (widget.transaction.dbId == null) return;
    
    if (_fullRecord != null) {
      final record = await DatabaseService.getTransaction(widget.transaction.dbId!);
      if (record == null) return;

      // Zaten seçili olan kasaya tekrar tıklandıysa bir şey yapma (en az 1 kasa seçili kalmalı)
      if (record.vaultId == vault.id) {
        return;
      }

      record.vaultId = vault.id;
      record.updatedAt = DateTime.now();
      await DatabaseService.updateTransaction(record);
    } else if (_template != null) {
      final template = await DatabaseService.getTemplate(widget.transaction.dbId!);
      if (template == null) return;

      // Zaten seçili olan kasaya tekrar tıklandıysa bir şey yapma (en az 1 kasa seçili kalmalı)
      if (template.vaultId == vault.id) {
        return;
      }

      template.vaultId = vault.id;
      template.updatedAt = DateTime.now();
      await DatabaseService.updateTemplate(template);
      await MaterializationService.onTemplateChanged(template);
    }
    
    HapticFeedback.mediumImpact();
    await _loadData();
    ref.invalidate(transactionsStreamProvider);
    ref.invalidate(templatesStreamProvider);
  }

  Future<void> _toggleNotification(bool value) async {
    setState(() {
      _isNotificationEnabled = value;
    });

    final templateToUpdate = _activeTemplate ?? _template;
    if (templateToUpdate != null) {
      final template = await DatabaseService.getTemplate(templateToUpdate.id);
      if (template != null) {
        template.isNotificationEnabled = value;
        await DatabaseService.updateTemplate(template);
        HapticFeedback.mediumImpact();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tx = widget.transaction;
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;
    final sf = (screenHeight / 812.0).clamp(0.75, 1.0);

    final hasFlexibleAmount = tx.minAmount != null && tx.maxAmount != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. HEADER
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 1000),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.5 + (0.5 * value),
              child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
            );
          },
          child: Center(
            child: Container(
              width: 80 * sf, height: 80 * sf,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(24 * sf),
                border: Border.all(color: AppColors.getAccentDeep(context, tx.color).withValues(alpha: 0.3), width: 0.5),
              ),
              child: Icon(tx.icon, size: 36 * sf, color: AppColors.getAccentDeep(context, tx.color)),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // TUTAR (Dengeli ve Etiketli Layout)
        Center(
          child: tx.effectiveAmount == 0
            ? Column(
                children: [
                  Text(
                    l10n.amountNotEntered,
                    style: TextStyle(
                      fontSize: 24 * sf,
                      fontWeight: FontWeight.w900,
                      color: AppColors.getTextSecondary(context).withValues(alpha: isDark ? 0.4 : 0.8),
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    l10n.addAmountByEditing,
                    style: TextStyle(
                      fontSize: 12 * sf,
                      fontWeight: FontWeight.w600,
                      color: AppColors.getTextSecondary(context).withValues(alpha: isDark ? 0.3 : 0.7),
                    ),
                  ),
                ],
              )
            : hasFlexibleAmount
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildRangeValue(l10n.minimum, tx.minAmount!, tx.currency, sf, isDark),
                    Flexible(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16 * sf),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '${tx.currency ?? "₺"}${_formatFull(tx.effectiveAmount, context)}',
                            style: TextStyle(
                              fontSize: 40 * sf,
                              fontWeight: FontWeight.w900,
                              color: tx.isIncome ? AppColors.getIncome(context) : AppColors.getExpense(context),
                              letterSpacing: -1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    _buildRangeValue(l10n.maximum, tx.maxAmount!, tx.currency, sf, isDark),
                  ],
                )
              : FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${tx.currency ?? "₺"}${_formatFull(tx.effectiveAmount, context)}',
                    style: TextStyle(
                      fontSize: 40 * sf,
                      fontWeight: FontWeight.w900,
                      color: tx.isIncome ? AppColors.getIncome(context) : AppColors.getExpense(context),
                      letterSpacing: -2, height: 1,
                    ),
                  ),
                ),
        ),

        SizedBox(height: 16 * sf),

        // 2. BİLGİ KARTLARI
        CustomCard(
          scalingFactor: sf,
          padding: EdgeInsets.all(12 * sf),
          child: Column(
            children: [
              _buildInfoRow(
                context, 
                icon: Icons.calendar_today_rounded, 
                label: l10n.added, 
                value: _fullRecord != null 
                    ? DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(_fullRecord!.date) 
                    : (_template != null 
                        ? DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(_template!.startDate) 
                        : '-'), 
                color: Colors.blue
              ),
              Divider(height: 16 * sf, thickness: 0.5),
              _buildInfoRow(context, icon: Icons.replay_rounded, label: l10n.period, value: _getDetailedPeriodLabel(tx, l10n, context), color: Colors.purple),
              
              if (_isRecurring) ...[
                if (_endDate != null) ...[
                  Divider(height: 16 * sf, thickness: 0.5),
                  _buildInfoRow(
                    context, 
                    icon: Icons.event_available_rounded, 
                    label: l10n.endDate, 
                    value: DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(_endDate!), 
                    color: Colors.redAccent
                  ),
                ],
                Divider(height: 16 * sf, thickness: 0.5),
                _buildInfoRow(
                  context, 
                  icon: Icons.task_alt_rounded, 
                  label: l10n.occurred, 
                  value: l10n.times(_passedOccurrences), 
                  color: Colors.teal
                ),
                if (_totalLimit != null) ...[
                  Divider(height: 16 * sf, thickness: 0.5),
                  _buildInfoRow(
                    context, 
                    icon: Icons.hourglass_bottom_rounded, 
                    label: l10n.remainingCount, 
                    value: l10n.times(_remainingOccurrences), 
                    color: Colors.deepOrange
                  ),
                ],
              ],

              if (tx.note != null && tx.note!.isNotEmpty) ...[
                Divider(height: 16 * sf, thickness: 0.5),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.getAccentDeep(context, Colors.amber).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.notes_rounded, size: 16, color: AppColors.getAccentDeep(context, Colors.amber)),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          l10n.note,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.getTextSecondary(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark 
                            ? Colors.white.withValues(alpha: 0.05) 
                            : Colors.black.withValues(alpha: 0.02),
                        borderRadius: BorderRadius.circular(12 * sf),
                        border: Border.all(
                          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        tx.note!,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.getTextPrimary(context),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ]
            ],
          ),
        ),

        const SizedBox(height: 8),

        // 3. KASALAR
        if (_allVaults.isNotEmpty && !widget.isTemplateMode) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.vaults.toSafeUpperCase(context),
              style: TextStyle(
                fontSize: 9 * sf,
                fontWeight: FontWeight.w900,
                color: AppColors.getTextSecondary(context).withValues(alpha: isDark ? 0.6 : 0.85),
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              final double itemWidth = (constraints.maxWidth - 16) / 3;
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _allVaults.map((vault) {
                  final isAttached = _attachedVaults.any((v) => v.id == vault.id);
                  return SizedBox(
                    width: itemWidth,
                    height: 42 * sf,
                    child: ClickableAction(
                      onTap: () => _toggleVault(vault),
                      borderRadius: BorderRadius.circular(16 * sf),
                      child: CustomCard(
                        scalingFactor: sf,
                        padding: EdgeInsets.zero,
                        backgroundColor: isAttached 
                            ? AppColors.getPrimary(context).withValues(alpha: isDark ? 0.12 : 0.06)
                            : null,
                        borderColor: isAttached 
                            ? AppColors.getPrimary(context).withValues(alpha: 0.4)
                            : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06)),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16 * sf),
                          child: Stack(
                            children: [
                              // Arka Plan Filigran İkonu
                              Positioned(
                                right: -8 * sf,
                                bottom: -10 * sf,
                                child: Opacity(
                                  opacity: isAttached 
                                      ? (isDark ? 0.15 : 0.08) 
                                      : (isDark ? 0.12 : 0.06),
                                  child: Icon(
                                    Icons.account_balance_wallet_rounded,
                                    size: 54 * sf,
                                    color: isAttached ? AppColors.getPrimary(context) : AppColors.getTextSecondary(context),
                                  ),
                                ),
                              ),
                              // Ön Plan İçeriği
                              Positioned.fill(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10 * sf),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          vault.name,
                                          style: TextStyle(
                                            fontSize: 11 * sf,
                                            fontWeight: isAttached ? FontWeight.w800 : FontWeight.w600,
                                            color: isAttached 
                                                ? AppColors.getPrimary(context) 
                                                : AppColors.getTextPrimary(context).withValues(alpha: 0.85),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      CustomAnimatedIcon(
                                        activeIcon: Icons.add_circle_outline_rounded,
                                        inactiveIcon: Icons.remove_circle_outline_rounded,
                                        isActive: isAttached,
                                        size: 17 * sf,
                                        color: isAttached 
                                            ? AppColors.getPrimary(context) 
                                            : AppColors.getTextSecondary(context).withValues(alpha: 0.35),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],

        SizedBox(height: 12 * sf),

        // 3.5 BİLDİRİM TOGGLE
        if (_activeTemplate != null && _activeTemplate!.isNotificationEnabled) ...[
          CustomCard(
            scalingFactor: sf,
            padding: EdgeInsets.symmetric(horizontal: 16 * sf, vertical: 12 * sf),
            child: Row(
              children: [
                Container(
                  width: 38 * sf,
                  height: 38 * sf,
                  decoration: BoxDecoration(
                    color: tx.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12 * sf),
                  ),
                  child: CustomAnimatedIcon(
                    isActive: _isNotificationEnabled,
                    activeIcon: Icons.notifications_active_rounded,
                    inactiveIcon: Icons.notifications_off_rounded,
                    color: tx.color,
                    size: 18 * sf,
                  ),
                ),
                SizedBox(width: 12 * sf),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.notifications,
                        style: TextStyle(
                          fontSize: 14 * sf,
                          fontWeight: FontWeight.w700,
                          color: AppColors.getTextPrimary(context),
                        ),
                      ),
                      Text(
                        _isNotificationEnabled ? l10n.active : l10n.disabled,
                        style: TextStyle(
                          fontSize: 11 * sf,
                          fontWeight: FontWeight.w600,
                          color: AppColors.getTextSecondary(context).withValues(alpha: isDark ? 0.5 : 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                CustomSwitch(
                  value: _isNotificationEnabled,
                  onChanged: _toggleNotification,
                  activeColor: tx.color,
                  scalingFactor: sf * 0.85,
                  activeIcon: Icons.notifications_active_rounded,
                  inactiveIcon: Icons.notifications_off_rounded,
                ),
              ],
            ),
          ),
          SizedBox(height: 16 * sf),
        ],

        // 4. AKSİYONLAR
        Row(
          children: [
            Expanded(
              child: CustomButton(
                label: l10n.edit,
                onTap: () {
                  Navigator.pop(context, DetailSheetAction.edit);
                },
                height: 52 * sf,
                fontSize: 13,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(width: 12),
            CustomIconButton(
              onTap: () => Navigator.pop(context, DetailSheetAction.delete),
              icon: Icons.delete_sweep_rounded,
              color: AppColors.error,
              backgroundColor: AppColors.error.withValues(alpha: 0.1),
              borderRadius: 18 * sf,
              size: 22,
              padding: 14,
            ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  String _formatFull(double val, BuildContext context) {
    // Kısaltma yapmadan binlik ayırıcı ile göster
    final locale = Localizations.localeOf(context).toString();
    final format = NumberFormat.decimalPattern(locale);
    return format.format(val.toInt());
  }

  Widget _buildRangeValue(String label, double value, String? currency, double sf, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toSafeUpperCase(context),
          style: TextStyle(
            fontSize: 9 * sf,
            fontWeight: FontWeight.w900,
            color: AppColors.getTextSecondary(context),
            letterSpacing: 1,
          ),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '${currency ?? "₺"}${_formatFull(value, context)}',
            style: TextStyle(
              fontSize: 14 * sf,
              fontWeight: FontWeight.w700,
              color: AppColors.getTextPrimary(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, {required IconData icon, required String label, required String value, required Color color}) {
    final Color effectiveColor = AppColors.getAccentDeep(context, color);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: effectiveColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 16, color: effectiveColor),
        ),
        const SizedBox(width: 12),
        Text(
          label, 
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.getTextSecondary(context)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value, 
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }


  String _getDetailedPeriodLabel(TransactionUI tx, AppLocalizations l10n, BuildContext context) {
    final t = _activeTemplate;
    if (t == null) {
      return l10n.oneTime;
    }
    
    String base = '';
    final int pType = t.periodType;
    
    if (pType == 0) {
      base = l10n.oneTime;
    } else if (pType == 250) {
      base = l10n.weekdays;
    } else if (pType == 251) {
      base = l10n.weekends;
    } else {
      final unit = pType ~/ 100;
      final interval = pType % 100;
      
      switch (unit) {
        case 1:
          base = interval == 1 ? l10n.everyDayDetailed : l10n.everyXDays(interval);
          break;
        case 2:
          base = interval == 1 ? l10n.everyWeekDetailed : l10n.everyXWeeks(interval);
          break;
        case 3:
          base = interval == 1 ? l10n.everyMonthDetailed : l10n.everyXMonths(interval);
          break;
        case 4:
          base = interval == 1 ? l10n.everyYearDetailed : l10n.everyXYears(interval);
          break;
        default:
          base = l10n.oneTime;
      }
    }
    
    if (pType != 0) {
      List<String> details = [base];
      final unit = pType ~/ 100;
      
      if (t.recurrenceDay != null && (unit == 2 || pType == 250 || pType == 251)) {
        final List<String> weekDays = [l10n.monday, l10n.tuesday, l10n.wednesday, l10n.thursday, l10n.friday, l10n.saturday, l10n.sunday];
        if (t.recurrenceDay! > 0 && t.recurrenceDay! <= 7) {
          details.add(weekDays[t.recurrenceDay! - 1]);
        }
      } else if (t.recurrenceDate != null && (unit == 3 || unit == 4)) {
        if (unit == 4) {
          details.add(DateFormat.MMMMd(Localizations.localeOf(context).toString()).format(t.recurrenceDate!));
        } else {
          details.add(l10n.dayOfMonthOrdinal(t.recurrenceDate!.day));
        }
      }
      
      if (t.totalInstallments != null) {
        final langCode = Localizations.localeOf(context).languageCode;
        details.add(_getInstallmentsLabel(langCode, t.totalInstallments!));
      } else {
        details.add(l10n.indefinitely);
      }
      
      return details.join(' • ');
    }
    
    return base;
  }

  String _getInstallmentsLabel(String langCode, int count) {
    if (langCode == 'tr') return '$count Taksit';
    if (langCode == 'de') return '$count Raten';
    if (langCode == 'fr') return '$count mensualités';
    if (langCode == 'es') return '$count cuotas';
    return '$count installments';
  }
}
