import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../shared/widgets/glass_surface.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../core/theme/app_constants.dart';
import '../transactions/transaction_builder_screen.dart';
import 'dashboard_screen.dart';
import 'home_providers.dart';
import '../vaults/vaults_screen.dart';
import '../vaults/vaults_providers.dart';
import '../smart_inbox/smart_scan_screen.dart';
import '../settings/settings_screen.dart';

import '../../core/services/subscription_service.dart';
import '../subscription/widgets/pro_upgrade_sheet.dart';
import '../../shared/widgets/membership_orb.dart';
import '../auth/widgets/auth_background.dart';
import '../smart_inbox/services/share_handler_service.dart';
import '../smart_inbox/providers/smart_inbox_providers.dart';
import '../../shared/widgets/custom_dialog.dart';
import 'home_scroll_provider.dart';
import '../../shared/widgets/custom_notification.dart';
import '../../core/utils/route_transitions.dart';

class MainScaffold extends ConsumerStatefulWidget {
  const MainScaffold({super.key});

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> with TickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isFloatingActionsVisible = true;
  late final PageController _pageController = PageController(initialPage: _currentIndex);
  ScrollController? _scrollController; 
  late final ShareHandlerService _shareHandlerService;

  late final AnimationController _pillController;
  double _sourceIndex = 0.0;
  double _targetIndex = 0.0;
  bool _isSlidingTransition = true;

  // GlobalKey listesi: Sayfaların durumunu (state) reparenting esnasında korumak için
  late final List<GlobalKey> _pageKeys = List.generate(4, (_) => GlobalKey());

  late final List<Widget> _pages = [
    DashboardScreen(key: _pageKeys[0]),
    VaultsScreen(key: _pageKeys[1]),
    SmartScanScreen(key: _pageKeys[2]),
    SettingsScreen(key: _pageKeys[3]),
  ];

  bool _isTransitioning = false;
  List<Widget>? _transitioningPages;

  List<Widget> _getTransitionPages(int from, int to) {
    if ((to - from).abs() <= 1) return _pages;
    
    // Diğer sayfaları boş kutularla (SizedBox) doldurarak hem performansı artırır
    // hem de aynı GlobalKey'e sahip widget'ların ağaçta aynı anda iki kez bulunmasını engeller.
    final list = List<Widget>.generate(4, (_) => const SizedBox());
    list[from] = _pages[from];
    if (to > from) {
      list[from + 1] = _pages[to];
    } else {
      list[from - 1] = _pages[to];
    }
    return list;
  }

