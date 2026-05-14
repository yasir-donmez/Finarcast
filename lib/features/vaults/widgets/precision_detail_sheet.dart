import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/database/database_service.dart';
import '../../../../core/database/models/vault.dart';
import '../../../../core/database/models/transaction_record.dart';

import '../../../../shared/widgets/precision_card.dart';
import '../../../../shared/widgets/precision_button.dart';
import '../../../../shared/widgets/precision_icon_button.dart';
import '../../../../shared/widgets/precision_dialog.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/precision_toggle.dart';
import '../../../../shared/widgets/precision_animated_icon.dart';
import '../vaults_providers.dart';

class PrecisionDetailSheet extends ConsumerStatefulWidget {
  final TransactionUI transaction;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onRemoveFromVault;
  final bool isInVault;

  const PrecisionDetailSheet({
    super.key,
    required this.transaction,
    required this.onEdit,
    required this.onDelete,
    this.onRemoveFromVault,
    required this.isInVault,
  });

  @override
  ConsumerState<PrecisionDetailSheet> createState() => _PrecisionDetailSheetState();
}

class _PrecisionDetailSheetState extends ConsumerState<PrecisionDetailSheet> {
  List<Vault> _attachedVaults = [];
  TransactionRecord? _fullRecord;
  late bool _isNotificationEnabled;

  @override
  void initState() {
    super.initState();
    _isNotificationEnabled = widget.transaction.isNotificationEnabled;
    _loadData();
  }

