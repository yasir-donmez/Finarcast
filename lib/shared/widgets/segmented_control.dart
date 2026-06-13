import 'package:flutter/material.dart';
import '../../core/theme/app_constants.dart';

class SegmentedControl extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final Function(int) onTabChanged;
  final double scalingFactor;
  final Color? activeColor;

  const SegmentedControl({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabChanged,
    this.scalingFactor = 1.0,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Cam efekti için rengi çok düşük opaklığa çekiyoruz (Tint efekti)
    final effectiveActiveColor = activeColor != null 
        ? activeColor!.withValues(alpha: 0.15) // Şeffaf cam rengi
        : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white);
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8 * scalingFactor),
      height: 50 * scalingFactor,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(25 * scalingFactor),
      ),
      child: Stack(
        children: [
          // Hareketli Arka Plan (Renklendirilmiş Cam Indicator)
          AnimatedAlign(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOutBack,
            alignment: Alignment(
              tabs.length <= 1 ? 0.0 : (selectedIndex / (tabs.length - 1)) * 2 - 1,
              0,
            ),
            child: FractionallySizedBox(
              widthFactor: tabs.isEmpty ? 0 : 1 / tabs.length,
              child: Container(
                height: 42 * scalingFactor,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: effectiveActiveColor,
                  borderRadius: BorderRadius.circular(21 * scalingFactor),
                  border: Border.all(
                    color: activeColor != null 
                        ? activeColor!.withValues(alpha: 0.3) 
                        : Colors.transparent,
                    width: 1,
                  ),
                  boxShadow: [
                    if (activeColor != null)
                      BoxShadow(
                        color: activeColor!.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
              ),
            ),
          ),
          // Tab Yazıları
          Row(
            children: List.generate(tabs.length, (index) {
              final isActive = selectedIndex == index;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTabChanged(index),
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14 * scalingFactor,
                        // Yazı rengini orijinal renginde ama net tutalım
                        color: isActive 
                          ? (activeColor ?? AppColors.getTextPrimary(context)) 
                          : AppColors.getTextSecondary(context),
                      ),
                      child: Text(tabs[index]),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
