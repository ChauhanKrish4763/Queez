import 'package:flutter/material.dart';
import 'package:quiz_app/widgets/sci_fi/sci_fi_theme.dart';
import 'package:quiz_app/config/sci_fi_assets.dart';

class SciFiButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isLoading;
  final double? width;
  final double height;

  const SciFiButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isPrimary = true,
    this.isLoading = false,
    this.width,
    this.height = 56,
  });

  @override
  State<SciFiButton> createState() => _SciFiButtonState();
}

class _SciFiButtonState extends State<SciFiButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;
    
    // Select asset based on type
    final String assetPath = widget.isPrimary 
        ? SciFiAssets.buttonBlue 
        : SciFiAssets.buttonGrey;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
      child: GestureDetector(
        onTapDown: isEnabled ? (_) => _controller.forward() : null,
        onTapUp: isEnabled ? (_) => _controller.reverse() : null,
        onTapCancel: isEnabled ? () => _controller.reverse() : null,
        onTap: isEnabled ? widget.onPressed : null,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(assetPath),
                centerSlice: const Rect.fromLTWH(15, 15, 10, 10), // Approximate 9-slice
                fit: BoxFit.fill,
                colorFilter: !isEnabled
                    ? const ColorFilter.mode(Colors.grey, BlendMode.saturation)
                    : _isHovered
                        ? ColorFilter.mode(Colors.white.withValues(alpha: 0.2), BlendMode.srcATop)
                        : null,
              ),
              boxShadow: isEnabled && _isHovered
                  ? [
                      BoxShadow(
                        color: (widget.isPrimary ? SciFiTheme.primary : SciFiTheme.accent)
                            .withValues(alpha: 0.6),
                        blurRadius: 12,
                        spreadRadius: 2,
                      )
                    ]
                  : [],
            ),
            child: Center(
              child: widget.isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: SciFiTheme.textPrimary,
                      ),
                    )
                  : Text(
                      widget.label.toUpperCase(),
                      style: SciFiTheme.button.copyWith(
                        color: isEnabled
                            ? SciFiTheme.textPrimary
                            : SciFiTheme.textSecondary,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
