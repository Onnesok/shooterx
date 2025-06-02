import 'package:flame/components.dart';
import 'package:flutter/painting.dart';
import 'dart:math';

class Heart extends RectangleComponent {
  static const double speed = 180;
  Heart({required Vector2 position})
      : super(
          position: position,
          size: Vector2(32, 32),
          paint: Paint()..color = const Color(0xFFFF1744),
          anchor: Anchor.topLeft,
        );

  @override
  void render(Canvas canvas) {
    // Draw a simple heart shape (can be replaced with an image/sprite)
    final paint = Paint()..color = const Color(0xFFFF1744);
    final w = size.x;
    final h = size.y;
    final path = Path();
    path.moveTo(w / 2, h * 0.8);
    path.cubicTo(-w * 0.2, h * 0.4, w * 0.2, -h * 0.1, w / 2, h * 0.3);
    path.cubicTo(w * 0.8, -h * 0.1, w * 1.2, h * 0.4, w / 2, h * 0.8);
    canvas.drawPath(path, paint);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += speed * dt;
    // Remove if off the bottom of the screen
    final game = findGame();
    if (game != null && position.y > game.size.y) {
      removeFromParent();
    }
  }
} 