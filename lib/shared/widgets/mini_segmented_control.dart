import 'package:flutter/material.dart';

class MiniSegmentedControl extends StatelessWidget {
  final List<String> items;
  final int selectedIndex;
  final Function(int) onChanged;
  final double scalingFactor;

  const MiniSegmentedControl({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
    this.scalingFactor = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32 * scalingFactor, // Biraz daha rahat dokunulması için 32 yapıldı
      padding: EdgeInsets.all(2 * scalingFactor),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3), // Biraz daha belirgin arka plan
        borderRadius: BorderRadius.circular(8 * scalingFactor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(items.length, (index) {
          final isSelected = selectedIndex == index;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onChanged(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: EdgeInsets.symmetric(horizontal: 14 * scalingFactor), // Genişlik S W L harfleri için iyi
              decoration: BoxDecoration(
                color: isSelected 
                    ? Theme.of(context).colorScheme.surface.withValues(alpha: 0.95)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6 * scalingFactor),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  )
                ] : [],
              ),
              alignment: Alignment.center,
              child: Text(
                items[index],
                style: TextStyle(
                  fontSize: 11 * scalingFactor,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                  color: isSelected 
                      ? Theme.of(context).colorScheme.primary 
                      : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
