import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/database/models/transaction_record.dart';
import '../../../../shared/widgets/precision_glass_card.dart';
import '../../../../shared/widgets/precision_animated_icon.dart';
import '../../../../shared/widgets/precision_multi_toggle.dart';
import '../../../../l10n/app_localizations.dart';

class OptimizationItemsSection extends StatefulWidget {
  final List<TransactionRecord> txs;
  final int? scopeVaultId;
  final Set<int> userLockedIds;
  final Set<int> userFlexibleIds;
  final Function(int id, int status) onStatusChanged;
  final AppLocalizations l10n;

  const OptimizationItemsSection({
    super.key,
    required this.txs,
    this.scopeVaultId,
    required this.userLockedIds,
    required this.userFlexibleIds,
    required this.onStatusChanged,
    required this.l10n,
  });

  @override
  State<OptimizationItemsSection> createState() => _OptimizationItemsSectionState();
}

class _OptimizationItemsSectionState extends State<OptimizationItemsSection> {
  bool _showPreselect = false;
  final _currencyFormat = NumberFormat('#,##0', 'tr_TR');

  @override
  Widget build(BuildContext context) {
    final scopedTxs = widget.scopeVaultId == null
        ? widget.txs
        : widget.txs.where((t) => t.vaultIds.contains(widget.scopeVaultId)).toList();
    final relevant = scopedTxs.where((t) => t.periodType != 0).toList();

    return PrecisionGlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _showPreselect = !_showPreselect);
            },
            borderRadius: BorderRadius.circular(AppSizes.radiusDefault),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  PrecisionAnimatedIcon(
                    isActive: _showPreselect,
                    activeIcon: Icons.layers_rounded,
                    inactiveIcon: Icons.tune_rounded,
                    color: AppColors.getPrimary(context),
                    size: 20,
                    duration: const Duration(milliseconds: 450),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          widget.l10n.items.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                          ),
                        ),
                        if (relevant.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.getPrimary(context).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              relevant.length.toString(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.getPrimary(context),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _showPreselect ? 0.5 : 0,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutBack,
                    child: Icon(
                      Icons.expand_more_rounded,
                      color: AppColors.getTextSecondary(
                        context,
                      ).withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutQuart,
            child: _showPreselect
                ? Column(
                    children: [
                      const Divider(height: 1, indent: 20, endIndent: 20),
                      if (relevant.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                          child: Text(
                            widget.l10n.noItemsToAnalyze,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.getTextSecondary(context).withValues(alpha: 0.5),
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        )
                      else
                        ...relevant.map((tx) => _preselectRowFluid(tx)),
                      const SizedBox(height: 16),
                    ],
                  )
                : const SizedBox(width: double.infinity, height: 0),
          ),
        ],
      ),
    );
  }

  Widget _preselectRowFluid(TransactionRecord tx) {
    final isLocked = widget.userLockedIds.contains(tx.id);
    final isFlexible = widget.userFlexibleIds.contains(tx.id);
    final int selectedIndex = isLocked ? 0 : (isFlexible ? 2 : 1);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.title,
                  style: TextStyle(
                    color: AppColors.getTextPrimary(context),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${_currencyFormat.format(tx.amount.toInt())} ${tx.currency}',
                  style: TextStyle(
                    color: AppColors.getTextSecondary(context).withValues(alpha: 0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          PrecisionMultiToggle(
            icons: const [
              Icons.lock_rounded,
              Icons.drag_handle_rounded,
              Icons.auto_fix_high_rounded,
            ],
            selectedIndex: selectedIndex,
            activeColors: [
              AppColors.error,
              AppColors.getTextSecondary(context).withValues(alpha: 0.6),
              const Color(0xFF00E5FF),
            ],
            onChanged: (index) {
              widget.onStatusChanged(tx.id, index);
            },
          ),
        ],
      ),
    );
  }
}
