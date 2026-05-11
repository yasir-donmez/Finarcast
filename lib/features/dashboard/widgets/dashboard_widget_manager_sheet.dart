import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_constants.dart';
import '../../../shared/widgets/precision_segmented_control.dart';
import '../../../shared/widgets/precision_card.dart';
import '../../../shared/widgets/precision_selector_field.dart';
import '../../../shared/widgets/precision_multi_toggle.dart';
import '../../../shared/widgets/precision_button.dart';
import '../../../shared/widgets/precision_icon_button.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/widget_layout_provider.dart';
import 'dashboard_widget.dart'; // for DashboardWidgetSize
import '../../../shared/widgets/precision_notification.dart';

enum WidgetManagerTab { active, library }

class DashboardWidgetManagerSheet extends ConsumerStatefulWidget {
  const DashboardWidgetManagerSheet({super.key});

  @override
  ConsumerState<DashboardWidgetManagerSheet> createState() => _DashboardWidgetManagerSheetState();
}

class _DashboardWidgetManagerSheetState extends ConsumerState<DashboardWidgetManagerSheet> {
  WidgetManagerTab _activeTab = WidgetManagerTab.active;

  void _switchTab(WidgetManagerTab tab) {
    if (_activeTab == tab) return;
    HapticFeedback.mediumImpact();
    setState(() => _activeTab = tab);
  }

  List<Map<String, dynamic>> _getLibrary(AppLocalizations l10n) => [
    {'type': 'timeline', 'name': l10n.historyTitle, 'icon': Icons.history_rounded, 'defaultSize': DashboardWidgetSize.large},
    {'type': 'radar', 'name': l10n.radarTitle, 'icon': Icons.radar_rounded, 'defaultSize': DashboardWidgetSize.large},
    {'type': 'spending', 'name': l10n.giantsTitle, 'icon': Icons.bar_chart_rounded, 'defaultSize': DashboardWidgetSize.large},
    {'type': 'quick_action', 'name': l10n.quickActionTitle, 'icon': Icons.flash_on_rounded, 'defaultSize': DashboardWidgetSize.small},
    {'type': 'vault_status', 'name': l10n.vaultStatusTitle, 'icon': Icons.account_balance_wallet_rounded, 'defaultSize': DashboardWidgetSize.small},
    {'type': 'daily_budget', 'name': l10n.dailyBudgetTitle, 'icon': Icons.attach_money_rounded, 'defaultSize': DashboardWidgetSize.wide},
  ];

  String _getWidgetName(String type, AppLocalizations l10n) {
    return _getLibrary(l10n).firstWhere((w) => w['type'] == type, orElse: () => {'name': type})['name'] as String;
  }

