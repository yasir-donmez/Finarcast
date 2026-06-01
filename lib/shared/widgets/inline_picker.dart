import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InlinePicker extends StatefulWidget {
  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final double width;
  final double? height;
  final double scalingFactor;

  const InlinePicker({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
    this.width = 120.0,
    this.height,
    this.scalingFactor = 1.0,
  });

  @override
  State<InlinePicker> createState() => _PrecisionInlinePickerState();
}

class _PrecisionInlinePickerState extends State<InlinePicker> {
  late FixedExtentScrollController _controller;
  late int _selectedIndex;
  int? _lastReportedIndex;

  @override
  void initState() {
    super.initState();
    _controller = FixedExtentScrollController(initialItem: widget.selectedIndex);
    _selectedIndex = widget.selectedIndex;
    _lastReportedIndex = widget.selectedIndex;
  }

  @override
  void didUpdateWidget(InlinePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      if (widget.selectedIndex != _lastReportedIndex) {
        _controller.jumpToItem(widget.selectedIndex);
        _lastReportedIndex = widget.selectedIndex;
        setState(() {
          _selectedIndex = widget.selectedIndex;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = Theme.of(context).colorScheme.primary;
    
    final actualHeight = widget.height ?? (64 * widget.scalingFactor);
    final itemExtent = actualHeight / 2.2;

    return SizedBox(
      height: actualHeight,
      width: widget.width * widget.scalingFactor,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Merkezi Vurgu Alanı (Mavi Cam Efekti)
          Container(
            width: widget.width * widget.scalingFactor,
            height: itemExtent * 1.1,
            decoration: BoxDecoration(
              color: activeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: activeColor.withValues(alpha: 0.15),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: activeColor.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          
          NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollEndNotification && notification.depth == 0) {
                if (_selectedIndex != widget.selectedIndex) {
                  _lastReportedIndex = _selectedIndex;
                  widget.onChanged(_selectedIndex);
                }
              }
              return false;
            },
            child: ListWheelScrollView.useDelegate(
              controller: _controller,
              itemExtent: itemExtent,
              physics: const FixedExtentScrollPhysics(),
              perspective: 0.003,
              diameterRatio: 1.8,
              squeeze: 1.1,
              overAndUnderCenterOpacity: 0.4,
              useMagnifier: true,
              magnification: 1.1,
              onSelectedItemChanged: (index) {
                if (index != _selectedIndex) {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _selectedIndex = index;
                  });
                }
              },
              childDelegate: ListWheelChildBuilderDelegate(
                childCount: widget.items.length,
                builder: (context, index) {
                  final isSelected = index == _selectedIndex;
                  final onSurface = Theme.of(context).colorScheme.onSurface;
                  
                  return Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      style: TextStyle(
                        fontSize: (isSelected ? 15 : 13) * widget.scalingFactor,
                        fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                        color: isSelected 
                            ? activeColor 
                            : onSurface.withValues(alpha: 0.3),
                        letterSpacing: isSelected ? 0.2 : 0,
                      ),
                      child: Text(widget.items[index]),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
