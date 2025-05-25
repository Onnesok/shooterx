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
        // Full-screen background image
        Positioned.fill(
          child: Image.asset(
            'assets/images/backgrounds/background1.png',
            fit: BoxFit.cover,
          ),
        ),
        // Semi-transparent dark overlay for readability
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.5),
          ),
        ),
        // Centered content
        SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.92, end: 1.0),
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.elasticOut,
                    builder: (context, scale, child) => Transform.scale(
                      scale: scale,
                      child: child,
                    ),
                    child: ShaderMask(
                      shaderCallback: (rect) => const RadialGradient(
                        colors: [Color(0xFF4F8FFF), Color(0xFF00FFFF)],
                        center: Alignment.topCenter,
                        radius: 1.2,
                      ).createShader(rect),
                      child: const Text(
                        'shooterX',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 64,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                          shadows: [
                            Shadow(blurRadius: 24, color: Colors.blueAccent, offset: Offset(0, 0)),
                            Shadow(blurRadius: 8, color: Colors.black54, offset: Offset(0, 2)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.18)),
                    ),
                    child: const Text(
                      'Endless Shooter game for fun by Onnesok',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1.2,
                        shadows: [Shadow(blurRadius: 8, color: Colors.black26)],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 18,
                      textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      shadowColor: Colors.blueAccent,
                    ),
                    onPressed: () {
                      game.startGame();
                    },
                    icon: const Icon(Icons.play_arrow, size: 24),
                    label: const Text('Start Game'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
} 