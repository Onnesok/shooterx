import 'package:flutter/material.dart';
import '../game/shooterx_game.dart';

class ScoreOverlay extends StatelessWidget {
  final ShooterXGame game;
  const ScoreOverlay({Key? key, required this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: game.score,
      builder: (context, value, _) => Container(
        alignment: Alignment.topLeft,
        padding: const EdgeInsets.all(24),
        child: Text(
          'Score: $value',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(blurRadius: 4, color: Colors.black)],
          ),
        ),
      ),
    );
  }
} 