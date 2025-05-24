import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game/shooterx_game.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'screen/score_overlay.dart';
import 'screen/game_over_overlay.dart';
import 'screen/paused_overlay.dart';
import 'screen/welcome_overlay.dart';

final ShooterXGame _game = ShooterXGame();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: GameWidget(
          game: _game,
          overlayBuilderMap: {
            'Score': (context, game) => ScoreOverlay(game: game as ShooterXGame),
            'GameOver': (context, game) => GameOverOverlay(game: game as ShooterXGame),
            'Paused': (context, game) => PausedOverlay(game: game as ShooterXGame),
            'Welcome': (context, game) => WelcomeOverlay(game: game as ShooterXGame),
          },
        ),
      ),
    ),
  );
}
