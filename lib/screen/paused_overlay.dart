import 'package:flutter/material.dart';
import '../game/shooterx_game.dart';
import 'dart:ui' as ui;

class PausedOverlay extends StatelessWidget {
  final ShooterXGame game;
  const PausedOverlay({Key? key, required this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
        ),
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ShaderMask(
                      shaderCallback: (rect) => const RadialGradient(
                        colors: [Color(0xFF4F8FFF), Color(0xFF00FFFF)],
                        center: Alignment.topCenter,
                        radius: 1.2,
                      ).createShader(rect),
                      child: const Text(
                        'Paused',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          shadows: [Shadow(blurRadius: 8, color: Colors.black38)],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                        textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        shadowColor: Colors.blueAccent,
                      ),
                      onPressed: () {
                        game.resumeEngine();
                        game.overlays.remove('Paused');
                      },
                      icon: const Icon(Icons.play_arrow, size: 24),
                      label: const Text('Resume'),
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