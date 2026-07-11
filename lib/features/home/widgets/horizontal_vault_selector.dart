import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HorizontalVaultSelector extends StatefulWidget {
  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final double scalingFactor;

  const HorizontalVaultSelector({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
    this.scalingFactor = 1.0,
  });

  @override
  State<HorizontalVaultSelector> createState() => _HorizontalVaultSelectorState();
}

class _HorizontalVaultSelectorState extends State<HorizontalVaultSelector> {
  late PageController _pageController;
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
    _pageController = PageController(
      initialPage: widget.selectedIndex,
      viewportFraction: 0.45,
    );
  }

  @override
  void didUpdateWidget(HorizontalVaultSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _selectedIndex = widget.selectedIndex;
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          widget.selectedIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = Theme.of(context).colorScheme.primary;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return SizedBox(
      height: 48 * widget.scalingFactor,
      child: ShaderMask(
        shaderCallback: (Rect rect) {
          return const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.transparent,
              Colors.black,
              Colors.black,
              Colors.transparent,
            ],
            stops: [0.0, 0.15, 0.85, 1.0],
          ).createShader(rect);
        },
        blendMode: BlendMode.dstIn,
        child: PageView.builder(
          controller: _pageController,
          itemCount: widget.items.length,
          physics: const BouncingScrollPhysics(),
          onPageChanged: (index) {
            if (index != _selectedIndex) {
              HapticFeedback.lightImpact();
              setState(() {
                _selectedIndex = index;
              });
              widget.onChanged(index);
            }
          },
          itemBuilder: (context, index) {
            final isSelected = index == _selectedIndex;

            return Center(
              child: GestureDetector(
                onTap: () {
                  if (index != _selectedIndex) {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                    );
                  }
                },
                behavior: HitTestBehavior.opaque,
                child: AnimatedScale(
                  scale: isSelected ? 1.0 : 0.85,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    style: TextStyle(
                      fontSize: (isSelected ? 15 : 13) * widget.scalingFactor,
                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                      color: isSelected
                          ? activeColor
                          : onSurface.withValues(alpha: 0.35),
                      letterSpacing: isSelected ? 0.3 : 0,
                    ),
                    child: Text(
                      widget.items[index],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
