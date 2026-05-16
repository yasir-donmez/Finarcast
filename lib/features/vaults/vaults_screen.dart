import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../core/theme/app_constants.dart';
import '../../core/database/database_service.dart';
import '../../shared/widgets/precision_sheet.dart';
import '../../shared/widgets/precision_dialog.dart';
import '../../shared/widgets/precision_inset.dart';
import 'vaults_providers.dart';
import 'widgets/precision_transaction_card.dart';
import '../transactions/add_transaction_screen.dart';

import 'widgets/add_vault_sheet.dart';
import 'widgets/vault_detail_sheet.dart';
import 'widgets/precision_detail_sheet.dart';
import '../dashboard/dashboard_providers.dart';
import '../dashboard/dashboard_scroll_provider.dart';
import 'widgets/header_delegate.dart';
import 'widgets/filter_chip.dart';
import 'widgets/vault_snap_scroll_physics.dart';
import 'widgets/staggered_entry_anim.dart';

class VaultsScreen extends ConsumerStatefulWidget {
  const VaultsScreen({super.key});

  @override
  ConsumerState<VaultsScreen> createState() => _VaultsScreenState();
}

class _VaultsScreenState extends ConsumerState<VaultsScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final allTransactions = ref.watch(vaultTransactionsProvider);
    final groups = ref.watch(transactionGroupsProvider);
    final filter = ref.watch(transactionFilterProvider);
    final selectedVaultId = ref.watch(selectedVaultProvider);
    final selectedPeriod = ref.watch(selectedPeriodProvider);
    final activeColor = ref.watch(rotaryColorProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredTransactions = ref.watch(filteredVaultTransactionsProvider);

    final screenHeight = MediaQuery.of(context).size.height;
    final scalingFactor = (screenHeight / 812.0).clamp(0.85, 1.0);
    final topPadding = MediaQuery.of(context).padding.top;

    final scrollController = ref.watch(dashboardScrollProvider);

    // YENİ: HeaderDelegate içindeki gerçek değerlerle eşitleme
    const maxHeaderHeight = 420.0;
    final minHeaderHeight = topPadding + 56.0 + 20.0; // kCompactCardHeight + kHeaderBottomBuffer

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Eski bloblar kaldırıldı, global pattern görünüyor

          CustomScrollView(
            controller: scrollController,
            physics: VaultSnapScrollPhysics(
              maxScrollExtent: maxHeaderHeight - minHeaderHeight,
            ),
            slivers: [
              _buildHeader(groups, allTransactions, selectedVaultId, activeColor, l10n, context),
              _buildFilters(filter, selectedPeriod, activeColor, scalingFactor, l10n, context),
              
              if (filteredTransactions.isEmpty)
                _buildEmptyState(activeColor, isDark, l10n)
              else
                _buildTransactionGrid(filteredTransactions, context),

              _buildSmartSpacing(maxHeaderHeight, minHeaderHeight),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    List<TransactionGroup> groups, 
    List<TransactionUI> allTransactions, 
    String? selectedVaultId, 
    Color activeColor, 
    AppLocalizations l10n, 
    BuildContext context
  ) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: TrueMorphDeckHeaderDelegate(
        groups: groups,
        allTransactions: allTransactions,
        selectedVaultId: selectedVaultId,
        onVaultSelect: (id) => ref.read(selectedVaultProvider.notifier).state = id,
        activeColor: activeColor,

        onAddVault: () => _showAddVaultSheet(context),
        l10n: l10n,
        onVaultTap: (id) => _showVaultDetail(context, id),
        topPadding: MediaQuery.of(context).padding.top,
      ),
    );
  }

  Widget _buildFilters(
    TransactionFilter filter, 
    int? selectedPeriod, 
    Color activeColor, 
    double scalingFactor, 
    AppLocalizations l10n, 
    BuildContext context
  ) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.paddingMedium,
          0, // Üst boşluk tamamen kaldırıldı
          AppSizes.paddingMedium,
          24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8), // Filtre butonları ile üstteki kart arasında çok az bir nefes payı
            Row(
              children: [
                VaultFilterChip(
                  label: l10n.all,
                  isActive: filter == TransactionFilter.all,
                  onTap: () => ref.read(transactionFilterProvider.notifier).state = TransactionFilter.all,
                  activeColor: activeColor,
                ),
                const SizedBox(width: 8),
                VaultFilterChip(
                  label: l10n.income,
                  isActive: filter == TransactionFilter.income,
                  onTap: () => ref.read(transactionFilterProvider.notifier).state = TransactionFilter.income,
                  activeColor: AppColors.getIncome(context),
                ),
                const SizedBox(width: 8),
                VaultFilterChip(
                  label: l10n.expense,
                  isActive: filter == TransactionFilter.expense,
                  onTap: () => ref.read(transactionFilterProvider.notifier).state = TransactionFilter.expense,
                  activeColor: AppColors.getExpense(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              clipBehavior: Clip.none,
              child: Row(
                children: [
                  VaultFilterChip(
                    label: l10n.allTime,
                    isActive: selectedPeriod == null,
                    onTap: () => ref.read(selectedPeriodProvider.notifier).state = null,
                    activeColor: activeColor,
                  ),
                  const SizedBox(width: 8),
                  ...[1, 2, 3].map(
                    (p) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: VaultFilterChip(
                        label: _getPeriodLabel(p, l10n),
                        isActive: selectedPeriod == p,
                        onTap: () => ref.read(selectedPeriodProvider.notifier).state = p,
                        activeColor: activeColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(Color activeColor, bool isDark, AppLocalizations l10n) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Align(
        alignment: const Alignment(0, -0.4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 1200),
                tween: Tween(begin: 0.0, end: 1.0),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return PrecisionInset(
                    size: 100,
                    child: Transform.scale(
                      scale: 0.4 + (0.6 * value),
                      child: Opacity(
                        opacity: value.clamp(0.0, 1.0),
                        child: child,
                      ),
                    ),
                  );
                },
                child: Icon(
                  Icons.auto_graph_rounded,
                  size: 40,
                  color: activeColor.withValues(alpha: isDark ? 0.3 : 0.1),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Kasa İşlemi Bulunmadı".toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.15)
                      : Colors.grey.withValues(alpha: 0.3),
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionGrid(List<TransactionUI> transactions, BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.paddingMedium,
        0,
        AppSizes.paddingMedium,
        20,
      ),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.35,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final tx = transactions[index];
            return StaggeredEntryAnim(
              key: ValueKey(tx.id),
              index: index,
              child: PrecisionTransactionCard(
                transaction: tx,
                onTap: () => _showTransactionActions(context, tx),
                onLongPress: () {
                  HapticFeedback.heavyImpact();
                  _showTransactionActions(context, tx);
                },
              ),
            );
          },
          childCount: transactions.length,
        ),
      ),
    );
  }

  Widget _buildSmartSpacing(double maxHeaderHeight, double minHeaderHeight) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final totalHeightAtStart = constraints.precedingScrollExtent + constraints.scrollOffset;
        final targetHeight = constraints.viewportMainAxisExtent + (maxHeaderHeight - minHeaderHeight);
        final gap = targetHeight - totalHeightAtStart;

        return SliverToBoxAdapter(
          child: SizedBox(height: gap > 0 ? gap : 0),
        );
      },
    );
  }

  String _getPeriodLabel(int period, AppLocalizations l10n) {
    switch (period) {
      case 0:
        return l10n.oneTime;
      case 1:
        return l10n.weekly;
      case 4:
        return l10n.every2Weeks;
      case 5:
        return l10n.every3Weeks;
      case 2:
        return l10n.monthly;
      case 6:
        return l10n.every3Months;
      case 7:
        return l10n.every6Months;
      case 3:
        return l10n.yearly;
      default:
        return '';
    }
  }

  void _showTransactionActions(BuildContext context, TransactionUI tx) {
    if (tx.dbId == null) return;
    
    final l10n = AppLocalizations.of(context)!;
    final categoryName = localizedCategoryName(tx.categoryId, l10n) ?? l10n.all;
    final parentId = tx.categoryId?.split('_').take(2).join('_');
    final parentName = parentId != null ? localizedCategoryName(parentId, l10n) : null;
    final fullTitle = parentName != null && parentName != categoryName 
        ? '$parentName / $categoryName' 
        : categoryName;

    final selectedVaultId = ref.read(selectedVaultProvider);

    PrecisionSheet.show(
      context: context,
      title: fullTitle,
      child: PrecisionDetailSheet(
        transaction: tx,
        onEdit: () {
          final selectedVaultId = ref.read(selectedVaultProvider);
          final currentVaultIds = tx.groupIds
              .map((vId) => int.parse(vId.replaceFirst('v_', '')))
              .toList();
          
          // Eğer bir kasa seçili ise ve işlem bu kasada değilse, düzenleme ekranına bu kasayı da seçili gönder
          if (selectedVaultId != null) {
            final vId = int.tryParse(selectedVaultId.replaceFirst('v_', ''));
            if (vId != null && !currentVaultIds.contains(vId)) {
              currentVaultIds.add(vId);
            }
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTransactionScreen(
                initialId: tx.dbId,
                initialName: tx.name,
                initialAmount: tx.amount,
                initialMinAmount: tx.minAmount,
                initialMaxAmount: tx.maxAmount,
                initialIsIncome: tx.isIncome,
                initialVaultIds: currentVaultIds,
                initialCategoryId: tx.categoryId,
                initialNote: tx.note,
                initialCurrency: tx.currency,
                initialPeriodType: tx.periodType,
                initialRecurrenceDay: tx.recurrenceDay,
                initialRecurrenceDate: tx.recurrenceDate,
                initialRecurrenceDuration: tx.recurrenceDuration,
                initialIsNotificationEnabled: tx.isNotificationEnabled,
                initialNotificationReminderDays: tx.notificationReminderDays,
                initialNotificationHour: tx.notificationHour,
                initialNotificationMinute: tx.notificationMinute,
              ),
              fullscreenDialog: true,
            ),
          );
        },
        onDelete: () async {
          final confirm = await showPrecisionDialog<bool>(
            context: context,
            accentColor: AppColors.error,
            title: AppLocalizations.of(context)!.permanentDelete,
            content: AppLocalizations.of(context)!.permanentDeleteDesc,
            actions: [
              PrecisionDialogAction(
                label: AppLocalizations.of(context)!.cancel,
                onTap: () => Navigator.pop(context, false),
                isPrimary: false,
              ),
              PrecisionDialogAction(
                label: AppLocalizations.of(context)!.ok,
                onTap: () => Navigator.pop(context, true),
                isPrimary: true,
              ),
            ],
          );
          if (confirm == true) {
            await DatabaseService.deleteTransaction(tx.dbId!);
            HapticFeedback.mediumImpact();
            if (context.mounted) Navigator.pop(context); // Close the detail sheet
          }
        },
        onRemoveFromVault: selectedVaultId != null ? () async {
          final record = await DatabaseService.getTransaction(tx.dbId!);
          if (record != null) {
            final vId = int.tryParse(selectedVaultId.replaceFirst('v_', ''));
            if (vId != null) {
              record.vaultIds = List<int>.from(record.vaultIds)..remove(vId);
              await DatabaseService.updateTransaction(record);
              HapticFeedback.mediumImpact();
            }
          }
        } : null,
        isInVault: tx.groupIds.isNotEmpty,
      ),
    );
  }



  void _showAddVaultSheet(BuildContext context) {
    HapticFeedback.heavyImpact();
    PrecisionSheet.show(
      context: context,
      title: AppLocalizations.of(context)!.addNewVault,
      child: const AddVaultSheet(),
    );
  }

  void _showVaultDetail(BuildContext context, String? vaultId) {
    HapticFeedback.mediumImpact();
    PrecisionSheet.show(
      context: context,
      title: AppLocalizations.of(context)!.vaultDetail,
      child: VaultDetailSheet(vaultId: vaultId),
    );
  }
}
