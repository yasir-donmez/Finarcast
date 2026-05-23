import 'package:flutter/material.dart';
import 'dynamic_segmented_control.dart';

class SelectorField extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final double scalingFactor;
  final double pickerWidth;

  const SelectorField({
    super.key,
    required this.icon,
    required this.label,
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
    this.scalingFactor = 1.0,
    this.pickerWidth = 120.0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4 * scalingFactor),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18 * scalingFactor,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
          ),
          SizedBox(width: 12 * scalingFactor),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11 * scalingFactor,
                fontWeight: FontWeight.w900,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                letterSpacing: 1.0,
              ),
            ),
          ),
          SizedBox(
            width: pickerWidth * scalingFactor,
            child: DynamicSegmentedControl(
              items: items,
              selectedIndex: selectedIndex,
              onChanged: onChanged,
              scalingFactor: scalingFactor,
            ),
          ),
        ],
      ),
    );
  }
}
