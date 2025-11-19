import 'dart:math';
import 'package:flutter/material.dart';
import 'package:quiz_app/widgets/sci_fi/sci_fi_theme.dart';

class SciFiBackground extends StatefulWidget {
  final Widget child;

  const SciFiBackground({super.key, required this.child});

  @override
  State<SciFiBackground> createState() => _SciFiBackgroundState();
}

class _SciFiBackgroundState extends State<SciFiBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Star> _stars = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Generate random stars
    for (int i = 0; i < 100; i++) {
      _stars.add(Star());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base Gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0B0E17), // Deep Space
                Color(0xFF1B2735), // Dark Blue
                Color(0xFF090A0F), // Almost Black
              ],
            ),
          ),
        ),
        
        // Animated Stars
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: StarFieldPainter(
                stars: _stars,
                progress: _controller.value,
              ),
              size: Size.infinite,
            );
          },
        ),

        // Grid Overlay (Holographic effect)
        CustomPaint(
          painter: GridPainter(),
          size: Size.infinite,
        ),

        // Content
        widget.child,
      ],
    );
  }
}

class Star {
  double x = Random().nextDouble();
  double y = Random().nextDouble();
  double size = Random().nextDouble() * 2 + 1;
  double opacity = Random().nextDouble();
  double speed = Random().nextDouble() * 0.05 + 0.01;
}

class StarFieldPainter extends CustomPainter {
  final List<Star> stars;
  final double progress;

  StarFieldPainter({required this.stars, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;

    for (final star in stars) {
      // Move stars
      double y = (star.y + progress * star.speed) % 1.0;
      
      paint.color = Colors.white.withValues(alpha: star.opacity);
      canvas.drawCircle(
        Offset(star.x * size.width, y * size.height),
        star.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(StarFieldPainter oldDelegate) => true;
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = SciFiTheme.primary.withValues(alpha: 0.05)
      ..strokeWidth = 1;

    const double gridSize = 40;

    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
