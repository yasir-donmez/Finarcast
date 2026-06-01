import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/database/database_service.dart';
import '../../../../core/database/models/vault.dart';
import '../../../../core/database/models/transaction_record.dart';
import '../../../../core/providers/db_providers.dart';

import '../../../../shared/widgets/custom_card.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_icon_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/custom_switch.dart';
import '../../../../shared/widgets/clickable_action.dart';
import '../../../../shared/widgets/custom_animated_icon.dart';
import '../vaults_providers.dart';

class DetailSheet extends ConsumerStatefulWidget {
  final TransactionUI transaction;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const DetailSheet({
    super.key,
    required this.transaction,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  ConsumerState<DetailSheet> createState() => _PrecisionDetailSheetState();
}

class _PrecisionDetailSheetState extends ConsumerState<DetailSheet> {
  List<Vault> _allVaults = [];
  List<Vault> _attachedVaults = [];
  TransactionRecord? _fullRecord;
  late bool _isNotificationEnabled;

  @override
  void initState() {
    super.initState();
    _isNotificationEnabled = widget.transaction.isNotificationEnabled;
    _loadData();
  }

  @override
  void didUpdateWidget(covariant DetailSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.transaction.isNotificationEnabled != widget.transaction.isNotificationEnabled) {
      _isNotificationEnabled = widget.transaction.isNotificationEnabled;
    }
  }

  Future<void> _loadData() async {
    final allVaults = await DatabaseService.getAllVaults();
    if (widget.transaction.dbId != null) {
      _fullRecord = await DatabaseService.getTransaction(widget.transaction.dbId!);
    }
    final dbVaultIds = _fullRecord?.vaultIds;
    final ids = (dbVaultIds != null && dbVaultIds.isNotEmpty)
        ? dbVaultIds
        : widget.transaction.groupIds.map((id) => int.tryParse(id.replaceFirst('v_', ''))).whereType<int>().toList();
    
    debugPrint('🔎 [DetailSheet] dbId: ${widget.transaction.dbId}');
    debugPrint('🔎 [DetailSheet] widget groupIds: ${widget.transaction.groupIds}');
    debugPrint('🔎 [DetailSheet] db record vaultIds: ${_fullRecord?.vaultIds}');
    debugPrint('🔎 [DetailSheet] computed ids: $ids');
    debugPrint('🔎 [DetailSheet] allVaults IDs: ${allVaults.map((v) => v.id).toList()}');
    
    if (mounted) {
      setState(() {
        _allVaults = allVaults;
        _attachedVaults = allVaults.where((v) => ids.contains(v.id)).toList();
        debugPrint('🔎 [DetailSheet] attachedVaults IDs: ${_attachedVaults.map((v) => v.id).toList()}');
      });
    }
  }

  Future<void> _toggleVault(Vault vault) async {
    if (widget.transaction.dbId == null) return;
    
    final record = await DatabaseService.getTransaction(widget.transaction.dbId!);
    if (record == null) return;

    final currentVaults = List<int>.from(record.vaultIds);
    bool isCurrentlyAttached = currentVaults.contains(vault.id);

    if (isCurrentlyAttached) {
      if (currentVaults.length <= 1) {
        // Arayüzden kasanın çıkarılmasını engelle, en az bir tane kalmalıdır.
        HapticFeedback.vibrate();
        return;
      }
      currentVaults.remove(vault.id);
    } else {
      currentVaults.add(vault.id);
    }
    
    record.vaultIds = currentVaults;
    record.updatedAt = DateTime.now();
    await DatabaseService.updateTransaction(record);
    
    HapticFeedback.mediumImpact();
    await _loadData();
    // Provider'ları invalidate ederek bakiye ve UI güncellemelerini tetikle
    ref.invalidate(transactionsStreamProvider);
  }

  Future<void> _toggleNotification(bool value) async {
    setState(() {
      _isNotificationEnabled = value;
    });

    if (widget.transaction.dbId != null) {
      final record = await DatabaseService.getTransaction(widget.transaction.dbId!);
      if (record != null) {
        record.isNotificationEnabled = value;
        await DatabaseService.updateTransaction(record);
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
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 110 * sf, height: 110 * sf,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [tx.color.withValues(alpha: 0.2), tx.color.withValues(alpha: 0.0)],
                    ),
                  ),
                ),
                Container(
                  width: 80 * sf, height: 80 * sf,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.02),
                    borderRadius: BorderRadius.circular(24 * sf),
                    border: Border.all(color: AppColors.getAccentDeep(context, tx.color).withValues(alpha: 0.3), width: 0.5),
                  ),
                  child: Icon(tx.icon, size: 36 * sf, color: AppColors.getAccentDeep(context, tx.color)),
                ),
              ],
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
              _buildInfoRow(context, icon: Icons.calendar_today_rounded, label: l10n.added, value: _fullRecord != null ? DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(_fullRecord!.date) : '-', color: Colors.blue),
              Divider(height: 16 * sf, thickness: 0.5),
              _buildInfoRow(context, icon: Icons.replay_rounded, label: l10n.period, value: _getDetailedPeriodLabel(tx, l10n, context), color: Colors.purple),
              
              if (tx.periodType != 0) ...[
                if (tx.recurrenceDuration != null && tx.recurrenceDuration! > 0) ...[
                  Divider(height: 16 * sf, thickness: 0.5),
                  _buildInfoRow(
                    context, 
                    icon: Icons.event_available_rounded, 
                    label: l10n.endDate, 
                    value: _calculateEndDate(tx) != null ? DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(_calculateEndDate(tx)!) : '-', 
                    color: Colors.redAccent
                  ),
                ],
                Divider(height: 16 * sf, thickness: 0.5),
                _buildInfoRow(
                  context, 
                  icon: Icons.task_alt_rounded, 
                  label: l10n.occurred, 
                  value: l10n.times(tx.passedOccurrences), 
                  color: Colors.teal
                ),
                if (tx.recurrenceDuration != null && tx.recurrenceDuration! > 0) ...[
                  Divider(height: 16 * sf, thickness: 0.5),
                  _buildInfoRow(
                    context, 
                    icon: Icons.hourglass_bottom_rounded, 
                    label: l10n.remainingCount, 
                    value: l10n.times((tx.recurrenceDuration! - tx.passedOccurrences).clamp(0, tx.recurrenceDuration!)), 
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
        if (_allVaults.isNotEmpty) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.vaults.toUpperCase(),
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
        if (tx.hasNotification) ...[
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
                  Navigator.pop(context);
                  widget.onEdit();
                },
                height: 52 * sf,
                fontSize: 13,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(width: 12),
            CustomIconButton(
              onTap: () => widget.onDelete(),
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
          label.toUpperCase(),
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
        Expanded(
          child: Text(
            label, 
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.getTextSecondary(context)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )
        ),
        const SizedBox(width: 8),
        Flexible(
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


  DateTime? _calculateEndDate(TransactionUI tx) {
    if (tx.periodType == 0 || tx.recurrenceDuration == null || tx.recurrenceDuration! <= 0) return null;
    
    final start = tx.date;
    final duration = tx.recurrenceDuration! - 1; // İlki başlangıç tarihinde gerçekleştiği için -1
    if (duration <= 0) return start;
    
    if (tx.periodType == 250) {
      DateTime temp = start;
      for (int i = 0; i < duration; i++) {
        int addDays = 1;
        if (temp.weekday == DateTime.friday) {
          addDays = 3;
        } else if (temp.weekday == DateTime.saturday) {
          addDays = 2;
        }
        temp = temp.add(Duration(days: addDays));
      }
      return temp;
    } else if (tx.periodType == 251) {
      DateTime temp = start;
      for (int i = 0; i < duration; i++) {
        int addDays = 1;
        if (temp.weekday == DateTime.sunday) {
          addDays = 6;
        } else if (temp.weekday >= DateTime.monday && temp.weekday <= DateTime.friday) {
          addDays = DateTime.saturday - temp.weekday;
        }
        temp = temp.add(Duration(days: addDays));
      }
      return temp;
    } else {
      final unit = tx.periodType ~/ 100;
      final interval = tx.periodType % 100;
      if (interval > 0) {
        switch (unit) {
          case 1: return start.add(Duration(days: duration * interval));
          case 2: return start.add(Duration(days: duration * interval * 7));
          case 3: return DateTime(start.year, start.month + (duration * interval), start.day, start.hour, start.minute);
          case 4: return DateTime(start.year + (duration * interval), start.month, start.day, start.hour, start.minute);
        }
      }
    }
    return null;
  }

  String _getDetailedPeriodLabel(TransactionUI tx, AppLocalizations l10n, BuildContext context) {
    final isTr = Localizations.localeOf(context).languageCode == 'tr';
    String base = '';
    
    if (tx.periodType == 0) {
      base = l10n.oneTime;
    } else if (tx.periodType == 250) {
      base = isTr ? 'Hafta İçi' : 'Weekdays';
    } else if (tx.periodType == 251) {
      base = isTr ? 'Hafta Sonu' : 'Weekends';
    } else {
      final unit = tx.periodType ~/ 100;
      final interval = tx.periodType % 100;
      
      switch (unit) {
        case 1: // Gün
          if (interval == 1) {
            base = l10n.everyDayDetailed;
          } else {
            base = isTr ? '$interval Günde Bir' : 'Every $interval Days';
          }
          break;
        case 2: // Hafta
          if (interval == 1) {
            base = l10n.everyWeekDetailed;
          } else {
            base = isTr ? '$interval Haftada Bir' : 'Every $interval Weeks';
          }
          break;
        case 3: // Ay
          if (interval == 1) {
            base = l10n.everyMonthDetailed;
          } else {
            base = isTr ? '$interval Ayda Bir' : 'Every $interval Months';
          }
          break;
        case 4: // Yıl
          if (interval == 1) {
            base = l10n.everyYearDetailed;
          } else {
            base = isTr ? '$interval Yılda Bir' : 'Every $interval Years';
          }
          break;
        default:
          base = l10n.oneTime;
      }
    }
    
    if (tx.periodType != 0) {
      List<String> details = [base];
      final unit = tx.periodType ~/ 100;
      
      if (tx.recurrenceDay != null && (unit == 2 || tx.periodType == 250 || tx.periodType == 251)) {
        final List<String> weekDays = [l10n.monday, l10n.tuesday, l10n.wednesday, l10n.thursday, l10n.friday, l10n.saturday, l10n.sunday];
        if (tx.recurrenceDay! > 0 && tx.recurrenceDay! <= 7) {
          details.add(weekDays[tx.recurrenceDay! - 1]);
        }
      } else if (tx.recurrenceDate != null && (unit == 3 || unit == 4)) {
        if (unit == 4) {
          // Yıllık ise: 12 Mayıs
          details.add(DateFormat.MMMMd(Localizations.localeOf(context).toString()).format(tx.recurrenceDate!));
        } else {
          // Aylık veya X ayda bir ise: Ayın 12'si
          details.add(l10n.dayOfMonthOrdinal(tx.recurrenceDate!.day));
        }
      }
      
      if (tx.recurrenceDuration != null && tx.recurrenceDuration! > 0) {
        details.add(l10n.times(tx.recurrenceDuration!));
      } else {
        details.add(l10n.indefinitely);
      }
      
      return details.join(' • ');
    }
    
    return base;
  }
}
