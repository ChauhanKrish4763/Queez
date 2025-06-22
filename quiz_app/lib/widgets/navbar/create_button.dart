import 'package:flutter/material.dart';
import 'package:quiz_app/utils/color.dart';

class CreateButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CreateButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: 1.15),
      duration: const Duration(milliseconds: 2000),
      curve: Curves.easeInOutBack,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: FloatingActionButton(
            onPressed: onPressed,
            backgroundColor: AppColors.accentBright,
            shape: const CircleBorder(),
            elevation: 10,
            highlightElevation: 14,
            splashColor: AppColors.primaryDark.withOpacity(0.2),
            child: const Icon(
              Icons.add,
              size: 36,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black38,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CreateButtonLocation extends FloatingActionButtonLocation {
  final double offset;

  const CreateButtonLocation({this.offset = 20});

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final double fabX =
        (scaffoldGeometry.scaffoldSize.width -
            scaffoldGeometry.floatingActionButtonSize.width) /
        2;
    final double fabY =
        scaffoldGeometry.scaffoldSize.height -
        scaffoldGeometry.floatingActionButtonSize.height -
        offset;
    return Offset(fabX, fabY);
  }
}
