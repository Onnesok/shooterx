import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

class Bullet extends RectangleComponent {
  static const double speed = 500;

  Bullet({required Vector2 position})
      : super(
          position: position,
          size: Vector2(8, 20),
          paint: Paint()..color = const Color(0xFFFFFF00),
        );

  @override
  void update(double dt) {
    super.update(dt);
    position.y -= speed * dt;
    // Remove bullet if it goes off the top of the screen
    if (position.y + size.y < 0) {
      removeFromParent();
    }
  }
}

class EnemyBullet extends RectangleComponent {
  static const double speed = 320;

  EnemyBullet({required Vector2 position})
      : super(
          position: position,
          size: Vector2(8, 20),
          paint: Paint()..color = const Color(0xFFFF4444),
        );

  @override
  void update(double dt) {
    super.update(dt);
    position.y += speed * dt;
    // Remove bullet if it goes off the bottom of the screen
    if (position.y > findGame()!.size.y) {
      removeFromParent();
    }
  }
} 