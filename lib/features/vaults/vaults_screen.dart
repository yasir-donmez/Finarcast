import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../core/theme/app_constants.dart';
import '../../core/utils/string_utils.dart';
import '../../core/database/database_service.dart';
import '../../core/database/models/transaction_status.dart';
import '../../shared/widgets/custom_bottom_sheet.dart';
import '../../shared/widgets/custom_dialog.dart';
import '../../shared/widgets/inset_container.dart';
import 'vaults_providers.dart';
import 'widgets/template_card.dart';
import 'widgets/history_day_group.dart';
import '../transactions/transaction_builder_screen.dart';
import '../../core/utils/route_transitions.dart';
import '../../core/utils/category_utils.dart';
import '../../core/providers/db_providers.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/services/subscription_service.dart';
import '../subscription/widgets/pro_upgrade_sheet.dart';

import 'widgets/add_vault_sheet.dart';
import 'widgets/vault_detail_sheet.dart';
import 'widgets/detail_sheet.dart';
import 'widgets/in_app_notifications_sheet.dart';
import '../home/home_providers.dart';
import '../home/home_scroll_provider.dart';
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
  final Set<String> _animatedTxIds = {};

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
    final groups = ref.watch(transactionGroupsProvider);
    final filter = ref.watch(transactionFilterProvider);
    final selectedVaultId = ref.watch(selectedVaultProvider);
    final activeColor = ref.watch(rotaryColorProvider);
    final unseenNotificationsCount = ref.watch(unseenNotificationsCountProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final viewMode = ref.watch(vaultViewModeProvider);
    final filteredTransactions = ref.watch(filteredVaultTransactionsProvider);
    final filteredTemplates = ref.watch(filteredVaultTemplatesProvider);

    final isEmpty = viewMode == VaultViewMode.templates
        ? filteredTemplates.isEmpty
        : filteredTransactions.isEmpty;

    final screenHeight = MediaQuery.of(context).size.height;
    final scalingFactor = (screenHeight / 812.0).clamp(0.85, 1.0);
    final topPadding = MediaQuery.of(context).padding.top;

    final scrollController = ref.watch(homeScrollProvider);
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final screenWidth = MediaQuery.of(context).size.width;

    // Sabit boşluklar
    const double gapAB = 32.0;  // Başlık↔Kasa ve Kasa↔Filtre arası
    const double gapCD = 16.0;  // Filtre↔Kartlar ve Kartlar↔Navbar arası
    const double gapCardToFilters = 16.0;
    const double titleBarH = 42.0;
    const double cardH = 286.0;
    const double filtersH = 56.0; // 1 satır chip filtre alanı yüksekliği
    const double navbarH = 80.0;

    final topArea = topPadding + titleBarH + gapAB + cardH + gapCardToFilters + filtersH + gapCD;
    final bottomArea = navbarH + bottomPadding + gapCD;
    final availableForGrid = screenHeight - topArea - bottomArea;
    final cardHeight = ((availableForGrid - 12.0) / 2.0).clamp(80.0, 200.0);
    final cardWidth = (screenWidth - 32.0 - 12.0) / 2.0;
    final dynamicAspectRatio = cardWidth / cardHeight;

    final maxHeaderHeight = topPadding + titleBarH + gapAB + cardH;
    final minHeaderHeight = topPadding + 56.0 + 20.0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          CustomScrollView(
            controller: scrollController,
            physics: VaultSnapScrollPhysics(
              maxScrollExtent: maxHeaderHeight - minHeaderHeight,
            ),
            slivers: [
              _buildHeader(groups, selectedVaultId, activeColor, unseenNotificationsCount, gapAB, l10n, context),
              _buildFilters(viewMode, filter, activeColor, scalingFactor, gapCardToFilters, l10n, context),
              
              if (isEmpty)
                _buildEmptyState(activeColor, isDark, l10n)
              else if (viewMode == VaultViewMode.templates)
                _buildTemplateGrid(filteredTemplates, dynamicAspectRatio, context)
              else
                _buildTransactionHistoryList(filteredTransactions, context),

              _buildSmartSpacing(maxHeaderHeight, minHeaderHeight),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    List<TransactionGroup> groups, 
    String? selectedVaultId, 
    Color activeColor, 
    int unseenNotificationsCount,
    double dynamicGap,
    AppLocalizations l10n, 
    BuildContext context
  ) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: TrueMorphDeckHeaderDelegate(
        groups: groups,
        selectedVaultId: selectedVaultId,
        onVaultSelect: (id) => ref.read(selectedVaultProvider.notifier).state = id,
        activeColor: activeColor,
        onAddVault: () => _showAddVaultSheet(context),
        l10n: l10n,
        onVaultTap: (id) => _showVaultDetail(context, id),
        topPadding: MediaQuery.of(context).padding.top,
        onShowNotifications: () => _showNotificationsSheet(context),
        unseenNotificationsCount: unseenNotificationsCount,
        dynamicGap: dynamicGap,
      ),
    );
  }

  Widget _buildFilters(
    VaultViewMode viewMode,
    TransactionFilter filter, 
    Color activeColor, 
    double scalingFactor, 
    double dynamicGap,
    AppLocalizations l10n, 
    BuildContext context
  ) {
    final settings = ref.watch(settingsProvider);
    final langCode = settings.languageCode.split('_')[0].toLowerCase();

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.paddingMedium,
          0,
          AppSizes.paddingMedium,
          16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: dynamicGap),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 6),
              clipBehavior: Clip.none,
              child: Row(
                children: [
                  VaultFilterChip(
                    label: _getPlansLabel(langCode),
                    isActive: viewMode == VaultViewMode.templates,
                    onTap: () {
                      ref.read(vaultViewModeProvider.notifier).state = VaultViewMode.templates;
                      HapticFeedback.lightImpact();
                    },
                    activeColor: activeColor,
                  ),
                  const SizedBox(width: 8),
                  VaultFilterChip(
                    label: _getHistoryLabel(langCode),
                    isActive: viewMode == VaultViewMode.history,
                    onTap: () {
                      ref.read(vaultViewModeProvider.notifier).state = VaultViewMode.history;
                      HapticFeedback.lightImpact();
                    },
                    activeColor: activeColor,
                  ),
                  
                  // Dikey Ayraç
                  Container(
                    height: 18 * scalingFactor,
                    width: 1.5,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.getTextSecondary(context).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),

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
            ),
          ],
        ),
      ),
    );
  }


  String _getPlansLabel(String langCode) {
    switch (langCode) {
      case 'tr': return 'Planlar';
      case 'de': return 'Pläne';
      case 'fr': return 'Plans';
      case 'es': return 'Planes';
      case 'it': return 'Piani';
      case 'pt': return 'Planos';
      case 'zh': return '计划';
      case 'ja': return 'プラン';
      case 'ko': return '계획';
      default: return 'Plans';
    }
  }

  String _getHistoryLabel(String langCode) {
    switch (langCode) {
      case 'tr': return 'İşlemler';
      case 'de': return 'Transaktionen';
      case 'fr': return 'Transactions';
      case 'es': return 'Transacciones';
      case 'it': return 'Transazioni';
      case 'pt': return 'Transações';
      case 'zh': return '交易';
      case 'ja': return '取引';
      case 'ko': return '거래';
      default: return 'Transactions';
    }
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
                  return InsetContainer(
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
                  color: AppColors.getTextSecondary(context).withValues(alpha: 0.4),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.noVaultTransactions.toSafeUpperCase(context),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.getTextSecondary(context).withValues(alpha: 0.7),
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

  Widget _buildTemplateGrid(List<TemplateUI> templates, double childAspectRatio, BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        AppSizes.paddingMedium,
        0,
        AppSizes.paddingMedium,
        80.0 + bottomPadding + 16.0,
      ),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: childAspectRatio,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final template = templates[index];
            final tId = 't_${template.id}';
            final shouldAnimate = !_animatedTxIds.contains(tId);
            if (shouldAnimate) {
              _animatedTxIds.add(tId);
            }
            return StaggeredEntryAnim(
              key: ValueKey(tId),
              index: index,
              animate: shouldAnimate,
              child: TemplateCard(
                template: template,
                onTap: () => _showTemplateActions(context, template),
                onLongPress: () {
                  HapticFeedback.heavyImpact();
                  _showTemplateActions(context, template);
                },
              ),
            );
          },
          childCount: templates.length,
        ),
      ),
    );
  }

  Widget _buildTransactionHistoryList(List<TransactionUI> transactions, BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    // Group transactions by day
    final Map<DateTime, List<TransactionUI>> grouped = {};
    for (final tx in transactions) {
      final dateOnly = DateTime(tx.date.year, tx.date.month, tx.date.day);
      grouped.putIfAbsent(dateOnly, () => []).add(tx);
    }
    final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        AppSizes.paddingMedium,
        0,
        AppSizes.paddingMedium,
        80.0 + bottomPadding + 16.0,
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final date = sortedDates[index];
            final txs = grouped[date]!;
            
            return HistoryDayGroup(
              date: date,
              transactions: txs,
              onReviewed: (tx) async {
                if (tx.dbId != null) {
                  final record = await DatabaseService.getTransaction(tx.dbId!);
                  if (record != null) {
                    record.status = TransactionStatus.confirmed;
                    record.isReviewed = true;
                    await DatabaseService.updateTransaction(record);
                  }
                }
              },
              onSkipped: (tx) async {
                if (tx.dbId != null) {
                  final record = await DatabaseService.getTransaction(tx.dbId!);
                  if (record != null) {
                    record.status = TransactionStatus.skipped;
                    record.isReviewed = true;
                    await DatabaseService.updateTransaction(record);
                  }
                }
              },
              onTap: (tx) => _showTransactionActions(context, tx),
              onLongPress: (tx) {
                HapticFeedback.heavyImpact();
                _showTransactionActions(context, tx);
              },
            );
          },
          childCount: sortedDates.length,
        ),
      ),
    );
  }

  Widget _buildSmartSpacing(double maxHeaderHeight, double minHeaderHeight) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final totalHeightAtStart = constraints.precedingScrollExtent;
        final targetHeight = constraints.viewportMainAxisExtent + (maxHeaderHeight - minHeaderHeight);
        final gap = targetHeight - totalHeightAtStart;

        return SliverToBoxAdapter(
          child: SizedBox(height: gap > 0 ? gap : 0),
        );
      },
    );
  }


  Future<void> _showTemplateActions(BuildContext context, TemplateUI template) async {
    final customCategories = ref.read(customCategoriesProvider);
    final categoryName = CategoryUtils.getCategoryName(
      categoryId: template.categoryId,
      context: context,
      customCategories: customCategories,
      fallbackTitle: template.title,
    );
    final parentId = template.categoryId?.split('_').take(2).join('_');
    final parentName = parentId != null
        ? CategoryUtils.getCategoryName(
            categoryId: parentId,
            context: context,
            customCategories: customCategories,
          )
        : null;
    final categoryAccentColor = AppColors.getAccentDeep(context, template.color);
    
    final Widget sheetTitle = parentName != null && parentName != categoryName
        ? Text.rich(
            TextSpan(
              children: [
                TextSpan(text: parentName),
                TextSpan(
                  text: ' / ',
                  style: TextStyle(
                    color: AppColors.getTextSecondary(context).withValues(alpha: 0.5),
                  ),
                ),
                TextSpan(
                  text: categoryName,
                  style: TextStyle(
                    color: categoryAccentColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppColors.getTextPrimary(context),
              letterSpacing: -0.8,
            ),
          )
        : Text(
            categoryName,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppColors.getTextPrimary(context),
              letterSpacing: -0.8,
            ),
          );

    final action = await CustomBottomSheet.show<DetailSheetAction>(
      context: context,
      title: sheetTitle,
      child: DetailSheet(
        isTemplateMode: true,
        transaction: TransactionUI(
          id: 'db_${template.id}',
          name: template.title,
          icon: template.icon,
          color: template.color,
          amount: template.amount,
          minAmount: template.minAmount,
          maxAmount: template.maxAmount,
          isIncome: template.isIncome,
          date: template.startDate,
          dbId: template.id,
          categoryId: template.categoryId,
          iconCode: template.iconCode,
          note: template.note,
          currency: template.currency,
          status: TransactionStatus.confirmed,
          isReviewed: true,
          templateId: template.id,
          occurrenceDate: template.startDate,
          installmentNumber: null,
          totalInstallments: template.totalInstallments,
          isArchived: template.isArchived,
          groupIds: [if (template.vaultId != null) 'v_${template.vaultId}'],
        ),
      ),
    );

    if (!context.mounted) return;

    if (action == DetailSheetAction.edit) {
      Navigator.push(
        context,
        SlideUpPageRoute(
          child: TransactionBuilderScreen(
            initialId: template.id,
            initialName: template.title,
            initialAmount: template.amount,
            initialMinAmount: template.minAmount,
            initialMaxAmount: template.maxAmount,
            initialIsIncome: template.isIncome,
            initialVaultId: template.vaultId,
            initialCategoryId: template.categoryId,
            initialNote: template.note,
            initialCurrency: template.currency,
            initialPeriodType: template.periodType,
            initialRecurrenceDay: template.recurrenceDay,
            initialRecurrenceDate: template.recurrenceDate ?? template.startDate,
            initialIsNotificationEnabled: template.isNotificationEnabled,
            initialNotificationReminderDays: template.notificationReminderDays,
            initialNotificationHour: template.notificationHour,
            initialNotificationMinute: template.notificationMinute,
            initialTotalInstallments: template.totalInstallments,
            isTemplateEdit: true,
          ),
          fullscreenDialog: true,
        ),
      );
    } else if (action == DetailSheetAction.delete) {
      final confirm = await showCustomDialog<bool>(
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
      if (confirm == true && context.mounted) {
        await DatabaseService.deleteTemplate(template.id);
        HapticFeedback.mediumImpact();
      }
    }
  }

  Future<void> _showTransactionActions(BuildContext context, TransactionUI tx) async {
    if (tx.dbId == null) return;
    
    final customCategories = ref.read(customCategoriesProvider);
    final categoryName = CategoryUtils.getCategoryName(
      categoryId: tx.categoryId,
      context: context,
      customCategories: customCategories,
      fallbackTitle: tx.name,
    );
    final parentId = tx.categoryId?.split('_').take(2).join('_');
    final parentName = parentId != null
        ? CategoryUtils.getCategoryName(
            categoryId: parentId,
            context: context,
            customCategories: customCategories,
          )
        : null;
    final categoryAccentColor = AppColors.getAccentDeep(context, tx.color);
    
    final Widget sheetTitle = parentName != null && parentName != categoryName
        ? Text.rich(
            TextSpan(
              children: [
                TextSpan(text: parentName),
                TextSpan(
                  text: ' / ',
                  style: TextStyle(
                    color: AppColors.getTextSecondary(context).withValues(alpha: 0.5),
                  ),
                ),
                TextSpan(
                  text: categoryName,
                  style: TextStyle(
                    color: categoryAccentColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppColors.getTextPrimary(context),
              letterSpacing: -0.8,
            ),
          )
        : Text(
            categoryName,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppColors.getTextPrimary(context),
              letterSpacing: -0.8,
            ),
          );

    final action = await CustomBottomSheet.show<DetailSheetAction>(
      context: context,
      title: sheetTitle,
      child: DetailSheet(
        transaction: tx,
      ),
    );

    if (!context.mounted) return;

    if (action == DetailSheetAction.edit) {
      final selectedVaultId = ref.read(selectedVaultProvider);
      final groups = ref.read(transactionGroupsProvider);
      final effectiveVaultId = selectedVaultId ?? (groups.isNotEmpty ? groups.first.id : null);
      int? currentVaultId = tx.groupIds.isNotEmpty
          ? int.tryParse(tx.groupIds.first.replaceFirst('v_', ''))
          : null;
      
      if (currentVaultId == null && effectiveVaultId != null) {
        currentVaultId = int.tryParse(effectiveVaultId.replaceFirst('v_', ''));
      }

      Navigator.push(
        context,
        SlideUpPageRoute(
          child: TransactionBuilderScreen(
            initialId: tx.dbId,
            initialName: tx.name,
            initialAmount: tx.amount,
            initialMinAmount: tx.minAmount,
            initialMaxAmount: tx.maxAmount,
            initialIsIncome: tx.isIncome,
            initialVaultId: currentVaultId,
            initialCategoryId: tx.categoryId,
            initialNote: tx.note,
            initialCurrency: tx.currency,
            initialPeriodType: 0,
            initialRecurrenceDate: tx.date,
            isTemplateEdit: false,
          ),
          fullscreenDialog: true,
        ),
      );
    } else if (action == DetailSheetAction.delete) {
      final confirm = await showCustomDialog<bool>(
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
      if (confirm == true && context.mounted) {
        await DatabaseService.deleteTransaction(tx.dbId!);
        HapticFeedback.mediumImpact();
      }
    }
  }

  void _showAddVaultSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    HapticFeedback.heavyImpact();

    final vaults = ref.read(vaultsStreamProvider).valueOrNull ?? [];
    final subService = ref.read(subscriptionServiceProvider);
    
    if (!subService.isPro && vaults.length >= subService.maxVaults) {
      showCustomDialog(
        context: context,
        accentColor: const Color(0xFFFFB300),
        title: l10n.premiumRequired,
        content: l10n.vaultLimitReachedDesc(subService.maxVaults),
        actions: [
          PrecisionDialogAction(
            label: l10n.later,
            onTap: () => Navigator.pop(context),
            isPrimary: false,
          ),
          PrecisionDialogAction(
            label: l10n.upgradeToPro,
            onTap: () {
              Navigator.pop(context);
              ProUpgradeSheet.show(context);
            },
            isPrimary: true,
          ),
        ],
      );
      return;
    }

    CustomBottomSheet.show(
      context: context,
      title: AppLocalizations.of(context)!.addNewVault,
      child: const AddVaultSheet(),
    );
  }

  void _showVaultDetail(BuildContext context, String? vaultId) {
    HapticFeedback.mediumImpact();
    CustomBottomSheet.show(
      context: context,
      title: AppLocalizations.of(context)!.vaultDetail,
      child: VaultDetailSheet(vaultId: vaultId),
    );
  }

  void _showNotificationsSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    HapticFeedback.heavyImpact();
    CustomBottomSheet.show(
      context: context,
      title: l10n.inAppNotifications,
      child: const InAppNotificationsSheet(),
    );
  }
}
