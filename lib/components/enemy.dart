import 'package:flame/components.dart';
import 'package:flutter/painting.dart';
import 'dart:math';
import 'bullet.dart';

enum EnemyType { diamond, hexagon, octagon }

class Enemy extends PositionComponent {
  final double speed;
  final EnemyType type;
  double shootTimer = 0;
  double nextShoot = 0;
  final Random _random = Random();

  Enemy({required Vector2 position, this.type = EnemyType.diamond, this.speed = 120})
      : super(
          position: position,
          size: Vector2(40, 40),
        ) {
    nextShoot = 1.5 + _random.nextDouble() * 2.0; // random between 1.5 and 3.5s
  }

  @override
  void render(Canvas canvas) {
    switch (type) {
      case EnemyType.diamond:
        _renderDiamond(canvas);
        break;
      case EnemyType.hexagon:
        _renderHexagon(canvas);
        break;
      case EnemyType.octagon:
        _renderOctagon(canvas);
        break;
    }
  }

  void _renderDiamond(Canvas canvas) {
    final path = Path();
    path.moveTo(size.x / 2, 0); // Top
    path.lineTo(size.x, size.y / 2); // Right
    path.lineTo(size.x / 2, size.y); // Bottom
    path.lineTo(0, size.y / 2); // Left
    path.close();

    final gradient = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFF5555), Color(0xFFB71C1C), Color(0xFF880000)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));
    canvas.drawPath(path, gradient);

    final glowPaint = Paint()
      ..color = const Color(0x44FF5555)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawPath(path, glowPaint);

    final highlightPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0x99FFFFFF), Color(0x00FFFFFF)],
      ).createShader(Rect.fromCircle(center: Offset(size.x/2, size.y/2), radius: 10));
    canvas.drawCircle(Offset(size.x/2, size.y/2), 10, highlightPaint);
  }

  void _renderHexagon(Canvas canvas) {
    final path = Path();
    final double r = size.x / 2;
    final Offset c = Offset(size.x / 2, size.y / 2);
    for (int i = 0; i < 6; i++) {
      final angle = pi / 3 * i - pi / 2;
      final x = c.dx + r * cos(angle);
      final y = c.dy + r * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    final gradient = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF69F0AE), Color(0xFF00C853), Color(0xFF003300)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));
    canvas.drawPath(path, gradient);

    final glowPaint = Paint()
      ..color = const Color(0x4400C853)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawPath(path, glowPaint);

    final highlightPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0x99FFFFFF), Color(0x00FFFFFF)],
      ).createShader(Rect.fromCircle(center: Offset(size.x/2, size.y/2), radius: 10));
    canvas.drawCircle(Offset(size.x/2, size.y/2), 10, highlightPaint);
  }

  void _renderOctagon(Canvas canvas) {
    final path = Path();
    final double r = size.x / 2;
    final Offset c = Offset(size.x / 2, size.y / 2);
    for (int i = 0; i < 8; i++) {
      final angle = pi / 4 * i - pi / 2;
      final x = c.dx + r * cos(angle);
      final y = c.dy + r * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    final gradient = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF42A5F5), Color(0xFF1976D2), Color(0xFF0D1333)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));
    canvas.drawPath(path, gradient);

    final glowPaint = Paint()
      ..color = const Color(0x4442A5F5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawPath(path, glowPaint);

    final highlightPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0x99FFFFFF), Color(0x00FFFFFF)],
      ).createShader(Rect.fromCircle(center: c, radius: 10));
    canvas.drawCircle(c, 10, highlightPaint);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += speed * dt;
    if (position.y > findGame()!.size.y) {
      removeFromParent();
    }
    // Shooting logic
    shootTimer += dt;
    if (shootTimer >= nextShoot && position.y > 0 && position.y < findGame()!.size.y - size.y) {
      shootTimer = 0;
      nextShoot = 1.5 + _random.nextDouble() * 2.0;
      parent?.add(EnemyBullet(position: position + Vector2(size.x / 2 - 4, size.y)));
    }
  }
} 