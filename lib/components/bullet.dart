import 'package:flame/components.dart';
import 'package:flutter/painting.dart';
import 'dart:math';
import '../components/enemy.dart';

enum BulletType { normal, fire, plasma, laser, wave }

class Bullet extends RectangleComponent {
  static const double speed = 500;
  final BulletType type;

  Bullet({required Vector2 position, this.type = BulletType.normal})
      : super(
          position: position,
          size: Vector2(8, 20),
          paint: _getPaint(type),
          anchor: Anchor.topCenter,
        );

  static Paint _getPaint(BulletType type) {
    switch (type) {
      case BulletType.normal:
        return Paint()..color = const Color(0xFFFFFF00);
      case BulletType.fire:
        return Paint()..color = const Color(0xFFFF5722);
      case BulletType.plasma:
        return Paint()..color = const Color(0xFF00E5FF);
      case BulletType.laser:
        return Paint()..color = const Color(0xFFB388FF);
      case BulletType.wave:
        return Paint()..color = const Color(0xFF76FF03);
    }
  }

  @override
  void render(Canvas canvas) {
    final centerX = size.x / 2;
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    switch (type) {
      case BulletType.normal:
        super.render(canvas);
        break;
      case BulletType.fire:
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(6)),
          paint,
        );
        break;
      case BulletType.plasma:
        canvas.drawOval(rect, paint);
        break;
      case BulletType.laser:
        canvas.drawRect(rect.deflate(2), paint);
        break;
      case BulletType.wave:
        final path = Path();
        for (int i = 0; i < 8; i++) {
          final x = centerX + sin(i * 1.2) * 3;
          final y = i * size.y / 8;
          if (i == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
        }
        canvas.drawPath(path, paint..strokeWidth = 3..style = PaintingStyle.stroke);
        break;
    }
  }

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

class SplitBullet extends Bullet {
  double splitTimer = 0.18; // seconds before splitting
  bool hasSplit = false;
  SplitBullet({required Vector2 position}) : super(position: position, type: BulletType.normal);

  @override
  void update(double dt) {
    super.update(dt);
    if (!hasSplit) {
      splitTimer -= dt;
      if (splitTimer <= 0) {
        hasSplit = true;
        // Split into two bullets at angles
        final game = findGame();
        if (game != null) {
          final pos = position.clone();
          game.add(BulletWithAngle(position: pos, angle: -0.25));
          game.add(BulletWithAngle(position: pos, angle: 0.25));
        }
        removeFromParent();
      }
    }
  }
}

class BulletWithAngle extends Bullet {
  final double angle; // radians
  BulletWithAngle({required Vector2 position, required this.angle}) : super(position: position, type: BulletType.normal);

  @override
  void update(double dt) {
    super.update(dt);
    position.x += sin(angle) * Bullet.speed * dt;
    position.y -= cos(angle) * Bullet.speed * dt;
  }
}

class ExplosiveBullet extends Bullet {
  double timer = 0.7; // Explodes after 0.7s if not hit
  bool exploded = false;
  ExplosiveBullet({required Vector2 position}) : super(position: position, type: BulletType.fire);

  @override
  void update(double dt) {
    super.update(dt);
    if (exploded) return;
    timer -= dt;
    if (timer <= 0) {
      explode();
    }
  }

  void explode() {
    if (exploded) return;
    exploded = true;
    // Damage nearby enemies
    final game = findGame();
    if (game != null) {
      final explosionRadius = 48.0;
      final enemies = game.children.whereType<Enemy>().toList();
      for (final enemy in enemies) {
        if ((enemy.position - position).length < explosionRadius) {
          enemy.removeFromParent();
        }
      }
      // Optionally: add explosion effect here
    }
    removeFromParent();
  }
} 