import 'package:flutter/material.dart';
import '../game/shooterx_game.dart';
import 'dart:ui' as ui;

class WelcomeOverlay extends StatelessWidget {
  final ShooterXGame game;
  const WelcomeOverlay({Key? key, required this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedContainer(
            duration: const Duration(seconds: 2),
            curve: Curves.easeInOut,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF232526), Color(0xFF0F2027), Color(0xFF2C5364)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.8, end: 1.0),
            duration: const Duration(milliseconds: 900),
            curve: Curves.elasticOut,
            builder: (context, scale, child) => Transform.scale(
              scale: scale,
              child: child,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ShaderMask(
                  shaderCallback: (rect) => const RadialGradient(
                    colors: [Color(0xFF4F8FFF), Color(0xFF00FFFF)],
                    center: Alignment.topCenter,
                    radius: 1.2,
                  ).createShader(rect),
                  child: const Text(
                    'shooterX',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 72,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                      shadows: [Shadow(blurRadius: 18, color: Colors.black54)],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.13),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.13),
                            blurRadius: 18,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 28),
                      child: Column(
                        children: [
                          const Text(
                            'Endless Shooter game for fun by Onnesok',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 28,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 40),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 54, vertical: 24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              elevation: 14,
                              textStyle: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                              shadowColor: Colors.blueAccent,
                            ),
                            onPressed: () {
                              game.startGame();
                            },
                            icon: const Icon(Icons.play_arrow, size: 38),
                            label: const Text('Start Game'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
} 