  @override
  void initState() {
    super.initState();
    _pillController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _sourceIndex = _currentIndex.toDouble();
    _targetIndex = _currentIndex.toDouble();
    _pillController.value = 1.0;

    // Build sonrası güvenli başlatma (LateInitializationError çözümüdür)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _scrollController = ref.read(homeScrollProvider);
        _scrollController?.addListener(_onScroll);
      }
    });

    // Initialize share intent handler
    _shareHandlerService = ShareHandlerService(
      ref: ref,
      onProcessingStarted: (message) {
        if (mounted) {
          // Switch to Cart screen (index 2) immediately
          setState(() {
            _currentIndex = 2;
            _isFloatingActionsVisible = false;
          });
          _pageController.jumpToPage(2);
          
          // Set global loading message
          ref.read(smartInboxLoadingProvider.notifier).state = message;
        }
      },
      onProcessingSuccess: (draft) {
        if (mounted) {
          // Clear loading message
          ref.read(smartInboxLoadingProvider.notifier).state = null;
          // Refresh list of drafts
          ref.read(smartInboxDraftsProvider.notifier).loadDrafts();
          
          CustomNotification.success(
            context,
            AppLocalizations.of(context)!.sharedExpenseAnalyzed,
          );
        }
      },
      onProcessingError: (title, detail) {
        if (mounted) {
          // Clear loading message
          ref.read(smartInboxLoadingProvider.notifier).state = null;
          
          final l10n = AppLocalizations.of(context)!;
          final String effectiveTitle = title == 'LIMIT_EXCEEDED' ? l10n.limitExceeded : title;

          // Show error dialog
          if (title == 'LIMIT_EXCEEDED') {
            final isPro = ref.read(subscriptionServiceProvider).isPro;
            if (isPro) {
              showCustomDialog(
                context: context,
                accentColor: const Color(0xFFFFB300), // Altın rengi
                title: effectiveTitle,
                content: l10n.unlimitedAccessLimitDesc,
                actions: [
                  PrecisionDialogAction(
                    label: l10n.close,
                    onTap: () => Navigator.pop(context),
                    isPrimary: true,
                  ),
                ],
              );
            } else {
              showCustomDialog(
                context: context,
                accentColor: const Color(0xFFFFB300), // Altın rengi
                title: effectiveTitle,
                content: l10n.standardAccessLimitDesc,
                actions: [
                  PrecisionDialogAction(
                    label: l10n.later,
                    onTap: () => Navigator.pop(context),
                    isPrimary: false,
                  ),
                  PrecisionDialogAction(
                    label: l10n.upgradeToExtendedAccess,
                    onTap: () {
                      Navigator.pop(context);
                      ProUpgradeSheet.show(context);
                    },
                    isPrimary: true,
                  ),
                ],
              );
            }
          } else {
            CustomNotification.error(context, detail != null && detail.isNotEmpty ? '$effectiveTitle: $detail' : effectiveTitle);
          }
        }
      },
    )..init();
  }

  @override
  void dispose() {
    _pillController.dispose();
    _shareHandlerService.dispose();
    // ref kullanmadan güvenli temizlik
    _scrollController?.removeListener(_onScroll);
    _pageController.dispose();
    super.dispose();
  }

  double _getCurrentIndexPosition() {
    final t = _pillController.value;
    final isMovingRight = _targetIndex > _sourceIndex;
    final valLeading = Curves.easeOutQuart.transform(t);
    final valTrailing = Curves.easeInQuart.transform(t);
    
    if (isMovingRight) {
      final leftPos = _sourceIndex + (_targetIndex - _sourceIndex) * valTrailing;
      final rightPos = _sourceIndex + (_targetIndex - _sourceIndex) * valLeading;
      return (leftPos + rightPos) / 2.0;
    } else {
      final leftPos = _sourceIndex + (_targetIndex - _sourceIndex) * valLeading;
      final rightPos = _sourceIndex + (_targetIndex - _sourceIndex) * valTrailing;
      return (leftPos + rightPos) / 2.0;
    }
  }

  Widget _buildPillWidget(Color activeColor, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(23),
        color: activeColor.withValues(alpha: isDark ? 0.25 : 0.15),
        border: Border.all(
          color: activeColor.withValues(alpha: isDark ? 0.3 : 0.2),
          width: 1.2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(23),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: isDark ? 0.05 : 0.2),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onScroll() {
    if (!mounted || _scrollController == null) return;
    final controller = _scrollController!;
    if (!controller.hasClients) return;

    // Sadece header açıkken (kasa kartları görünürken, yani en tepedeyken) göster
    final isAtTop = controller.offset < 10;
    if (_isFloatingActionsVisible != isAtTop) {
      setState(() {
        _isFloatingActionsVisible = isAtTop;
      });
    }
  }

  void _openTransactionScreen() {
    final selectedVaultId = ref.read(selectedVaultProvider);
    final groups = ref.read(transactionGroupsProvider);
    final effectiveVaultId = selectedVaultId ?? (groups.isNotEmpty ? groups.first.id : null);
    List<int>? vaultIds;
    
    if (_currentIndex == 1 && effectiveVaultId != null) {
      final vId = int.tryParse(effectiveVaultId.replaceFirst('v_', ''));
      if (vId != null) {
        vaultIds = [vId];
      }
    }

    Navigator.push(
      context,
      SlideUpPageRoute(
        child: TransactionBuilderScreen(
          initialVaultIds: vaultIds,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subscription = ref.watch(subscriptionServiceProvider);
    final rotaryColor = ref.watch(rotaryColorProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? rotaryColor : AppColors.getAccentDeep(context, rotaryColor);
    
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    const navbarHeight = 58.0;
    const navbarBottomMargin = 12.0;
    const gapAboveNavbar = 18.0;
    
    final floatingActionBottom = bottomPadding + navbarBottomMargin + navbarHeight + gapAboveNavbar;
    final shouldShowProButton = _currentIndex == 0 && _isFloatingActionsVisible && !isKeyboardVisible;

    return Stack(
      children: [
        Positioned.fill(
          child: Stack(
            children: [
              const AuthBackground(useSystemBackground: false),
              // RadialGradient animasyonu tamamen kaldırıldı, çünkü geçiş sırasında BackdropFilter'ı bozuyor
              // ve kartların bir anda opak/şeffaf olmasına (pıt efekti) neden oluyordu.
            ],
          ),
        ),

        Scaffold(
          extendBody: true,
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: false,
          body: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) {
              if (_isTransitioning) return;
              setState(() {
                _currentIndex = index;
                // Sekme değişimlerinde orb görünürlük durumunu akıllıca güncelle
                if (index == 0) {
                  _isFloatingActionsVisible = true;
                } else if (index == 1) {
                  if (_scrollController != null && _scrollController!.hasClients) {
                    _isFloatingActionsVisible = _scrollController!.offset < 10;
                  } else {
                    _isFloatingActionsVisible = true;
                  }
                } else {
                  _isFloatingActionsVisible = false;
                }
              });
            },
            children: _isTransitioning && _transitioningPages != null ? _transitioningPages! : _pages,
          ),
        ),

        AnimatedPositioned(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutQuart,
          bottom: shouldShowProButton && !subscription.isPro ? floatingActionBottom : 12, 
          right: 32,
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: (shouldShowProButton && !subscription.isPro) ? 1.0 : 0.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutQuart,
            builder: (context, scaleFactor, child) {
              return IgnorePointer(
                ignoring: scaleFactor < 0.5,
                child: Opacity(
                  opacity: scaleFactor.clamp(0.0, 1.0), 
                  child: Transform.scale(
                    scale: scaleFactor,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        HeroMode(
                          enabled: shouldShowProButton && scaleFactor > 0.5,
                          child: Hero(
                            tag: 'pro_orb',
                            child: MembershipOrb(
                              color: activeColor,
                              size: 60,
                              morphFactor: scaleFactor,
                            ),
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              ProUpgradeSheet.show(context);
                            },
                            borderRadius: BorderRadius.circular(30),
                            child: const SizedBox(width: 60, height: 60),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        _buildFloatingActionButton(floatingActionBottom),

        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Material(
            type: MaterialType.transparency,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: _buildModernNavbar(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernNavbar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rotaryColor = ref.watch(rotaryColorProvider);
    final activeColor = isDark ? rotaryColor : AppColors.getAccentDeep(context, rotaryColor);
    
    final screenWidth = MediaQuery.of(context).size.width;
    final navWidth = screenWidth - 32; 
    const internalPadding = 20.0; 
    final availableWidth = navWidth - internalPadding;
    final itemWidth = availableWidth / 4;
    
    // ZİRVE HİSSİYAT: Seçici hapa (pill) yanlardan daha fazla yer tanıyarak dillerin/ekranların sığmasını sağlar.
    const double pillHorizontalMargin = 4.0;
    final double maxLabelWidth = itemWidth - (2 * pillHorizontalMargin + 4);

    return RepaintBoundary(
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(29),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
              blurRadius: 30,
              offset: const Offset(0, 10),
              spreadRadius: -5,
            ),
          ],
        ),
        child: GlassSurface(
          borderRadius: 29,
          blurSigma: 28,
          showShadow: false,
          child: Stack(
            children: [
              AnimatedBuilder(
                animation: _pillController,
                builder: (context, child) {
                  final t = _pillController.value;
                  
                  if (_isSlidingTransition) {
                    final isMovingRight = _targetIndex > _sourceIndex;
                    
                    // ZİRVE HİSSİYAT: Öncü kenar Curves.easeOutBack ile hafif taşma yaparken,
                    // artçı kenar Curves.easeInOutCubic ile geriden gelip yakalıyor.
                    final valLeading = Curves.easeOutBack.transform(t);
                    final valTrailing = Curves.easeInOutCubic.transform(t);
                    
                    final double leftIndex;
                    final double rightIndex;
                    
                    if (isMovingRight) {
                      leftIndex = _sourceIndex + (_targetIndex - _sourceIndex) * valTrailing;
                      rightIndex = _sourceIndex + (_targetIndex - _sourceIndex) * valLeading;
                    } else {
                      leftIndex = _sourceIndex + (_targetIndex - _sourceIndex) * valLeading;
                      rightIndex = _sourceIndex + (_targetIndex - _sourceIndex) * valTrailing;
                    }
                    
                    final double left = 10 + (leftIndex * itemWidth) + pillHorizontalMargin;
                    final double width = (rightIndex - leftIndex) * itemWidth + (itemWidth - (2 * pillHorizontalMargin));
                    
                    return Stack(
                      children: [
                        Positioned(
                          left: left,
                          top: 6,
                          bottom: 6,
                          width: width,
                          child: _buildPillWidget(activeColor, isDark),
                        ),
                      ],
                    );
                  } else {
                    // FADE/SCALE HYBRID ANIMATION (for distance > 1)
                    if (!_pillController.isAnimating) {
                      final double left = 10 + (_targetIndex * itemWidth) + pillHorizontalMargin;
                      final double width = itemWidth - (2 * pillHorizontalMargin);
                      return Stack(
                        children: [
                          Positioned(
                            left: left,
                            top: 6,
                            bottom: 6,
                            width: width,
                            child: _buildPillWidget(activeColor, isDark),
                          ),
                        ],
                      );
                    }
                    
                    final sourceLeft = 10 + (_sourceIndex * itemWidth) + pillHorizontalMargin;
                    final targetLeft = 10 + (_targetIndex * itemWidth) + pillHorizontalMargin;
                    final width = itemWidth - (2 * pillHorizontalMargin);
                    
                    // ZİRVE HİSSİYAT: Eski hap ilk %40'lık dilimde hızlıca sönüyor.
                    final sourceOpacity = (1.0 - t / 0.4).clamp(0.0, 1.0);
                    
                    // Yeni hap %10'luk bir gecikmeyle başlayıp Curves.easeOutBack ile büyüyerek pop-in yapıyor.
                    final targetT = ((t - 0.1) / 0.9).clamp(0.0, 1.0);
                    final targetOpacity = Curves.easeIn.transform(targetT);
                    final targetScale = 0.8 + (0.2 * Curves.easeOutBack.transform(targetT));
                    
                    return Stack(
                      children: [
                        // Old pill fading out
                        Positioned(
                          left: sourceLeft,
                          top: 6,
                          bottom: 6,
                          width: width,
                          child: Opacity(
                            opacity: sourceOpacity,
                            child: _buildPillWidget(activeColor, isDark),
                          ),
                        ),
                        // New pill fading & scaling in
                        Positioned(
                          left: targetLeft,
                          top: 6,
                          bottom: 6,
                          width: width,
                          child: Opacity(
                            opacity: targetOpacity,
                            child: Transform.scale(
                              scale: targetScale,
                              child: _buildPillWidget(activeColor, isDark),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    _buildNavItem(0, Icons.dashboard_rounded, Icons.dashboard_outlined, AppLocalizations.of(context)!.dashboard, itemWidth, maxLabelWidth),
                    _buildNavItem(1, Icons.account_balance_wallet_rounded, Icons.account_balance_wallet_outlined, AppLocalizations.of(context)!.vaults, itemWidth, maxLabelWidth),
                    _buildNavItem(
                      2,
                      Icons.auto_awesome_rounded,
                      Icons.auto_awesome_outlined,
                      AppLocalizations.of(context)!.smartScanTitle,
                      itemWidth,
                      maxLabelWidth,
                    ),
                    _buildNavItem(3, Icons.settings_rounded, Icons.settings_outlined, AppLocalizations.of(context)!.settings, itemWidth, maxLabelWidth),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(double floatingActionBottom) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rotaryColor = ref.watch(rotaryColorProvider);
    final activeColor = isDark ? rotaryColor : AppColors.getAccentDeep(context, rotaryColor);
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    
    final isVisible = _currentIndex == 1 && !isKeyboardVisible && _isFloatingActionsVisible;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutQuart,
      bottom: isVisible ? floatingActionBottom : 12, 
      right: 32,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: isVisible ? 1.0 : 0.0),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutQuart,
        builder: (context, scaleFactor, child) {
          return IgnorePointer(
            ignoring: scaleFactor < 0.5,
            child: Opacity(
              opacity: scaleFactor.clamp(0.0, 1.0),
              child: Transform.scale(
                scale: scaleFactor,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Hero(
                      tag: 'fab_bubble',
                      child: MembershipOrb(
                        color: activeColor,
                        size: 60, 
                        morphFactor: scaleFactor,
                        showParticles: false,
                      ),
                    ),
                    if (scaleFactor > 0.6)
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: (scaleFactor - 0.6) / 0.4,
                        child: const Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.heavyImpact();
                          _openTransactionScreen();
                        },
                        borderRadius: BorderRadius.circular(30),
                        child: const SizedBox(width: 60, height: 60),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label, double itemWidth, double maxLabelWidth) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _currentIndex == index;
    final secondaryTextColor = AppColors.getTextSecondary(context);
    final activeColor = ref.watch(rotaryColorProvider);
    
    final contentColor = isSelected 
        ? (isDark ? activeColor : AppColors.getAccentDeep(context, activeColor)) 
        : secondaryTextColor.withValues(alpha: 0.8);

    return Expanded(
      child: GestureDetector(
        onTap: () async {
          if (_currentIndex == index) return;
          if (_isTransitioning) return;
          
          HapticFeedback.selectionClick();
          
          final int fromIndex = _currentIndex;
          final int toIndex = index;
          final distance = (toIndex - fromIndex).abs();
          
          setState(() {
            _sourceIndex = _pillController.isAnimating ? _getCurrentIndexPosition() : fromIndex.toDouble();
            _targetIndex = toIndex.toDouble();
            _currentIndex = toIndex;
            _isSlidingTransition = distance <= 1;
            
            // Sekme değişimlerinde orb görünürlük durumunu akıllıca güncelle
            if (toIndex == 0) {
              _isFloatingActionsVisible = true;
            } else if (toIndex == 1) {
              if (_scrollController != null && _scrollController!.hasClients) {
                _isFloatingActionsVisible = _scrollController!.offset < 10;
              } else {
                _isFloatingActionsVisible = true;
              }
            } else {
              _isFloatingActionsVisible = false;
            }
          });
          
          _pillController.forward(from: 0.0);
          
          if (distance <= 1) {
            await _pageController.animateToPage(
              toIndex,
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutQuart,
            );
          } else {
            final tempPages = _getTransitionPages(fromIndex, toIndex);
            
            setState(() {
              _isTransitioning = true;
              _transitioningPages = tempPages;
            });
            
            final int animateTo = toIndex > fromIndex ? fromIndex + 1 : fromIndex - 1;
            
            await _pageController.animateToPage(
              animateTo,
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutQuart,
            );
            
            if (mounted) {
              _pageController.jumpToPage(toIndex);
              setState(() {
                _isTransitioning = false;
                _transitioningPages = null;
              });
            }
          }
        },
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(scale: animation, child: child),
                );
              },
              child: Icon(
                isSelected ? activeIcon : inactiveIcon,
                key: ValueKey('icon_${index}_$isSelected'),
                color: contentColor,
                size: 22,
              ),
            ),
            const SizedBox(height: 1),
            SizedBox(
              width: maxLabelWidth,
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutQuart,
                style: TextStyle(
                  color: contentColor,
                  fontSize: 9.5,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                  letterSpacing: isSelected ? 0.1 : -0.2,
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
