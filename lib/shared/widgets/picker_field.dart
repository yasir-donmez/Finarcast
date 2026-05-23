import 'package:flutter/material.dart';
import 'inline_picker.dart';

/// Precision Tasarım Sistemi'nin tekerlekli (wheel) seçici alan bileşeni.
/// SelectorField ile aynı yapıya sahiptir ancak sağ tarafta InlinePicker kullanır.
class PickerField extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final double scalingFactor;
  final double pickerWidth;

  const PickerField({
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
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 2 * scalingFactor),
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
              label.toUpperCase(),
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
            height: 44 * scalingFactor,
            child: InlinePicker(
              items: items,
              selectedIndex: selectedIndex,
              onChanged: onChanged,
              scalingFactor: scalingFactor,
              width: pickerWidth,
              height: 44 * scalingFactor,
            ),
          ),
        ],
      ),
    );
  }
}
