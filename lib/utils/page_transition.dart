import 'package:flutter/material.dart';

class PageTransition extends StatelessWidget {
  final Widget child;
  final bool isForward;
  final int index;

  const PageTransition({
    super.key,
    required this.child,
    required this.isForward,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        if (index == 2) {
          // Simple fade transition for index 2
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        } else {
          // Slide transition for other indices
          final beginOffset = isForward ? const Offset(1.0, 0.0) : const Offset(-1.0, 0.0);
          final offsetAnimation = Tween<Offset>(
            begin: beginOffset,
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ));

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        }
      },
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      child: child,
    );
  }
}