  IconData _getWidgetIcon(String type, AppLocalizations l10n) {
    return _getLibrary(l10n).firstWhere((w) => w['type'] == type, orElse: () => {'icon': Icons.widgets_rounded})['icon'] as IconData;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pages = ref.watch(widgetLayoutProvider);
    final activeColor = AppColors.getPrimary(context);
    final scalingFactor = (MediaQuery.of(context).size.height / 812.0).clamp(0.85, 1.0);

    return AnimatedSize(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutSine, // Daha yumuşak ve performanslı bir eğri
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: PrecisionSegmentedControl(
              tabs: [l10n.dashboard, l10n.library],
              selectedIndex: _activeTab == WidgetManagerTab.active ? 0 : 1,
              onTabChanged: (index) => _switchTab(index == 0 ? WidgetManagerTab.active : WidgetManagerTab.library),
              scalingFactor: scalingFactor,
            ),
          ),
          const SizedBox(height: 12),
          RepaintBoundary(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _activeTab == WidgetManagerTab.active 
                  ? _buildActiveWidgetsList(context, pages, activeColor, scalingFactor, l10n)
                  : _buildLibraryList(context, pages, activeColor, scalingFactor, l10n),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveWidgetsList(BuildContext context, List<List<WidgetConfig>> pages, Color activeColor, double scalingFactor, AppLocalizations l10n) {
    final List<Map<String, dynamic>> flatList = [];
    for (int i = 0; i < pages.length; i++) {
      for (var widget in pages[i]) {
        flatList.add({'page': i, 'widget': widget});
      }
    }

    return Column(
      key: const ValueKey('active_widgets'),
      mainAxisSize: MainAxisSize.min,
      children: [
        if (flatList.isNotEmpty)
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.55 * scalingFactor),
            child: ReorderableListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8 * scalingFactor),
              physics: const BouncingScrollPhysics(),
              proxyDecorator: (child, index, animation) {
                return AnimatedBuilder(
                  animation: animation,
                  builder: (context, _) {
                    final double animValue = Curves.easeInOut.transform(animation.value);
                    final double elevation = lerpDouble(0, 12, animValue)!;
                    final double scale = lerpDouble(1.0, 1.02, animValue)!; // Hafif büyüme
                    
                    return Transform.scale(
                      scale: scale,
                      child: Material(
                        color: Colors.transparent,
                        elevation: elevation,
                        shadowColor: Colors.black45,
                        borderRadius: BorderRadius.circular(16 * scalingFactor),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16 * scalingFactor),
                            boxShadow: [
                              BoxShadow(
                                color: (Theme.of(context).primaryColor).withValues(alpha: 0.15 * animValue),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: child,
                        ),
                      ),
                    );
                  },
                );
              },
              itemCount: flatList.length,
              onReorder: (oldIndex, newIndex) {
                if (newIndex > oldIndex) newIndex -= 1;
                final item = flatList[oldIndex];
                final targetItem = flatList[newIndex];
                // Sürükle bırak ile sayfa numarasını da güncelleyebiliriz
                ref.read(widgetLayoutProvider.notifier).changeWidgetPage(
                  (item['widget'] as WidgetConfig).id, 
                  (targetItem['widget'] as WidgetConfig).page,
                );
              },
              itemBuilder: (context, index) {
                final item = flatList[index];
                final widget = item['widget'] as WidgetConfig;
                return Container(
                  key: ValueKey('active_${widget.id}'), // Sabit anahtar animasyon için kritik
                  margin: EdgeInsets.only(bottom: 10 * scalingFactor),
                  child: _buildActiveItem(context, widget, item['page'] as int, activeColor, scalingFactor, pages.length, index, l10n),
                );
              },
            ),
          )
        else
          _buildEmptyState(l10n.dashboardEmpty, Icons.dashboard_customize_rounded, activeColor, scalingFactor),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildLibraryList(BuildContext context, List<List<WidgetConfig>> pages, Color activeColor, double scalingFactor, AppLocalizations l10n) {
    final library = _getLibrary(l10n);
    return Column(
      key: const ValueKey('library_widgets'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (library.isNotEmpty)
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.55 * scalingFactor),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8 * scalingFactor),
              physics: const BouncingScrollPhysics(),
              itemCount: library.length,
              separatorBuilder: (_, __) => SizedBox(height: 10 * scalingFactor),
              itemBuilder: (context, index) {
                final libItem = library[index];
                return _buildLibraryItem(context, libItem, activeColor, scalingFactor, index, l10n);
              },
            ),
          )
        else
          _buildEmptyState(l10n.libraryEmpty, Icons.check_circle_outline_rounded, activeColor, scalingFactor),
        const SizedBox(height: 12),
      ],
    );
  }

  List<DashboardWidgetSize> _getAllowedSizes(String type) {
    switch (type) {
      case 'quick_action': return [DashboardWidgetSize.small];
      case 'timeline':
      case 'radar': return [DashboardWidgetSize.wide, DashboardWidgetSize.large];
      case 'daily_budget': return [DashboardWidgetSize.small, DashboardWidgetSize.wide];
      case 'spending':
      case 'vault_status':
      default: return [DashboardWidgetSize.small, DashboardWidgetSize.wide, DashboardWidgetSize.large];
    }
  }

  Widget _buildActiveItem(BuildContext context, WidgetConfig widget, int pageIndex, Color activeColor, double scalingFactor, int totalPages, int index, AppLocalizations l10n) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final allowedSizes = _getAllowedSizes(widget.type);
    
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300), // Sabit ve hızlı giriş
      curve: Curves.easeOutSine,
      tween: Tween(begin: 0.98, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(opacity: value.clamp(0, 1), child: child),
        );
      },
      child: PrecisionCard(
        scalingFactor: scalingFactor,
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  _getWidgetIcon(widget.type, l10n),
                  color: activeColor,
                  size: 20 * scalingFactor,
                ),
                SizedBox(width: 12 * scalingFactor),
                Expanded(
                  child: Text(
                    _getWidgetName(widget.type, l10n),
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15 * scalingFactor,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                PrecisionIconButton(
                  icon: Icons.remove_circle_outline_rounded,
                  color: AppColors.error,
                  size: 20 * scalingFactor,
                  padding: 8 * scalingFactor,
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    ref.read(widgetLayoutProvider.notifier).removeWidget(widget.id);
                  },
                ),
                SizedBox(width: 4 * scalingFactor),
                // Sürükleme Tutamacı İkonu (Statik, arka plansız)
                Icon(
                  Icons.unfold_more_rounded,
                  color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.3),
                  size: 22 * scalingFactor,
                ),
              ],
            ),
            PrecisionSelectorField(
              icon: Icons.dashboard_rounded,
              label: l10n.pageLabel,
              pickerWidth: 160,
              items: const ['1', '2', '3', '4'],
              selectedIndex: pageIndex.clamp(0, 3),
              scalingFactor: scalingFactor,
              onChanged: (newIdx) {
                ref.read(widgetLayoutProvider.notifier).changeWidgetPage(widget.id, newIdx);
              },
            ),
            Divider(height: 1, thickness: 0.5, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black).withValues(alpha: 0.08)),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 4 * scalingFactor),
              child: Row(
                children: [
                  Icon(
                    Icons.aspect_ratio_rounded,
                    size: 18 * scalingFactor,
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                  ),
                  SizedBox(width: 12 * scalingFactor),
                  Expanded(
                    child: Text(
                      l10n.sizeLabel,
                      style: TextStyle(
                        fontSize: 11 * scalingFactor,
                        fontWeight: FontWeight.w900,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  PrecisionMultiToggle(
                    labels: allowedSizes.map((s) => s == DashboardWidgetSize.small ? 'S' : s == DashboardWidgetSize.wide ? 'W' : 'L').toList(),
                    selectedIndex: allowedSizes.indexOf(widget.size).clamp(0, allowedSizes.length - 1),
                    activeColors: List.generate(allowedSizes.length, (_) => Theme.of(context).colorScheme.primary),
                    scalingFactor: scalingFactor,
                    onChanged: (index) {
                      HapticFeedback.mediumImpact();
                      ref.read(widgetLayoutProvider.notifier).setWidgetSizeById(widget.id, allowedSizes[index]);
                    },
                  ),
                ],
              ),
            ),
            Divider(height: 1, thickness: 0.5, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black).withValues(alpha: 0.08)),
          ],
        ),
      ),
    );
  }

  Widget _buildLibraryItem(BuildContext context, Map<String, dynamic> libItem, Color activeColor, double scalingFactor, int index, AppLocalizations l10n) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutSine,
      tween: Tween(begin: 0.98, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(opacity: value.clamp(0, 1), child: child),
        );
      },
      child: PrecisionCard(
        scalingFactor: scalingFactor,
        child: Row(
          children: [
            Icon(
              libItem['icon'] as IconData,
              color: activeColor,
              size: 20 * scalingFactor,
            ),
            SizedBox(width: 12 * scalingFactor),
            Expanded(
              child: Text(
                libItem['name'] as String,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15 * scalingFactor,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            PrecisionButton(
              label: l10n.addNewVault.split(' ').last, // Use 'Add' or similar
              onTap: () {
                HapticFeedback.heavyImpact();
                ref.read(widgetLayoutProvider.notifier).addWidget(
                  libItem['type'] as String,
                  libItem['defaultSize'] as DashboardWidgetSize,
                );
                
                PrecisionNotification.success(
                  context,
                  l10n.widgetAdded(libItem['name'] as String),
                );
              },
              activeColor: activeColor,
              width: 80 * scalingFactor,
              height: 34 * scalingFactor,
              fontSize: 12 * scalingFactor,
              isFilled: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon, Color color, double scalingFactor) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 60 * scalingFactor),
      child: Opacity(
        opacity: 0.5,
        child: Column(
          children: [
            Icon(icon, size: 48 * scalingFactor, color: color),
            SizedBox(height: 12 * scalingFactor),
            Text(message, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13 * scalingFactor)),
          ],
        ),
      ),
    );
  }
}
