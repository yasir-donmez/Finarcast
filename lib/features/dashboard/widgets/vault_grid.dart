import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/app_constants.dart';
import '../dashboard_providers.dart';
import '../../../shared/widgets/solid_surface.dart';
import '../../../shared/widgets/custom_bottom_sheet.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../core/utils/category_utils.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/database/database_service.dart';
import '../../../core/providers/db_providers.dart';

class VaultGrid extends ConsumerStatefulWidget {
  final List<DashboardItem> items;

  const VaultGrid({super.key, required this.items});

  @override
  ConsumerState<VaultGrid> createState() =>
      _PrecisionVaultGridState();
}

class _PrecisionVaultGridState extends ConsumerState<VaultGrid> {
  final Set<int> _selectedIndices =
      {}; // Sayfa başı veya satır başı bağımsız detay durumu
  late PageController _pageController;
  int _currentPage = 0;

  bool _isExpanded(int index, int layoutType, int startIndex) {
    if (layoutType == 1) return true;
    if (layoutType == 2) return true;
    if (layoutType == 3) {
      if (index == startIndex) return true;
      return _selectedIndices.contains(index);
    }
    return _selectedIndices.contains(index);
  }

  bool _isShrunk(int index, int layoutType, int startIndex) {
    if (layoutType <= 2) return false;
    if (layoutType == 3) {
      if (index == startIndex) return false;
      int otherIdx = (index == startIndex + 1)
          ? startIndex + 2
          : startIndex + 1;
      return _selectedIndices.contains(otherIdx);
    }
    if (layoutType == 4) {
      int localIdx = index - startIndex;
      int otherIdx = (localIdx % 2 == 0) ? index + 1 : index - 1;
      return _selectedIndices.contains(otherIdx);
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double parentWidth = constraints.maxWidth;
        final count = widget.items.length;

        if (count == 0) return const SizedBox.shrink();
        return _buildPaginatedLayout(parentWidth);
      },
    );
  }

  // CASE 1: Tek Kasa
  Widget _buildLayoutFor1(
    List<DashboardItem> items,
    double width,
    int startIndex,
  ) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Consistent min size
        mainAxisAlignment: MainAxisAlignment.start, // Üste yasla
        children: [
          const SizedBox(height: 10), // Üstten hafif pay
          _buildVaultCardWrapper(
            item: items[0],
            index: startIndex,
            pageStartIndex: startIndex,
            layoutType: 1,
            width: (width - (AppSizes.paddingMedium * 2)).clamp(0.0, double.infinity),
            height: 224,
            isExpanded: true,
            isShrunk: false,
          ),
        ],
      ),
    );
  }

  // CASE 2: İki Kasa - İkisi de Açık
  Widget _buildLayoutFor2(
    List<DashboardItem> items,
    double width,
    int startIndex,
  ) {
    if (items.isEmpty) return const SizedBox.shrink();
    final double cardWidth = (width - (AppSizes.paddingMedium * 2)).clamp(0.0, double.infinity);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start, // Üste yasla
        children: [
          const SizedBox(height: 10),
          _buildVaultCardWrapper(
            item: items[0],
            index: startIndex,
            pageStartIndex: startIndex,
            layoutType: 2,
            width: cardWidth,
            height: 108,
            isExpanded: true,
            isShrunk: false,
          ),
          if (items.length > 1) ...[
            const SizedBox(height: 8),
            _buildVaultCardWrapper(
              item: items[1],
              index: startIndex + 1,
              pageStartIndex: startIndex,
              layoutType: 2,
              width: cardWidth,
              height: 108,
              isExpanded: true,
              isShrunk: false,
            ),
          ],
        ],
      ),
    );
  }

  // CASE 3: Üç Kasa - Biri Büyük, İkisi Küçük (Yalnızca Dikey Büyüme)
  Widget _buildLayoutFor3(
    List<DashboardItem> items,
    double width,
    int startIndex,
  ) {
    if (items.isEmpty) return const SizedBox.shrink();

    final int totalInPage = items.length;
    final double availableWidth = (width - (AppSizes.paddingMedium * 3)).clamp(0.0, double.infinity);
    final leftWidth = availableWidth * 0.55;
    final rightWidth = availableWidth * 0.45;

    final rightH1 = totalInPage > 1
        ? (_isExpanded(startIndex + 1, 3, startIndex)
              ? 160.0
              : (_isShrunk(startIndex + 1, 3, startIndex) ? 60.0 : 108.0))
        : 108.0;
    final rightH2 = totalInPage > 2
        ? (_isExpanded(startIndex + 2, 3, startIndex)
              ? 160.0
              : (_isShrunk(startIndex + 2, 3, startIndex) ? 60.0 : 108.0))
        : 108.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 10), // Consistent top padding
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildVaultCardWrapper(
                item: items[0],
                index: startIndex,
                pageStartIndex: startIndex,
                layoutType: 3,
                width: leftWidth,
                height: 224,
                isExpanded: true,
                isShrunk: false,
              ),
              if (totalInPage > 1)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildVaultCardWrapper(
                      item: items[1],
                      index: startIndex + 1,
                      pageStartIndex: startIndex,
                      layoutType: 3,
                      width: rightWidth,
                      height: rightH1,
                      isExpanded: _isExpanded(startIndex + 1, 3, startIndex),
                      isShrunk: _isShrunk(startIndex + 1, 3, startIndex),
                    ),
                    if (totalInPage > 2) ...[
                      const SizedBox(height: 8),
                      _buildVaultCardWrapper(
                        item: items[2],
                        index: startIndex + 2,
                        pageStartIndex: startIndex,
                        layoutType: 3,
                        width: rightWidth,
                        height: rightH2,
                        isExpanded: _isExpanded(startIndex + 2, 3, startIndex),
                        isShrunk: _isShrunk(startIndex + 2, 3, startIndex),
                      ),
                    ],
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  // CASE 4: Dört Kasa - Satır İçi Bağımsız Genişleme
  Widget _buildLayoutFor4(
    List<DashboardItem> items,
    double width,
    int startIndex,
  ) {
    if (items.isEmpty) return const SizedBox.shrink();

    final double availableWidth = (width - (AppSizes.paddingMedium * 3)).clamp(0.0, double.infinity);

    double getW(int idx) {
      if (_isExpanded(idx, 4, startIndex)) return availableWidth * 0.75;
      if (_isShrunk(idx, 4, startIndex)) return availableWidth * 0.25;
      return availableWidth * 0.5;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start, // Üste yasla
        children: [
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildVaultCardWrapper(
                item: items[0],
                index: startIndex,
                pageStartIndex: startIndex,
                layoutType: 4,
                width: getW(startIndex),
                height: 108,
                isExpanded: _isExpanded(startIndex, 4, startIndex),
                isShrunk: _isShrunk(startIndex, 4, startIndex),
              ),
              if (items.length > 1)
                _buildVaultCardWrapper(
                  item: items[1],
                  index: startIndex + 1,
                  pageStartIndex: startIndex,
                  layoutType: 4,
                  width: getW(startIndex + 1),
                  height: 108,
                  isExpanded: _isExpanded(startIndex + 1, 4, startIndex),
                  isShrunk: _isShrunk(startIndex + 1, 4, startIndex),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (items.length > 2)
                _buildVaultCardWrapper(
                  item: items[2],
                  index: startIndex + 2,
                  pageStartIndex: startIndex,
                  layoutType: 4,
                  width: getW(startIndex + 2),
                  height: 108,
                  isExpanded: _isExpanded(startIndex + 2, 4, startIndex),
                  isShrunk: _isShrunk(startIndex + 2, 4, startIndex),
                ),
              if (items.length > 3)
                _buildVaultCardWrapper(
                  item: items[3],
                  index: startIndex + 3,
                  pageStartIndex: startIndex,
                  layoutType: 4,
                  width: getW(startIndex + 3),
                  height: 108,
                  isExpanded: _isExpanded(startIndex + 3, 4, startIndex),
                  isShrunk: _isShrunk(startIndex + 3, 4, startIndex),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // CASE 5+: Sayfalı Düzen (Dinamik Gruplar)
  Widget _buildPaginatedLayout(double width) {
    List<List<DashboardItem>> pages = [];
    List<int> pageStartIndices = [];
    int i = 0;
    while (i < widget.items.length) {
      pageStartIndices.add(i);
      int layoutCount = widget.items[i].dashboardLayoutType;
      if (layoutCount < 1) layoutCount = 4;
      if (layoutCount > 4) layoutCount = 4;

      List<DashboardItem> pageItems = [];
      for (int j = 0; j < layoutCount; j++) {
        if (i + j < widget.items.length) {
          pageItems.add(widget.items[i + j]);
        } else {
          break;
        }
      }

      pages.add(pageItems);
      i += pageItems.length;
    }

    final int pageCount = pages.length;
    if (_currentPage >= pageCount && pageCount > 0) {
      _currentPage = pageCount - 1;
    }

    return Column(
      children: [
        // SADECE Sayfa içeriği sönümlenir (ShaderMask)
        Expanded(
          child: ShaderMask(
            shaderCallback: (rect) {
              return LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black, Colors.black, Colors.transparent],
                stops: const [0.0, 0.95, 1.0],
              ).createShader(rect);
            },
            blendMode: BlendMode.dstIn,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (idx) => setState(() => _currentPage = idx),
              itemCount: pageCount,
              itemBuilder: (context, pageIdx) {
                if (pageIdx >= pages.length) return const SizedBox.shrink();

                final pageItems = pages[pageIdx];
                final startIndex = pageStartIndices[pageIdx];
                final int layoutType = pageItems.length;
                
                return AnimatedSwitcher(
                  key: ValueKey('page_$pageIdx'),
                  duration: const Duration(milliseconds: 500),
                  layoutBuilder:
                      (Widget? currentChild, List<Widget> previousChildren) {
                    return Stack(
                      alignment: Alignment.topCenter,
                      children: <Widget>[
                        ...previousChildren,
                        if (currentChild != null) currentChild,
                      ],
                    );
                  },
                  child: switch (layoutType) {
                    1 => _buildLayoutFor1(pageItems, width, startIndex),
                    2 => _buildLayoutFor2(pageItems, width, startIndex),
                    3 => _buildLayoutFor3(pageItems, width, startIndex),
                    _ => _buildLayoutFor4(pageItems, width, startIndex),
                  },
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 4), // Boşluğu azalttık
        // Dots - Maskelenmez, pırıl pırıl cam gibi durur
        if (pageCount > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(pageCount, (idx) {
              final activeColor = AppColors.getAccentDeep(context, ref.watch(rotaryColorProvider));
              return AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOutCubic,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == idx ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == idx
                      ? activeColor
                      : activeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: _currentPage == idx ? [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      spreadRadius: 0,
                    )
                  ] : [],
                ),
              );
            }),
          ),
      ],
    );
  }

  // Kart Sarmalayıcı Yardımcı Method
  Widget _buildVaultCardWrapper({
    required DashboardItem item,
    required int index,
    required int pageStartIndex,
    required int layoutType,
    required double width,
    required double height,
    required bool isExpanded,
    bool isShrunk = false,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          if (layoutType == 4) {
            int localIdx = index - pageStartIndex;
            int otherIdxInRow = (localIdx % 2 == 0) ? index + 1 : index - 1;
            _selectedIndices.remove(otherIdxInRow);
          } else if (layoutType == 3) {
            if (index == pageStartIndex + 1) {
              _selectedIndices.remove(pageStartIndex + 2);
            }
            if (index == pageStartIndex + 2) {
              _selectedIndices.remove(pageStartIndex + 1);
            }
          }

          if (_selectedIndices.contains(index)) {
            _selectedIndices.remove(index);
          } else {
            _selectedIndices.add(index);
          }
        });
      },
      onLongPress: () => _showLayoutSettings(item),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutQuart,
        clipBehavior: Clip.antiAlias, // Sıvı ve kusursuz geçişler için kritik
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge * 1.2),
        ),
        child: SolidSurface(
          padding: EdgeInsets.zero,
          borderRadius: AppSizes.radiusLarge * 1.2,
          child: _buildVaultCard(item, isExpanded, isShrunk, width, height),
        ),
      ),
    );
  }

  IconData _getIconData(String code) {
    final customCategories = ref.watch(customCategoriesProvider);
    return CategoryUtils.getCategoryIcon(
      categoryId: code,
      customCategories: customCategories,
      iconCode: code,
    );
  }

  IconData _getIconForItem(DashboardItem item) {
    final customCategories = ref.watch(customCategoriesProvider);
    return CategoryUtils.getCategoryIcon(
      categoryId: item.categoryId,
      customCategories: customCategories,
      iconCode: item.iconCode,
    );
  }

  Color _getColorForItem(DashboardItem item) {
    if (item.balance < 0) {
      return AppColors.getExpense(context);
    }
    final customCategories = ref.watch(customCategoriesProvider);
    return CategoryUtils.getCategoryColor(
      categoryId: item.categoryId,
      customCategories: customCategories,
    );
  }

  Widget _buildVaultCard(
    DashboardItem item,
    bool isExpanded,
    bool isShrunk,
    double width,
    double height,
  ) {
    final customCategories = ref.watch(customCategoriesProvider);
    final color = _getColorForItem(item);
    final icon = _getIconForItem(item);
    // Filigran için orijinal rengi alırken de ID öncelikli
    final originalColor = CategoryUtils.getCategoryColor(
      categoryId: item.categoryId,
      customCategories: customCategories,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.radiusDefault),
      child: Stack(
        children: [
          // Arka plan filigranı (soluk simge) - bakiyeden bağımsız renk
          Positioned(
            right: isShrunk ? -10 : -20,
            bottom: isShrunk ? -10 : -20,
            child: Icon(
              icon,
              size: isShrunk ? 70 : 120,
              color: originalColor.withValues(alpha: 0.10),
            ),
          ),

          // İçerik geçişi
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            layoutBuilder:
                (Widget? currentChild, List<Widget> previousChildren) {
                  final Set<Key> seenKeys = {};
                  if (currentChild?.key != null) seenKeys.add(currentChild!.key!);
                  return Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      ...previousChildren.where((child) => child.key == null || seenKeys.add(child.key!)),
                      if (currentChild != null) currentChild,
                    ],
                  );
                },
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: SizedBox(
              key: ValueKey('${item.id}_${isExpanded}_$isShrunk'),
              width: width,
              height: height,
              child: ClipRect(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 10.0,
                ),
                child: isExpanded
                    ? _buildExpandedContent(item, icon, color, width, height)
                    : isShrunk
                    ? _buildShrunkContent(item, icon, color, width, height)
                    : _buildNormalContent(item, icon, color, width, height),
              ),
            ),
            ),
          ),

          // Grup ise üstte geniş bir önizleme (Eğer çok dar değilse)
          if (item.isGroup && !isShrunk && !isExpanded)
            Positioned(
              top: 10,
              right: 12,
              child: _buildGroupPreview(item, color, isExpanded),
            ),
        ],
      ),
    );
  }

  Widget _buildGroupPreview(DashboardItem item, Color color, bool isExpanded) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.layers_rounded, size: 10, color: color),
          const SizedBox(width: 4),
          Text(
            '${item.itemCount}',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNormalContent(
    DashboardItem item,
    IconData icon,
    Color color,
    double width,
    double height,
  ) {
    String displayBalance = CurrencyUtils.formatAmount(item.balance.abs(), currencySymbol: item.currency);

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.topLeft,
      child: SizedBox(
        width: (width - 20.0).clamp(0.0, double.infinity),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      item.balance < 0
                          ? Icons.trending_down_rounded
                          : Icons.trending_up_rounded,
                      color: item.balance < 0
                          ? AppColors.getExpense(context)
                          : AppColors.getIncome(context),
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      displayBalance,
                      style: TextStyle(
                        color: item.balance < 0
                            ? AppColors.getExpense(context)
                            : AppColors.getTextPrimary(context),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  item.currency,
                  style: TextStyle(
                    color: color.withValues(alpha: 0.8),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
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

  Widget _buildShrunkContent(
    DashboardItem item,
    IconData icon,
    Color color,
    double width,
    double height,
  ) {
    return Center(child: Icon(icon, color: color, size: 22));
  }

  Widget _buildExpandedContent(
    DashboardItem item,
    IconData icon,
    Color color,
    double width,
    double height,
  ) {
    String displayBalance = CurrencyUtils.formatAmount(item.balance.abs(), currencySymbol: item.currency);

    final bool isFull = width > 300 && height > 200;
    final bool isWide = width > 300 && height < 150;
    final bool isTall = width < 200;

    Widget buildHeader() {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: (isTall || isWide) ? 12 : 14),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              item.name,
              style: TextStyle(
                color: AppColors.getTextSecondary(context),
                fontSize: (isTall || isWide) ? 10 : 11,
                fontWeight: FontWeight.bold,
              ),
              maxLines: (isFull || isTall) ? 2 : 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    Widget buildTransactionsGrid(int maxItems) {
      if (item.itemIconCodes.isEmpty) return const SizedBox.shrink();
      return Wrap(
        alignment: (isTall || isWide) ? WrapAlignment.start : WrapAlignment.end,
        spacing: 2,
        runSpacing: 2,
        children: List.generate(
          item.itemIconCodes.length > maxItems
              ? maxItems
              : item.itemIconCodes.length,
          (idx) {
            if (idx == maxItems - 1 && item.itemIconCodes.length > maxItems) {
              final int hiddenCount =
                  item.itemIconCodes.length - (maxItems - 1);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '+$hiddenCount',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    color: color.withValues(alpha: 0.9),
                  ),
                ),
              );
            }

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getIconData(item.itemIconCodes[idx]),
                    size: 8,
                    color: item.itemAmounts[idx] < 0
                        ? AppColors.getExpense(context).withValues(alpha: 0.8)
                        : AppColors.getIncome(context).withValues(alpha: 0.8),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    CurrencyUtils.formatAmount(item.itemAmounts[idx].abs(), currencySymbol: item.currency),
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: item.itemAmounts[idx] < 0
                          ? AppColors.getExpense(context)
                          : AppColors.getIncome(context),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }

    Widget buildBalanceInfo() {
      return FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Icon(
              item.balance < 0
                  ? Icons.trending_down_rounded
                  : Icons.trending_up_rounded,
              color: item.balance < 0
                  ? AppColors.getExpense(context)
                  : AppColors.getIncome(context),
              size: isFull ? 24 : 18,
            ),
            const SizedBox(width: 4),
            Text(
              displayBalance,
              style: TextStyle(
                color: item.balance < 0
                    ? AppColors.getExpense(context)
                    : AppColors.getIncome(context),
                fontSize: isFull ? 26 : 20,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              item.currency,
              style: TextStyle(
                color: color,
                fontSize: isFull ? 12 : 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    if (isWide) {
      return FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.center,
        child: SizedBox(
          width: (width - 20.0).clamp(0.0, double.infinity),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(flex: 3, child: buildHeader()),
              Expanded(flex: 4, child: Center(child: buildBalanceInfo())),
              Expanded(flex: 3, child: buildTransactionsGrid(4)),
            ],
          ),
        ),
      );
    }

    if (isTall) {
      return FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: (width - 20.0).clamp(0.0, double.infinity),
          height: (height - 20.0).clamp(0.0, double.infinity),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildHeader(),
              const SizedBox(height: 12),
              Expanded(child: SingleChildScrollView(child: buildTransactionsGrid(12))),
              const SizedBox(height: 8),
              buildBalanceInfo(),
            ],
          ),
        ),
      );
    }

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.topLeft,
      child: SizedBox(
        width: (width - 20.0).clamp(0.0, double.infinity),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: isFull ? 2 : 3, child: buildHeader()),
              Expanded(
                flex: isFull ? 3 : 2,
                child: buildTransactionsGrid(isFull ? 12 : 6),
              ),
            ],
          ),
          const SizedBox(height: 12),
          buildBalanceInfo(),
        ],
      ),
      ),
    );
  }

  void _showLayoutSettings(DashboardItem item) {
    final l10n = AppLocalizations.of(context)!;
    HapticFeedback.heavyImpact();
    CustomBottomSheet.show(
      context: context,
      title: l10n.layoutAndSorting,
      child: Column(
        mainAxisSize: MainAxisSize.min, // Sadece içerik kadar yer kaplamasını sağlar
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLayoutOption(item, 1, Icons.crop_square_rounded, l10n.layout1),
              _buildLayoutOption(item, 2, Icons.view_headline_rounded, l10n.layout2),
              _buildLayoutOption(item, 3, Icons.view_quilt_rounded, l10n.layout3),
              _buildLayoutOption(item, 4, Icons.view_module_rounded, l10n.layout4),
            ],
          ),
          const SizedBox(height: 32),
          CustomButton(
            isPrimary: false,
            onTap: () {
              Navigator.pop(context);
              _moveVault(item, -1);
            },
            leading: const Icon(Icons.arrow_upward_rounded, size: 18),
            label: l10n.moveForward,
          ),
          const SizedBox(height: 12),
          CustomButton(
            isPrimary: false,
            onTap: () {
              Navigator.pop(context);
              _moveVault(item, 1);
            },
            leading: const Icon(Icons.arrow_downward_rounded, size: 18),
            label: l10n.moveBackward,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildLayoutOption(
    DashboardItem item,
    int type,
    IconData icon,
    String label,
  ) {
    final bool isSelected = item.dashboardLayoutType == type;
    return GestureDetector(
      key: ValueKey('layout_option_${item.id}_$type'),
      onTap: () {
        Navigator.pop(context);
        _updateVaultLayout(item, type);
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.getPrimary(context).withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppColors.getPrimary(context)
                    : AppColors.getTextSecondary(context).withValues(alpha: 0.6), // Daha belirgin sınır (0.45 -> 0.6)
              ),
            ),
            child: Icon(
              icon,
              color: isSelected ? AppColors.getPrimary(context) : AppColors.getTextPrimary(context).withValues(alpha: 0.7), // Secondary -> Primary Text ve daha opak
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isSelected ? AppColors.getPrimary(context) : AppColors.getTextPrimary(context).withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateVaultLayout(DashboardItem item, int layoutType) async {
    final vaults = ref.read(allVaultsProvider);
    for (var v in vaults) {
      v.dashboardLayoutType = layoutType;
    }
    await DatabaseService.updateAllVaults(vaults);

    final txs = ref.read(allTransactionsProvider);
    for (var t in txs) {
      t.dashboardLayoutType = layoutType;
    }
    await DatabaseService.updateAllTransactions(txs);

    HapticFeedback.mediumImpact();
  }

  Future<void> _moveVault(DashboardItem item, int direction) async {
    final allItems = ref.read(dashboardItemsProvider);
    final visibleItems = List<DashboardItem>.from(allItems)
      ..sort((a, b) {
        int cmp = a.dashboardOrder.compareTo(b.dashboardOrder);
        if (cmp == 0) return a.id.compareTo(b.id);
        return cmp;
      });

    int index = visibleItems.indexWhere((v) => v.id == item.id);
    if (index == -1) return;

    int newIndex = index + direction;
    if (newIndex < 0 || newIndex >= visibleItems.length) return;

    final item1 = visibleItems[index];
    final item2 = visibleItems[newIndex];
    int tempOrder = item1.dashboardOrder;
    int order1 = item2.dashboardOrder;
    int order2 = tempOrder;

    if (order1 == order2) {
      order1 = index * 10;
      order2 = newIndex * 10;
    }

    if (item1.id.startsWith('v_')) {
      final vault = ref.read(allVaultsProvider).firstWhere((v) => 'v_${v.id}' == item1.id);
      vault.dashboardOrder = order1;
      await DatabaseService.updateVault(vault);
    } else {
      // Artık DashboardItem.id == MockTransaction.id ('db_1')
      final tx = ref.read(allTransactionsProvider).firstWhere((t) => 'db_${t.id}' == item1.id);
      tx.dashboardOrder = order1;
      await DatabaseService.updateTransaction(tx);
    }

    if (item2.id.startsWith('v_')) {
      final vault = ref.read(allVaultsProvider).firstWhere((v) => 'v_${v.id}' == item2.id);
      vault.dashboardOrder = order2;
      await DatabaseService.updateVault(vault);
    } else {
      final tx = ref.read(allTransactionsProvider).firstWhere((t) => 't_${t.id}' == item2.id);
      tx.dashboardOrder = order2;
      await DatabaseService.updateTransaction(tx);
    }

    HapticFeedback.mediumImpact();
  }
}
