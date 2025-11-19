import 'package:flutter/material.dart';
import 'package:quiz_app/config/sci_fi_assets.dart';

class SciFiSlider extends StatelessWidget {
  final double value;
  final Color? color;
  final double height;

  const SciFiSlider({
    super.key,
    required this.value,
    this.color,
    this.height = 24,
  });

  @override
  Widget build(BuildContext context) {
    final double percentage = value.clamp(0.0, 1.0);

    return SizedBox(
      height: height,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // Track Background
          Container(
            width: double.infinity,
            height: height,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(SciFiAssets.progressBarGrey),
                centerSlice: Rect.fromLTWH(15, 0, 10, 24),
                fit: BoxFit.fill,
              ),
            ),
          ),
          
          // Active Progress
          FractionallySizedBox(
            widthFactor: percentage,
            child: Container(
              height: height,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(SciFiAssets.progressBarBlue),
                  centerSlice: const Rect.fromLTWH(15, 0, 10, 24),
                  fit: BoxFit.fill,
                  colorFilter: color != null
                      ? ColorFilter.mode(color!, BlendMode.modulate)
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
