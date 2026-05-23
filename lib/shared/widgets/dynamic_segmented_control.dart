import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DynamicSegmentedControl extends StatelessWidget {
  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final double scalingFactor;

  const DynamicSegmentedControl({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
    this.scalingFactor = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      height: 44 * scalingFactor,
      padding: EdgeInsets.all(4 * scalingFactor),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12 * scalingFactor),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double totalWidth = constraints.maxWidth;
          final double itemWidth = items.isEmpty ? 0 : totalWidth / items.length;

          if (items.isEmpty) return const SizedBox();

          return Stack(
            children: [
              // Sliding Indicator
              AnimatedPositioned(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOutQuart,
                left: selectedIndex * itemWidth,
                width: itemWidth,
                top: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8 * scalingFactor),
                    border: Border.all(
                      color: primaryColor.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                ),
              ),
              // Items
              Row(
                children: List.generate(items.length, (index) {
                  final isSelected = selectedIndex == index;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (!isSelected) {
                          HapticFeedback.lightImpact();
                          onChanged(index);
                        }
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 250),
                          style: TextStyle(
                            fontSize: 13 * scalingFactor,
                            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                            color: isSelected 
                                ? primaryColor 
                                : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                          child: Text(items[index]),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}