  Future<void> _loadData() async {
    final allVaults = await DatabaseService.getAllVaults();
    final ids = widget.transaction.groupIds.map((id) => int.tryParse(id.replaceFirst('v_', ''))).whereType<int>().toList();
    if (widget.transaction.dbId != null) {
      _fullRecord = await DatabaseService.getTransaction(widget.transaction.dbId!);
    }
    if (mounted) {
      setState(() {
        _attachedVaults = allVaults.where((v) => ids.contains(v.id)).toList();
      });
    }
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
                    border: Border.all(color: tx.color.withValues(alpha: 0.3), width: 0.5),
                  ),
                  child: Icon(tx.icon, size: 36 * sf, color: tx.color),
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
                      color: Colors.grey.withValues(alpha: 0.4),
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    l10n.addAmountByEditing,
                    style: TextStyle(
                      fontSize: 12 * sf,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.withValues(alpha: 0.3),
                    ),
                  ),
                ],
              )
            : hasFlexibleAmount
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildRangeValue(l10n.minimum, tx.minAmount!, tx.currency, sf, isDark),
                    Padding(
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
        PrecisionCard(
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
                  value: l10n.times(_calculatePassedOccurrences(tx)), 
                  color: Colors.teal
                ),
                if (tx.recurrenceDuration != null && tx.recurrenceDuration! > 0) ...[
                  Divider(height: 16 * sf, thickness: 0.5),
                  _buildInfoRow(
                    context, 
                    icon: Icons.hourglass_bottom_rounded, 
                    label: l10n.remainingCount, 
                    value: l10n.times((tx.recurrenceDuration! - _calculatePassedOccurrences(tx)).clamp(0, tx.recurrenceDuration!)), 
                    color: Colors.deepOrange
                  ),
                ],
              ],

              if (tx.note != null && tx.note!.isNotEmpty) ...[
                Divider(height: 16 * sf, thickness: 0.5),
                _buildInfoRow(context, icon: Icons.notes_rounded, label: l10n.note, value: tx.note!, color: Colors.amber),
              ]
            ],
          ),
        ),

        const SizedBox(height: 8),

        // 3. KASALAR
        if (_attachedVaults.isNotEmpty) ...[
          Text(l10n.vaults.toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.grey.withValues(alpha: 0.5), letterSpacing: 1.5)),
          const SizedBox(height: 4),
          ..._attachedVaults.map((vault) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: PrecisionCard(
              scalingFactor: sf,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: AppColors.getPrimary(context).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                    child: Icon(Icons.account_balance_wallet_rounded, size: 12, color: AppColors.getPrimary(context)),
                  ),
                  const SizedBox(width: 8),
                  Text(vault.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                  const Spacer(),
                  PrecisionIconButton(
                    onTap: () async {
                      final confirm = await showPrecisionDialog<bool>(
                        context: context,
                        accentColor: AppColors.error,
                        title: l10n.removeFromVault,
                        content: l10n.removeFromVaultDesc,
                        actions: [
                          PrecisionDialogAction(
                            label: l10n.cancel, 
                            onTap: () => Navigator.pop(context, false), 
                            isPrimary: false,
                          ),
                          PrecisionDialogAction(
                            label: l10n.ok, 
                            onTap: () => Navigator.pop(context, true), 
                            isPrimary: true,
                          ),
                        ],
                      );
                      if (confirm == true) {
                        final record = await DatabaseService.getTransaction(tx.dbId!);
                        if (record != null) {
                          record.vaultIds = List<int>.from(record.vaultIds)..remove(vault.id);
                          await DatabaseService.updateTransaction(record);
                          HapticFeedback.heavyImpact();
                          _loadData();
                        }
                      }
                    },
                    icon: Icons.close_rounded,
                    color: AppColors.error,
                    backgroundColor: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: 8,
                    size: 14,
                    padding: 6,
                  ),
                ],
              ),
            ),
          )),
        ],

        SizedBox(height: 12 * sf),

        // 3.5 BİLDİRİM TOGGLE
        PrecisionCard(
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
                child: PrecisionAnimatedIcon(
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
                        color: AppColors.getTextSecondary(context).withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              PrecisionToggle(
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

        // 4. AKSİYONLAR
        Row(
          children: [
            Expanded(
              child: PrecisionButton(
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
            PrecisionIconButton(
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
            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.2),
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
              color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.3),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, {required IconData icon, required String label, required String value, required Color color}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 16, color: color),
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
        Text(
          value, 
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
          maxLines: 1,
          overflow: TextOverflow.visible,
        ),
      ],
    );
  }

  int _calculatePassedOccurrences(TransactionUI tx) {
    if (tx.periodType == 0) return 0;
    
    // Tarih bazlı karşılaştırma için saatleri sıfırlayalım (Date-only)
    final now = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final start = DateTime(tx.date.year, tx.date.month, tx.date.day);
    
    if (now.isBefore(start)) return 0;

    final diffDays = now.difference(start).inDays;
    int intervals = 0;
    
    switch (tx.periodType) {
      case 1: intervals = diffDays ~/ 7; break;
      case 2: // Aylık
        intervals = (now.year - start.year) * 12 + now.month - start.month;
        if (now.day < start.day) intervals--;
        break;
      case 3: // Yıllık
        intervals = now.year - start.year;
        if (now.month < start.month || (now.month == start.month && now.day < start.day)) intervals--;
        break;
      case 4: intervals = diffDays ~/ 14; break;
      case 5: intervals = diffDays ~/ 21; break;
      case 6: // 3 Ayda bir
        int months = (now.year - start.year) * 12 + now.month - start.month;
        if (now.day < start.day) months--;
        intervals = months ~/ 3;
        break;
      case 7: // 6 Ayda bir
        int months = (now.year - start.year) * 12 + now.month - start.month;
        if (now.day < start.day) months--;
        intervals = months ~/ 6;
        break;
      case 8: intervals = diffDays; break; // Günlük
      case 9: intervals = diffDays ~/ 2; break;
      case 10: intervals = diffDays ~/ 3; break;
      default: intervals = 0;
    }
    
    // Gerçekleşen sayısı = tamamlanan aralıklar + başlangıçtaki ilk işlem (+1)
    int passed = (intervals < 0 ? 0 : intervals) + 1;
    
    // Eğer bir süre sınırı varsa, gerçekleşen sayısı bu sınırı aşmamalı
    if (tx.recurrenceDuration != null && tx.recurrenceDuration! > 0) {
      if (passed > tx.recurrenceDuration!) passed = tx.recurrenceDuration!;
    }
    
    return passed;
  }

  DateTime? _calculateEndDate(TransactionUI tx) {
    if (tx.periodType == 0 || tx.recurrenceDuration == null || tx.recurrenceDuration! <= 0) return null;
    
    final start = tx.date;
    final duration = tx.recurrenceDuration! - 1; // İlki başlangıç tarihinde gerçekleştiği için -1
    if (duration <= 0) return start;
    
    switch (tx.periodType) {
      case 1: return start.add(Duration(days: duration * 7));
      case 2: return DateTime(start.year, start.month + duration, start.day, start.hour, start.minute);
      case 3: return DateTime(start.year + duration, start.month, start.day, start.hour, start.minute);
      case 4: return start.add(Duration(days: duration * 14));
      case 5: return start.add(Duration(days: duration * 21));
      case 6: return DateTime(start.year, start.month + (duration * 3), start.day, start.hour, start.minute);
      case 7: return DateTime(start.year, start.month + (duration * 6), start.day, start.hour, start.minute);
      case 8: return start.add(Duration(days: duration));
      case 9: return start.add(Duration(days: duration * 2));
      case 10: return start.add(Duration(days: duration * 3));
      default: return null;
    }
  }

  String _getDetailedPeriodLabel(TransactionUI tx, AppLocalizations l10n, BuildContext context) {
    String base = '';
    switch (tx.periodType) {
      case 0: base = l10n.oneTime; break;
      case 1: base = l10n.everyWeekDetailed; break;
      case 2: base = l10n.everyMonthDetailed; break;
      case 3: base = l10n.everyYearDetailed; break;
      case 4: base = l10n.every2WeeksDetailed; break;
      case 5: base = l10n.every3WeeksDetailed; break;
      case 6: base = l10n.every3MonthsDetailed; break;
      case 7: base = l10n.every6MonthsDetailed; break;
      case 8: base = l10n.everyDayDetailed; break;
      case 9: base = l10n.every2DaysDetailed; break;
      case 10: base = l10n.every3DaysDetailed; break;
      default: base = l10n.oneTime;
    }
    if (tx.periodType != 0) {
      List<String> details = [base];
      
      if (tx.recurrenceDay != null && [1, 4, 5].contains(tx.periodType)) {
        final List<String> weekDays = [l10n.monday, l10n.tuesday, l10n.wednesday, l10n.thursday, l10n.friday, l10n.saturday, l10n.sunday];
        if (tx.recurrenceDay! > 0 && tx.recurrenceDay! <= 7) {
          details.add(weekDays[tx.recurrenceDay! - 1]);
        }
      } else if (tx.recurrenceDate != null && [2, 3, 6, 7].contains(tx.periodType)) {
        if (tx.periodType == 3) {
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
