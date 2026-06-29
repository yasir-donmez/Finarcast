import 'package:flutter/material.dart';

class StaggeredEntryAnim extends StatefulWidget {
  final Widget child;
  final int index;
  final bool animate;

  const StaggeredEntryAnim({
    super.key,
    required this.child,
    required this.index,
    this.animate = true,
  });

  @override
  State<StaggeredEntryAnim> createState() => _StaggeredEntryAnimState();
}

class _StaggeredEntryAnimState extends State<StaggeredEntryAnim> with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    final bool isAnimationEnabled = widget.animate && widget.index < 4;
    
    if (isAnimationEnabled) {
      _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 550));
      
      _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _controller!,
        curve: Curves.easeOut,
      ));

      _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(CurvedAnimation(
        parent: _controller!,
        curve: Curves.easeOutCubic,
      ));
      
      _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(CurvedAnimation(
        parent: _controller!,
        curve: Curves.easeOutBack, // O meşhur "pıt" (spring) efekti
      ));

      final delay = widget.index * 60;
      Future.delayed(Duration(milliseconds: delay), () {
        if (mounted && _controller != null) {
          _controller!.forward();
        }
      });
    } else {
      _fadeAnimation = const AlwaysStoppedAnimation<double>(1.0);
      _slideAnimation = const AlwaysStoppedAnimation<Offset>(Offset.zero);
      _scaleAnimation = const AlwaysStoppedAnimation<double>(1.0);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: widget.child,
        ),
      ),
    );
  }
}
