import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/providers/game_provider.dart';
import 'package:quiz_app/providers/session_provider.dart';
import 'package:quiz_app/widgets/sci_fi/sci_fi_background.dart';
import 'package:quiz_app/widgets/sci_fi/sci_fi_panel.dart';
import 'package:quiz_app/widgets/sci_fi/sci_fi_button.dart';
import 'package:quiz_app/widgets/sci_fi/sci_fi_card.dart';
import 'package:quiz_app/widgets/sci_fi/sci_fi_theme.dart';
import 'dart:math' as math;

class ResultsScreen extends ConsumerStatefulWidget {
  const ResultsScreen({super.key});

  @override
  ConsumerState<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends ConsumerState<ResultsScreen> 
    with TickerProviderStateMixin {
  late AnimationController _confettiController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  final List<_Confetti> _confettiParticles = [];

  @override
  void initState() {
    super.initState();
    
    _confettiController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    
    // Generate confetti particles
    final random = math.Random();
    for (int i = 0; i < 50; i++) {
      _confettiParticles.add(_Confetti(
        x: random.nextDouble(),
        y: -0.1,
        color: [
          SciFiTheme.primary,
          SciFiTheme.accent,
          SciFiTheme.warning,
          SciFiTheme.success,
        ][random.nextInt(4)],
        speed: 0.3 + random.nextDouble() * 0.5,
        size: 4 + random.nextDouble() * 6,
      ));
    }
    
    _confettiController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final currentUserId = ref.watch(currentUserProvider);
    final rankings = gameState.rankings ?? [];
    
    final currentUserRank = rankings.indexWhere(
      (rank) => rank['user_id'] == currentUserId
    );
    final isWinner = currentUserRank == 0;

    return PopScope(
      canPop: false,
      child: SciFiBackground(
        child: Stack(
          children: [
            // Confetti Animation
            if (isWinner)
              AnimatedBuilder(
                animation: _confettiController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _ConfettiPainter(
                      particles: _confettiParticles,
                      progress: _confettiController.value,
                    ),
                    size: Size.infinite,
                  );
                },
              ),
            
            // Main Content
            FadeTransition(
              opacity: _fadeAnimation,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // Trophy Icon
                      Icon(
                        Icons.emoji_events,
                        size: 100,
                        color: isWinner ? SciFiTheme.warning : SciFiTheme.primary,
                        shadows: [
                          Shadow(
                            color: (isWinner ? SciFiTheme.warning : SciFiTheme.primary)
                                .withValues(alpha: 0.8),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Title
                      Text(
                        isWinner ? 'VICTORY!' : 'QUIZ COMPLETED!',
                        style: SciFiTheme.heading1.copyWith(
                          fontSize: 36,
                          color: isWinner ? SciFiTheme.warning : SciFiTheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Current User Stats
                      if (currentUserRank >= 0) ...[
                        SciFiPanel(
                          glowColor: isWinner ? SciFiTheme.warning : SciFiTheme.accent,
                          child: Column(
                            children: [
                              Text(
                                'YOUR RANK',
                                style: SciFiTheme.caption.copyWith(
                                  color: SciFiTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        '#${currentUserRank + 1}',
                                        style: SciFiTheme.heading1.copyWith(
                                          fontSize: 48,
                                          color: isWinner 
                                              ? SciFiTheme.warning 
                                              : SciFiTheme.primary,
                                        ),
                                      ),
                                      Text(
                                        'POSITION',
                                        style: SciFiTheme.caption,
                                      ),
                                    ],
                                  ),
                                  Container(
                                    width: 2,
                                    height: 60,
                                    color: SciFiTheme.primary.withValues(alpha: 0.3),
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        '${rankings[currentUserRank]['score']}',
                                        style: SciFiTheme.heading1.copyWith(
                                          fontSize: 48,
                                          color: SciFiTheme.success,
                                        ),
                                      ),
                                      Text(
                                        'POINTS',
                                        style: SciFiTheme.caption,
                                      ),
                                    ],
                                  ),
                                  if (rankings[currentUserRank]['accuracy'] != null) ...[
                                    Container(
                                      width: 2,
                                      height: 60,
                                      color: SciFiTheme.primary.withValues(alpha: 0.3),
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          '${rankings[currentUserRank]['accuracy']}%',
                                          style: SciFiTheme.heading1.copyWith(
                                            fontSize: 48,
                                            color: SciFiTheme.accent,
                                          ),
                                        ),
                                        Text(
                                          'ACCURACY',
                                          style: SciFiTheme.caption,
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                      
                      // Rankings Header
                      Text(
                        'FINAL RANKINGS',
                        style: SciFiTheme.heading2.copyWith(
                          color: SciFiTheme.accent,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Rankings List
                      Expanded(
                        child: ListView.builder(
                          itemCount: math.min(rankings.length, 10),
                          itemBuilder: (context, index) {
                            final rank = rankings[index];
                            final position = index + 1;
                            final isCurrentUser = rank['user_id'] == currentUserId;
                            
                            Color rankColor = SciFiTheme.primary;
                            IconData? medalIcon;
                            
                            if (position == 1) {
                              rankColor = SciFiTheme.warning;
                              medalIcon = Icons.emoji_events;
                            } else if (position == 2) {
                              rankColor = const Color(0xFFC0C0C0);
                              medalIcon = Icons.emoji_events;
                            } else if (position == 3) {
                              rankColor = const Color(0xFFCD7F32);
                              medalIcon = Icons.emoji_events;
                            }
                            
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: SciFiCard(
                                glowColor: isCurrentUser ? SciFiTheme.accent : rankColor,
                                child: Row(
                                  children: [
                                    // Rank Badge
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: rankColor.withValues(alpha: 0.3),
                                        border: Border.all(color: rankColor, width: 2),
                                        boxShadow: position <= 3
                                            ? [
                                                BoxShadow(
                                                  color: rankColor.withValues(alpha: 0.5),
                                                  blurRadius: 10,
                                                  spreadRadius: 2,
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Center(
                                        child: medalIcon != null
                                            ? Icon(medalIcon, color: rankColor, size: 28)
                                            : Text(
                                                '#$position',
                                                style: SciFiTheme.body.copyWith(
                                                  color: rankColor,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                      ),
                                    ),
                                    
                                    const SizedBox(width: 16),
                                    
                                    // User Info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            rank['user_id'],
                                            style: SciFiTheme.body.copyWith(
                                              fontWeight: isCurrentUser 
                                                  ? FontWeight.bold 
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                          if (rank['accuracy'] != null) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              '${rank['accuracy']}% accuracy',
                                              style: SciFiTheme.caption.copyWith(
                                                color: SciFiTheme.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    
                                    // Score
                                    Text(
                                      '${rank['score']}',
                                      style: SciFiTheme.heading2.copyWith(
                                        color: rankColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Return Button
                      SciFiButton(
                        label: 'RETURN TO LIBRARY',
                        onPressed: () {
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        },
                        isPrimary: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Confetti {
  final double x;
  final double y;
  final Color color;
  final double speed;
  final double size;

  _Confetti({
    required this.x,
    required this.y,
    required this.color,
    required this.speed,
    required this.size,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_Confetti> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = particle.color.withValues(alpha: 1.0 - progress)
        ..style = PaintingStyle.fill;
      
      final y = particle.y + (progress * particle.speed);
      if (y <= 1.0) {
        canvas.drawCircle(
          Offset(particle.x * size.width, y * size.height),
          particle.size,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => true;
}
