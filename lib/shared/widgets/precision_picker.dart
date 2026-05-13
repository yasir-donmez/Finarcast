import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

/// Finarcast "Precision" Serisi Döngüsel Seçici (Picker).
/// CupertinoPicker'ı premium bir cam efekti ve özel vurgu ile sarmalar.
class PrecisionPicker extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int, bool) itemBuilder;
  final int initialItem;
  final ValueChanged<int> onSelectedItemChanged;
  final double itemExtent;
  final double height;

  const PrecisionPicker({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.initialItem = 0,
    required this.onSelectedItemChanged,
    this.itemExtent = 54.0,
    this.height = 240.0,
  });

  /// Basit metin listeleri için kolay kullanım sağlayan fabrika metodu.
  factory PrecisionPicker.strings({
    Key? key,
    required List<String> items,
    int initialItem = 0,
    required ValueChanged<int> onSelectedItemChanged,
    double itemExtent = 54.0,
    double height = 240.0,
  }) {
    return PrecisionPicker(
      key: key,
      itemCount: items.length,
      initialItem: initialItem,
      onSelectedItemChanged: onSelectedItemChanged,
      itemExtent: itemExtent,
      height: height,
      itemBuilder: (context, index, isSelected) {
        return Center(
          child: Text(
            items[index],
            style: TextStyle(
              color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)
                  .withValues(alpha: isSelected ? 1.0 : 0.4),
              fontSize: 18,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
              letterSpacing: -0.5,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: height,
      child: Stack(
        children: [
          // 1. Ortadaki Cam Vurgu (Glass Indicator)
          Center(
            child: Container(
              height: itemExtent,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.08),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),

          // 2. Cupertino Picker
          _PrecisionPickerInner(
            itemCount: itemCount,
            itemBuilder: itemBuilder,
            initialItem: initialItem,
            onSelectedItemChanged: onSelectedItemChanged,
            itemExtent: itemExtent,
          ),
        ],
      ),
    );
  }
}

class _PrecisionPickerInner extends StatefulWidget {
  final int itemCount;
  final Widget Function(BuildContext, int, bool) itemBuilder;
  final int initialItem;
  final ValueChanged<int> onSelectedItemChanged;
  final double itemExtent;

  const _PrecisionPickerInner({
    required this.itemCount,
    required this.itemBuilder,
    required this.initialItem,
    required this.onSelectedItemChanged,
    required this.itemExtent,
  });

  @override
  State<_PrecisionPickerInner> createState() => _PrecisionPickerInnerState();
}

class _PrecisionPickerInnerState extends State<_PrecisionPickerInner> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialItem;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPicker.builder(
      itemExtent: widget.itemExtent,
      backgroundColor: Colors.transparent,
      useMagnifier: true,
      magnification: 1.1,
      diameterRatio: 1.1,
      scrollController: FixedExtentScrollController(initialItem: widget.initialItem),
      onSelectedItemChanged: (index) {
        setState(() => _selectedIndex = index);
        widget.onSelectedItemChanged(index);
      },
      selectionOverlay: const SizedBox.shrink(),
      itemBuilder: (context, index) {
        if (index < 0 || index >= widget.itemCount) return null;
        return widget.itemBuilder(context, index, index == _selectedIndex);
      },
      childCount: widget.itemCount,
    );
  }
}
