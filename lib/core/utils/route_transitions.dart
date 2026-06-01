import 'package:flutter/material.dart';

/// A custom page route that performs a premium slide-up transition with custom duration and curve.
class SlideUpPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;

  SlideUpPageRoute({
    required this.child,
    super.settings,
    super.fullscreenDialog = false,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            final curve = Curves.easeOutCubic;
            final reverseCurve = Curves.easeInCubic;
            
            final tween = Tween(begin: begin, end: end).chain(
              CurveTween(
                curve: animation.status == AnimationStatus.reverse 
                    ? reverseCurve 
                    : curve,
              ),
            );
            
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 320),
          reverseTransitionDuration: const Duration(milliseconds: 240),
        );
}

/// A custom page route that performs a premium fade-and-scale transition.
class FadeScalePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;

  FadeScalePageRoute({
    required this.child,
    super.settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.96, end: 1.0).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOutCubic,
                  ),
                ),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
          reverseTransitionDuration: const Duration(milliseconds: 300),
        );
}
