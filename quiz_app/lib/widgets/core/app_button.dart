import 'package:flutter/material.dart';
import '../../utils/color.dart';
import '../../utils/quiz_design_system.dart';

/// Button style variants
enum AppButtonStyle {
  primary,
  secondary,
  outlined,
  text,
  error,
  success,
}

/// Button size variants
enum AppButtonSize {
  small,
  medium,
  large,
}

/// Custom Button component with consistent styling
/// Provides multiple variants and sizes with AppColors integration
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonStyle style;
  final AppButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;
  final double? customWidth;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.style = AppButtonStyle.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    this.customWidth,
  });

  /// Primary button (green background, white text)
  const AppButton.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    this.customWidth,
  }) : style = AppButtonStyle.primary;

  /// Secondary button (sage green background)
  const AppButton.secondary({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    this.customWidth,
  }) : style = AppButtonStyle.secondary;

  /// Outlined button (transparent with border)
  const AppButton.outlined({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    this.customWidth,
  }) : style = AppButtonStyle.outlined;

  /// Text button (no background)
  const AppButton.text({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    this.customWidth,
  }) : style = AppButtonStyle.text;

  /// Error button (red background)
  const AppButton.error({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    this.customWidth,
  }) : style = AppButtonStyle.error;

  /// Success button (green background)
  const AppButton.success({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    this.customWidth,
  }) : style = AppButtonStyle.success;

  @override
  Widget build(BuildContext context) {
    final buttonStyle = _getButtonStyle();
    final buttonChild = _buildButtonChild();

    Widget button;

    switch (style) {
      case AppButtonStyle.outlined:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: buttonChild,
        );
        break;
      case AppButtonStyle.text:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: buttonChild,
        );
        break;
      default:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: buttonChild,
        );
    }

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: button);
    } else if (customWidth != null) {
      return SizedBox(width: customWidth, child: button);
    }

    return button;
  }

  Widget _buildButtonChild() {
    if (isLoading) {
      return SizedBox(
        height: _getIconSize(),
        width: _getIconSize(),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(_getLoadingColor()),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: _getIconSize()),
          const SizedBox(width: QuizSpacing.sm),
          Text(text),
        ],
      );
    }

    return Text(text);
  }

  ButtonStyle _getButtonStyle() {
    final padding = _getPadding();
    final textStyle = _getTextStyle();
    final borderRadius = BorderRadius.circular(QuizBorderRadius.md);

    switch (style) {
      case AppButtonStyle.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.disabledBackground,
          disabledForegroundColor: AppColors.textDisabled,
          padding: padding,
          textStyle: textStyle,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          elevation: 0,
        );

      case AppButtonStyle.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.disabledBackground,
          disabledForegroundColor: AppColors.textDisabled,
          padding: padding,
          textStyle: textStyle,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          elevation: 0,
        );

      case AppButtonStyle.outlined:
        return OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.textDisabled,
          padding: padding,
          textStyle: textStyle,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          side: const BorderSide(color: AppColors.primary, width: 1.5),
        );

      case AppButtonStyle.text:
        return TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.textDisabled,
          padding: padding,
          textStyle: textStyle,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
        );

      case AppButtonStyle.error:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.disabledBackground,
          disabledForegroundColor: AppColors.textDisabled,
          padding: padding,
          textStyle: textStyle,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          elevation: 0,
        );

      case AppButtonStyle.success:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.success,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.disabledBackground,
          disabledForegroundColor: AppColors.textDisabled,
          padding: padding,
          textStyle: textStyle,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          elevation: 0,
        );
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case AppButtonSize.small:
        return const EdgeInsets.symmetric(
          horizontal: QuizSpacing.md,
          vertical: QuizSpacing.sm,
        );
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: QuizSpacing.lg,
          vertical: QuizSpacing.md,
        );
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(
          horizontal: QuizSpacing.xl,
          vertical: QuizSpacing.lg,
        );
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case AppButtonSize.small:
        return const TextStyle(fontSize: 14, fontWeight: FontWeight.w500);
      case AppButtonSize.medium:
        return const TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
      case AppButtonSize.large:
        return const TextStyle(fontSize: 18, fontWeight: FontWeight.w600);
    }
  }

  double _getIconSize() {
    switch (size) {
      case AppButtonSize.small:
        return 16;
      case AppButtonSize.medium:
        return 20;
      case AppButtonSize.large:
        return 24;
    }
  }

  Color _getLoadingColor() {
    switch (style) {
      case AppButtonStyle.outlined:
      case AppButtonStyle.text:
        return AppColors.primary;
      default:
        return AppColors.white;
    }
  }
}
