import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../game/shooterx_game.dart';
import '../game/game_bloc.dart' as bloc;

class ScoreOverlay extends StatelessWidget {
  final ShooterXGame game;
  const ScoreOverlay({Key? key, required this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<bloc.GameBloc, bloc.GameState>(
      builder: (context, state) {
        return Stack(
          children: [
            // Score (optional, can be removed if not needed)
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Score: ${state.score}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                  ),
                ),
              ),
            ),
            // Life display in top right
            Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: const EdgeInsets.only(top: 40, right: 100), // Adjust right to be beside pause
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.favorite, color: Colors.redAccent, size: 22),
                    const SizedBox(width: 4),
                    Text(
                      '${state.life}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(blurRadius: 2, color: Colors.black)],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
} 