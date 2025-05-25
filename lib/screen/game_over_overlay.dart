import 'package:flutter/material.dart';
import '../game/shooterx_game.dart';

class GameOverOverlay extends StatelessWidget {
  final ShooterXGame game;
  const GameOverOverlay({Key? key, required this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Full-screen background image
        Positioned.fill(
          child: Image.asset(
            'assets/images/backgrounds/background1.png',
            fit: BoxFit.cover,
          ),
        ),
        // Simple dark overlay
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.65),
          ),
        ),
        // Animated entrance for content
        SafeArea(
          child: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOut,
              builder: (context, opacity, child) => AnimatedOpacity(
                opacity: opacity,
                duration: const Duration(milliseconds: 300),
                child: child,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Animated title
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.8, end: 1.0),
                      duration: const Duration(milliseconds: 900),
                      curve: Curves.elasticOut,
                      builder: (context, scale, child) => Transform.scale(
                        scale: scale,
                        child: child,
                      ),
                      child: Text(
                        'Game Over',
                        style: TextStyle(
                          color: Colors.redAccent.shade100,
                          fontSize: 54,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          shadows: const [
                            Shadow(blurRadius: 12, color: Colors.redAccent, offset: Offset(0, 2)),
                            Shadow(blurRadius: 4, color: Colors.black54, offset: Offset(0, 2)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Score
                    Text(
                      'Score: ${game.score.value}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        shadows: [Shadow(blurRadius: 4, color: Colors.black45)],
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Animated sad icon
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.7, end: 1.0),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.elasticOut,
                      builder: (context, scale, child) => Transform.scale(
                        scale: scale,
                        child: child,
                      ),
                      child: const Icon(
                        Icons.sentiment_very_dissatisfied,
                        color: Colors.redAccent,
                        size: 48,
                        shadows: [
                          Shadow(blurRadius: 8, color: Colors.redAccent, offset: Offset(0, 2)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),
                    // Buttons
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            elevation: 8,
                            textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            shadowColor: Colors.redAccent,
                          ),
                          onPressed: () {
                            game.restart();
                          },
                          icon: const Icon(Icons.refresh, size: 24),
                          label: const Text('Restart'),
                        ),
                        const SizedBox(width: 24),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[900],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            elevation: 8,
                            textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            shadowColor: Colors.black54,
                          ),
                          onPressed: () {
                            game.overlays.remove('GameOver');
                            game.overlays.add('Welcome');
                          },
                          icon: const Icon(Icons.home, size: 24),
                          label: const Text('Main Menu'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
