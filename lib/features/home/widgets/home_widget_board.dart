import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/home_widget_layout_provider.dart';
import 'home_widget.dart';
import 'timeline_activity_widget.dart';
import 'due_date_radar_widget.dart';
import 'spending_giants_widget.dart';
import 'quick_action_widget.dart';
import 'daily_budget_widget.dart';
import 'vault_status_widget.dart';
import 'home_widget_manager_sheet.dart';
import '../../../shared/widgets/custom_bottom_sheet.dart';
import '../../../l10n/app_localizations.dart';

class HomeWidgetBoard extends ConsumerStatefulWidget {
  const HomeWidgetBoard({super.key});

  @override
  ConsumerState<HomeWidgetBoard> createState() => _HomeWidgetBoardState();
}

class _HomeWidgetBoardState extends ConsumerState<HomeWidgetBoard> {
  final PageController _pageController = PageController(viewportFraction: 1.0);
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allPages = ref.watch(widgetLayoutProvider);
    // Boş olmayan sayfaları filtrele, eğer hiç dolu sayfa yoksa en az bir boş sayfa göster
    final pages = allPages.where((p) => p.isNotEmpty).toList();
    if (pages.isEmpty) pages.add([]);

    return LayoutBuilder(
      builder: (context, constraints) {
        final boardWidth = constraints.maxWidth;
        // PageView tam ekran çalışacak, bu yüzden sayfa genişliği ekran genişliğine eşit.
        final actualPageWidth = boardWidth;
        // Sayfalar birbirine yapışmasın diye her sayfanın sağına ve soluna 8px padding vereceğiz. (Toplam 16px)
        final contentWidth = actualPageWidth - 16; 
        final contentHeight = contentWidth * 0.70;
        final pageViewHeight = contentHeight + 8;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: pageViewHeight, 
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                physics: const BouncingScrollPhysics(),
                itemCount: pages.length,
                itemBuilder: (context, index) {
                  return _buildWidgetPage(pages[index], contentWidth, contentHeight);
                },
              ),
            ),
            
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(pages.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 16 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: Theme.of(context).colorScheme.primary.withValues(
                      alpha: _currentPage == index ? 0.8 : 0.2,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 10),
          ],
        );
      },
    );
  }

  Widget _buildWidgetPage(List<WidgetConfig> configs, double fullWidth, double fullHeight) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Center(
        child: SizedBox(
          width: fullWidth,
          height: fullHeight,
          child: Wrap(
            spacing: 12, 
            runSpacing: 12, 
            children: configs.map((config) {
              return StaticGridItem(
                config: config,
                fullWidth: fullWidth,
                fullHeight: fullHeight,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class StaticGridItem extends StatelessWidget {
  final WidgetConfig config;
  final double fullWidth;
  final double fullHeight;

  const StaticGridItem({
    super.key,
    required this.config,
    required this.fullWidth,
    required this.fullHeight,
  });

  Widget _getWidgetByType(String type, HomeWidgetSize size, String? selectedVaultId) {
    switch (type) {
      case 'timeline': return TimelineActivityWidget(size: size, selectedVaultId: selectedVaultId);
      case 'radar': return DueDateRadarWidget(size: size, selectedVaultId: selectedVaultId);
      case 'spending': return SpendingGiantsWidget(size: size, selectedVaultId: selectedVaultId);
      case 'quick_action': return const QuickActionWidget();
      case 'daily_budget': return const DailyBudgetWidget();
      case 'vault_status': return const VaultStatusWidget();
      default: return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacing = 12.0;
    
    final halfWidth = (fullWidth - spacing) / 2;
    final halfHeight = (fullHeight - spacing) / 2;

    double actualWidth = 0.0;
    double actualHeight = 0.0;
    switch (config.size) {
      case HomeWidgetSize.small: actualWidth = halfWidth; actualHeight = halfHeight; break;
      case HomeWidgetSize.wide: actualWidth = fullWidth; actualHeight = halfHeight; break;
      case HomeWidgetSize.large: actualWidth = fullWidth; actualHeight = fullHeight; break;
    }

    return SizedBox(
      width: actualWidth,
      height: actualHeight,
      child: HomeWidget(
        size: config.size,
        isEditing: false,
        onLongPress: () {
          final l10n = AppLocalizations.of(context)!;
          CustomBottomSheet.show(
            context: context,
            title: l10n.home,
            child: const HomeWidgetManagerSheet(),
          );
        },
        child: _getWidgetByType(config.type, config.size, config.selectedVaultId),
      ),
    );
  }
}


