import 'package:flame/components.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class EnemyShatterParticle extends PositionComponent {
  final Paint paint;
  final Vector2 velocity;
  final double angularVelocity;
  double life;
  double opacity = 1.0;
  final Path? shape;
  static final Random _random = Random();

  EnemyShatterParticle({
    required Vector2 position,
    required this.paint,
    required this.velocity,
    required this.angularVelocity,
    this.shape,
    this.life = 0.7,
    Vector2? size,
  }) : super(position: position, size: size ?? Vector2.all(8));

  @override
  void render(Canvas canvas) {
    // Defensive: always use a valid color and multiply opacities
    final Color baseColor = (paint.color ?? Colors.white);
    final double combinedOpacity = (baseColor.opacity * opacity).clamp(0.0, 1.0);
    final p = Paint()
      ..color = baseColor.withOpacity(combinedOpacity)
      ..shader = paint.shader;
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    canvas.rotate(angle);
    canvas.translate(-size.x / 2, -size.y / 2);
    if (shape != null) {
      canvas.drawPath(shape!, p);
    } else {
      canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), p);
    }
    canvas.restore();
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;
    angle += angularVelocity * dt;
    life -= dt;
    opacity = life / 0.7;
    if (life <= 0) {
      removeFromParent();
    }
  }

  // Helper to generate random particles
  static List<EnemyShatterParticle> burst({
    required Vector2 position,
    required Paint paint,
    int count = 12,
    double speed = 120,
    double size = 8,
    List<Path>? shapes,
  }) {
    return List.generate(count, (i) {
      final angle = (2 * pi / count) * i + _random.nextDouble() * 0.3;
      final v = Vector2(cos(angle), sin(angle)) * (speed * (0.7 + _random.nextDouble() * 0.6));
      final av = (_random.nextDouble() - 0.5) * 6;
      return EnemyShatterParticle(
        position: position.clone(),
        paint: paint,
        velocity: v,
        angularVelocity: av,
        size: Vector2.all(size * (0.7 + _random.nextDouble() * 0.7)),
        shape: shapes != null && shapes.isNotEmpty ? shapes[i % shapes.length] : null,
      );
    });
  }
} 