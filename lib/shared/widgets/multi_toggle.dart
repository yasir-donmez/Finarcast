import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MultiToggle extends StatelessWidget {
  final List<String>? labels;
  final List<IconData>? icons;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final List<Color>? activeColors;
  final double scalingFactor;

  const MultiToggle({
    super.key,
    this.labels,
    this.icons,
    required this.selectedIndex,
    required this.onChanged,
    this.activeColors,
    this.scalingFactor = 1.0,
  }) : assert(labels != null || icons != null, 'Either labels or icons must be provided');

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final int itemCount = labels?.length ?? icons?.length ?? 0;
    
    // Eğer activeColors verilmemişse tema primary rengini kullan
    final List<Color> colors = activeColors ?? List.generate(itemCount, (i) => Theme.of(context).colorScheme.primary);

    final Color activeColor = selectedIndex < colors.length ? colors[selectedIndex] : Theme.of(context).colorScheme.primary;

    final double segmentWidth = 36.0 * scalingFactor;
    final double padding = 4.0 * scalingFactor;

    return Container(
      width: (segmentWidth * itemCount) + (padding * 2),
      height: 40 * scalingFactor,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20 * scalingFactor),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutBack,
            left: (selectedIndex * segmentWidth),
            top: 0,
            bottom: 0,
            child: Container(
              width: segmentWidth,
              decoration: BoxDecoration(
                color: activeColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Row(
            children: List.generate(itemCount, (index) {
              final isSelected = selectedIndex == index;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onChanged(index);
                },
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: segmentWidth,
                  child: Center(
                    child: labels != null 
                        ? Text(
                            labels![index],
                            style: TextStyle(
                              fontSize: 12 * scalingFactor,
                              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                              color: isSelected
                                  ? colors[index]
                                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                            ),
                          )
                        : Icon(
                            icons![index],
                            size: 18 * scalingFactor,
                            color: isSelected
                                ? colors[index]
                                : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
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
