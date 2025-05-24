import 'package:flutter/material.dart';
import '../game/shooterx_game.dart';
import 'dart:ui' as ui;

class GameOverOverlay extends StatelessWidget {
  final ShooterXGame game;
  const GameOverOverlay({Key? key, required this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF232526), Color(0xFF414345)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: null,
            ),
          ),
        ),
        Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.8, end: 1.0),
            duration: const Duration(milliseconds: 700),
            curve: Curves.elasticOut,
            builder: (context, scale, child) => Transform.scale(
              scale: scale,
              child: child,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(36),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(36),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.redAccent.withOpacity(0.18),
                        blurRadius: 32,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 44),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ShaderMask(
                          shaderCallback: (rect) => const RadialGradient(
                            colors: [Color(0xFFFF1744), Color(0xFFB71C1C)],
                            center: Alignment.topCenter,
                            radius: 1.2,
                          ).createShader(rect),
                          child: const Text(
                            'Game Over',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                              shadows: [Shadow(blurRadius: 8, color: Colors.black38)],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: game.score.value.toDouble()),
                          duration: const Duration(milliseconds: 900),
                          builder: (context, value, child) => Text(
                            'Score: ${value.toInt()}',
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0.7, end: 1.0),
                          duration: const Duration(milliseconds: 700),
                          curve: Curves.elasticOut,
                          builder: (context, scale, child) => Transform.scale(
                            scale: scale,
                            child: child,
                          ),
                          child: Icon(
                            Icons.sentiment_very_dissatisfied,
                            color: Colors.redAccent.withOpacity(0.8),
                            size: 38,
                            shadows: [
                              Shadow(
                                blurRadius: 10,
                                color: Colors.redAccent.withOpacity(0.4),
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 8,
                            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            shadowColor: Colors.redAccent,
                          ),
                          onPressed: () {
                            game.restart();
                          },
                          icon: const Icon(Icons.refresh, size: 22),
                          label: const Text('Restart'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
} 