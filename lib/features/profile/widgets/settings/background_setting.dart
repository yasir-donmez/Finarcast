import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/settings_provider.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../shared/widgets/precision_fluid_segmented_control.dart';
import 'color_theme_setting.dart';

class BackgroundSetting extends ConsumerWidget {
  const BackgroundSetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final density = ref.watch(
      settingsProvider.select((s) => s.bgPatternDensity),
    );
    final bgColorStyle = ref.watch(
      settingsProvider.select((s) => s.bgColorStyle),
    );
    final accentColorValue = ref.watch(
      settingsProvider.select((s) => s.accentColorValue),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Arka Plan Dokusu",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: AppColors.getTextPrimary(context),
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Arka plan deseninin görünürlük seviyesini ayarlayın",
              style: TextStyle(
                fontSize: 13,
                color: AppColors.getTextSecondary(
                  context,
                ).withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: 4,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: BackgroundPreviewCard(
                    densityLevel: index,
                    isSelected: density == index,
                    bgColorStyle: bgColorStyle,
                    accentColorValue: accentColorValue,
                    onTap: () {
                      if (density == index) return;
                      HapticFeedback.lightImpact();
                      ref
                          .read(settingsProvider.notifier)
                          .setBgPatternDensity(index);
                    },
                  ),
                );
              },
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutBack,
            alignment: Alignment.topCenter,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: density > 0 ? 1.0 : 0.0,
              child: density > 0 
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          "Renklendirme Stili",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.getTextPrimary(context),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: PrecisionFluidSegmentedControl(
                          items: const ["İkonları Boya", "Zemini Boya", "Sade"],
                          selectedIndex: bgColorStyle,
                          onChanged: (index) {
                            ref.read(settingsProvider.notifier).setBgColorStyle(index);
                          },
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

class BackgroundPreviewCard extends StatelessWidget {
  final int densityLevel;
  final bool isSelected;
  final int bgColorStyle;
  final int accentColorValue;
  final VoidCallback onTap;

  const BackgroundPreviewCard({
    super.key,
    required this.densityLevel,
    required this.isSelected,
    required this.bgColorStyle,
    required this.accentColorValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    // Opacity Mapping (Aynı PrecisionBackground gibi)
    final double opacity;
    if (densityLevel == 0) {
      opacity = 0.0;
    } else if (densityLevel == 1) {
      opacity = isDark ? 0.10 : 0.08;
    } else if (densityLevel == 2) {
      opacity = isDark ? 0.20 : 0.15;
    } else {
      opacity = isDark ? 0.30 : 0.20;
    }

    final labels = ["Kapalı", "Hafif", "Orta", "Yoğun"];
    final label = labels[densityLevel];

    // Check if the current color is a vibrant gradient color
    List<Color>? bgGradient;
    for (var option in ColorThemeSetting.vibrantColors) {
      if (option.primaryColor.toARGB32() == accentColorValue) {
        bgGradient = option.gradientColors;
        break;
      }
    }

    // Base layer styling
    final baseColor = isDark ? Colors.black : const Color(0xFFF5F7FA);
    Decoration baseDecoration = BoxDecoration(
      color: baseColor,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isSelected
            ? primaryColor
            : AppColors.getTextSecondary(context).withValues(alpha: 0.1),
        width: isSelected ? 2.5 : 1,
      ),
      boxShadow: isSelected
          ? [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.3),
                blurRadius: 12,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ]
          : [],
    );

    if (densityLevel > 0 && bgColorStyle == 1) {
      // Zemini Boya (Gerçek doygun renk stili)
      if (bgGradient != null) {
        baseDecoration = (baseDecoration as BoxDecoration).copyWith(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            // Solid painting logic synchronized
            colors: bgGradient
                .map((c) => isDark 
                    ? Color.lerp(Colors.black, c, 0.45)! 
                    : Color.lerp(const Color(0xFFF5F7FA), c, 0.18)!)
                .toList(),
          ),
        );
      } else {
        baseDecoration = (baseDecoration as BoxDecoration).copyWith(
          color: isDark 
              ? Color.lerp(Colors.black, Color(accentColorValue), 0.40)
              : Color.lerp(const Color(0xFFF5F7FA), Color(accentColorValue), 0.12),
        );
      }
    }

    Color neutralIconColor = isDark ? Colors.white : Colors.black;
    if (bgColorStyle == 1) {
      neutralIconColor = isDark ? Colors.white : Colors.black;
    }

    final iconColor = (bgColorStyle == 0)
        ? Color(accentColorValue == 0 ? primaryColor.toARGB32() : accentColorValue)
        : Colors.black;

    double iconOpacity;
    if (bgColorStyle == 0) {
      iconOpacity = opacity * 0.8;
    } else if (bgColorStyle == 1) {
      iconOpacity = isDark ? opacity * 2.2 : opacity * 1.8;
    } else {
      iconOpacity = opacity * 0.3;
    }

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          // Preview Box
          Container(
            width: 86,
            height: 120,
            decoration: baseDecoration,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14), // Inner border radius
              child: Stack(
                children: [
                  // Pattern Layer
                  if (opacity > 0.0)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                              AppAssets.getBackgroundImg(context),
                            ),
                            repeat: ImageRepeat.repeat,
                            scale: 2.8,
                            filterQuality: FilterQuality.medium,
                            colorFilter: ColorFilter.mode(
                              iconColor.withValues(alpha: iconOpacity),
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Mock UI Element (A small "glass" card to mimic a chat bubble or UI element)
                  Center(
                    child: Container(
                      width: 56,
                      height: 40,
                      decoration: BoxDecoration(
                        color: (isDark ? Colors.white : Colors.black)
                            .withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: (isDark ? Colors.white : Colors.black)
                              .withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 32,
                            height: 6,
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 20,
                            height: 4,
                            decoration: BoxDecoration(
                              color: (isDark ? Colors.white : Colors.black)
                                  .withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Selected Indicator Icon
                  if (isSelected)
                    Positioned(
                      bottom: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Label
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected
                  ? AppColors.getTextPrimary(context)
                  : AppColors.getTextSecondary(context).withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
