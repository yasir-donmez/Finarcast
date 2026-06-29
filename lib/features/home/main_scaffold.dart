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
  ScrollController? _scrollController; 
  late final ShareHandlerService _shareHandlerService;

  late final AnimationController _sheenController;
  late final AnimationController _pageSlideController;
  late final Animation<double> _sheenAnimation;
  int _previousIndex = 0;

  // Sayfaların durumunu (state) korumak için GlobalKey kullanımı
  late final List<GlobalKey> _pageKeys = List.generate(4, (_) => GlobalKey());

  late final List<Widget> _pages = [
    DashboardScreen(key: _pageKeys[0]),
    VaultsScreen(key: _pageKeys[1]),
    SmartScanScreen(key: _pageKeys[2]),
    SettingsScreen(key: _pageKeys[3]),
  ];

  @override
  void initState() {
    super.initState();
    _pageSlideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _pageSlideController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() {}); // Eski sayfayı gizle
      }
    });
    _sheenController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    // Sheen animasyonunu yalnızca Pro butonu görünürken çalıştır (başlangıçta index 0)
    _sheenController.repeat();
    _sheenAnimation = CurvedAnimation(
      parent: _sheenController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
    );


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
          _switchToPage(2);
          
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

  /// Hedef sayfaya geçiş yap — orb görünürlüğünü ve sheen lifecycle'ını yönetir.
  void _switchToPage(int toIndex) {
    final fromIndex = _currentIndex;
    _previousIndex = fromIndex;
    
    setState(() {
      _currentIndex = toIndex;
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
    
    // Slide animasyonu başlat
    _pageSlideController.forward(from: 0.0);
    
    // Sheen animasyonunu yönet: yalnızca Dashboard (index 0) sekmesinde çalıştır
    _manageSheenLifecycle(toIndex);
  }

  /// Sheen animasyonunu sadece görünür olduğunda çalıştır (Dashboard sekmesi).
  void _manageSheenLifecycle(int activeIndex) {
    if (activeIndex == 0) {
      if (!_sheenController.isAnimating) _sheenController.repeat();
    } else {
      if (_sheenController.isAnimating) _sheenController.stop();
    }
  }

  @override
  void dispose() {
    _sheenController.dispose();
    _pageSlideController.dispose();
    _shareHandlerService.dispose();
    // ref kullanmadan güvenli temizlik
    _scrollController?.removeListener(_onScroll);
    super.dispose();
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

    // Sheen animasyonunu Pro butonu görünürlüğüne bağla
    final shouldAnimateSheen = _currentIndex == 0 && isAtTop;
    if (shouldAnimateSheen && !_sheenController.isAnimating) {
      _sheenController.repeat();
    } else if (!shouldAnimateSheen && _sheenController.isAnimating) {
      _sheenController.stop();
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

    final viewMode = ref.read(vaultViewModeProvider);
    final initialBuilderType = viewMode == VaultViewMode.templates
        ? TransactionBuilderType.recurring
        : TransactionBuilderType.oneTime;

    Navigator.push(
      context,
      SlideUpPageRoute(
        child: TransactionBuilderScreen(
          initialVaultId: vaultIds?.first,
          initialBuilderType: initialBuilderType,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subscription = ref.watch(subscriptionServiceProvider);
    
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
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
          // Offstage + TickerMode + SlideTransition mimarisi:
          // - Sayfa state'i korunur (Offstage widget'ı ağaçta tutar)
          // - Görünmeyen sayfanın TÜM animasyonları otomatik durur (TickerMode)
          // - Smooth slide geçişi (SlideTransition, GPU-native transform)
          body: AnimatedBuilder(
            animation: _pageSlideController,
            builder: (context, _) {
              final bool isAnimating = _pageSlideController.isAnimating;
              final double t = Curves.easeOutCubic.transform(_pageSlideController.value);
              final bool goingRight = _currentIndex > _previousIndex;
              
              return Stack(
                children: List.generate(4, (i) {
                  final isActive = i == _currentIndex;
                  final isPrevious = i == _previousIndex && isAnimating;
                  final isVisible = isActive || isPrevious;
                  
                  // Geçiş sırasında slide offset hesapla
                  Offset slideOffset = Offset.zero;
                  if (isAnimating) {
                    if (isActive) {
                      // Yeni sayfa: yönden içeri kayar
                      final direction = goingRight ? 1.0 : -1.0;
                      slideOffset = Offset(direction * (1.0 - t), 0);
                    } else if (isPrevious) {
                      // Eski sayfa: ters yöne dışarı kayar
                      final direction = goingRight ? -1.0 : 1.0;
                      slideOffset = Offset(direction * t, 0);
                    }
                  }
                  
                  return TickerMode(
                    enabled: isActive,
                    child: Offstage(
                      offstage: !isVisible,
                      child: FractionalTranslation(
                        translation: slideOffset,
                        child: _pages[i],
                      ),
                    ),
                  );
                }),
              );
            },
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
                            child: AnimatedBuilder(
                              animation: _sheenAnimation,
                              builder: (context, child) {
                                return MembershipOrb(
                                  color: const Color(0xFFFFB300),
                                  sheenVal: _sheenAnimation.value,
                                  size: 60,
                                  morphFactor: scaleFactor,
                                );
                              },
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
              maintainBottomViewPadding: true,
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
    const internalPadding = 12.0; 
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
          blurSigma: 18,
          showShadow: false,
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                left: 6 + (_currentIndex * itemWidth) + pillHorizontalMargin,
                top: 6,
                bottom: 6,
                width: itemWidth - (2 * pillHorizontalMargin),
                child: _buildPillWidget(activeColor, isDark),
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Row(
                  children: [
                    _buildNavItem(0, Icons.dashboard_rounded, Icons.dashboard_outlined, AppLocalizations.of(context)!.navDashboard, itemWidth, maxLabelWidth),
                    _buildNavItem(1, Icons.account_balance_wallet_rounded, Icons.account_balance_wallet_outlined, AppLocalizations.of(context)!.navVaults, itemWidth, maxLabelWidth),
                    _buildNavItem(
                      2,
                      Icons.auto_awesome_rounded,
                      Icons.auto_awesome_outlined,
                      AppLocalizations.of(context)!.navSmartScan,
                      itemWidth,
                      maxLabelWidth,
                    ),
                    _buildNavItem(3, Icons.settings_rounded, Icons.settings_outlined, AppLocalizations.of(context)!.navSettings, itemWidth, maxLabelWidth),
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
        onTap: () {
          if (_currentIndex == index) return;
          
          HapticFeedback.selectionClick();
          
          final int toIndex = index;
          
          // Sayfa geçişi — tek setState, jumpToPage yok
          _switchToPage(toIndex);
        },
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.0 : 0.85,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              child: Icon(
                isSelected ? activeIcon : inactiveIcon,
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
