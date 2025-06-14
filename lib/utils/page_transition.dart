import 'package:flutter/material.dart';

enum AnimationType {
  slideLeft,
  slideRight,
  fade,
}

class PageTransition extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;
  final AnimationType animationType;

  const PageTransition({
    super.key,
    required this.child,
    required this.animation,
    required this.animationType,
  });

  @override
  Widget build(BuildContext context) {
    switch (animationType) {
      case AnimationType.slideLeft:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      case AnimationType.slideRight:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      case AnimationType.fade:
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.02),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
    }
  }
}
