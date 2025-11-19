import 'package:flutter/material.dart';
import 'package:quiz_app/config/sci_fi_assets.dart';

class SciFiPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double? width;
  final double? height;
  final Color? glowColor;

  const SciFiPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24.0),
    this.width,
    this.height,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage(SciFiAssets.panelBlue),
          centerSlice: Rect.fromLTWH(20, 20, 10, 10),
          fit: BoxFit.fill,
        ),
        boxShadow: glowColor != null
            ? [
                BoxShadow(
                  color: glowColor!.withValues(alpha: 0.5),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}
