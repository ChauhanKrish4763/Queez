import 'package:flutter/material.dart';
import 'package:quiz_app/config/sci_fi_assets.dart';

class SciFiCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool isSelected;
  final EdgeInsetsGeometry padding;
  final Color? glowColor;

  const SciFiCard({
    super.key,
    required this.child,
    this.onTap,
    this.isSelected = false,
    this.padding = const EdgeInsets.all(16.0),
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    final asset = isSelected ? SciFiAssets.cardBlue : SciFiAssets.cardGrey;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(asset),
            centerSlice: const Rect.fromLTWH(20, 20, 10, 10),
            fit: BoxFit.fill,
          ),
          boxShadow: glowColor != null
              ? [
                  BoxShadow(
                    color: glowColor!.withValues(alpha: 0.4),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: child,
      ),
    );
  }
}
