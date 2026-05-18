import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../core/theme/app_constants.dart';
import '../transactions/add_transaction_screen.dart';
import 'dashboard_screen.dart';
import 'dashboard_providers.dart';
import '../vaults/vaults_screen.dart';
import '../vaults/vaults_providers.dart';
import '../optimization/optimization_screen.dart';
import '../profile/profile_screen.dart';
import '../../shared/widgets/precision_surface.dart';
import 'package:flutter/rendering.dart';
import '../../core/services/subscription_service.dart';
import '../subscription/widgets/pro_upgrade_sheet.dart';
import '../../shared/widgets/precision_membership_orb.dart';
import '../auth/widgets/precision_background.dart';
import 'dashboard_scroll_provider.dart';

class MainScaffold extends ConsumerStatefulWidget {
  const MainScaffold({super.key});

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  int _currentIndex = 0;
  int _previousIndex = 0;
  bool _isFloatingActionsVisible = true;
  late final PageController _pageController = PageController(initialPage: _currentIndex);
  ScrollController? _scrollController; 

  final List<Widget> _pages = [
    const DashboardScreen(),
    const VaultsScreen(),
    const OptimizationScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Build sonrası güvenli başlatma (LateInitializationError çözümüdür)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _scrollController = ref.read(dashboardScrollProvider);
        _scrollController?.addListener(_onScroll);
      }
    });
  }

  @override
  void dispose() {
    // ref kullanmadan güvenli temizlik
    _scrollController?.removeListener(_onScroll);
    _pageController.dispose();
    super.dispose();
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
    List<int>? vaultIds;
    
    if (_currentIndex == 1 && selectedVaultId != null) {
      final vId = int.tryParse(selectedVaultId.replaceFirst('v_', ''));
      if (vId != null) {
        vaultIds = [vId];
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionScreen(
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
    const navbarHeight = 66.0;
    const navbarBottomMargin = 12.0;
    const gapAboveNavbar = 18.0;
    
    final floatingActionBottom = bottomPadding + navbarBottomMargin + navbarHeight + gapAboveNavbar;
    final shouldShowProButton = _currentIndex == 0 && _isFloatingActionsVisible && !isKeyboardVisible;

    return Stack(
      children: [
        Positioned.fill(
          child: Stack(
            children: [
              const PrecisionBackground(useSystemBackground: false),
              // RadialGradient animasyonu tamamen kaldırıldı, çünkü geçiş sırasında BackdropFilter'ı bozuyor
              // ve kartların bir anda opak/şeffaf olmasına (pıt efekti) neden oluyordu.
            ],
          ),
        ),

        Scaffold(
          extendBody: true,
          backgroundColor: Colors.transparent,
          body: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                _previousIndex = _currentIndex;
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
                }
              });
            },
            children: _pages,
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
                            child: PrecisionMembershipOrb(
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

    return RepaintBoundary(
      child: PrecisionSurface(
        height: 66, 
        padding: EdgeInsets.zero,
        borderRadius: 33,
        isGlass: true,
        blur: 28,
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutQuart,
              left: 10 + (_currentIndex * itemWidth),
              top: 6,
              bottom: 6,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                width: itemWidth,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: activeColor.withValues(alpha: isDark ? 0.25 : 0.15),
                  boxShadow: [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: activeColor.withValues(alpha: isDark ? 0.3 : 0.2),
                    width: 1.2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
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
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  _buildNavItem(0, Icons.home_rounded, Icons.home_outlined, AppLocalizations.of(context)!.home),
                  _buildNavItem(1, Icons.account_balance_wallet_rounded, Icons.account_balance_wallet_outlined, AppLocalizations.of(context)!.vaults),
                  _buildNavItem(2, Icons.bar_chart_rounded, Icons.bar_chart_outlined, AppLocalizations.of(context)!.analysis),
                  _buildNavItem(3, Icons.person_rounded, Icons.person_outline_rounded, AppLocalizations.of(context)!.profile),
                ],
              ),
            ),
          ],
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
                      child: PrecisionMembershipOrb(
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

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label) {
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
          
          // Akıllı Kayma: Eğer hedef çok uzaktaysa, önce hedefin yanına ışınlan
          final distance = (index - _currentIndex).abs();
          if (distance > 1) {
            final jumpTo = index > _currentIndex ? index - 1 : index + 1;
            _pageController.jumpToPage(jumpTo);
          }
          
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOutQuart,
          );
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
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutQuart,
              style: TextStyle(
                color: contentColor,
                fontSize: 9.5,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                letterSpacing: isSelected ? 0.1 : -0.2,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
