import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/painting.dart';
import 'dart:math';

class Player extends PositionComponent {
  static const double speed = 300;
  Vector2 moveDirection = Vector2.zero();
  double shootCooldown = 0;
  void Function(Vector2 position)? shootCallback;

  Player() : super(position: Vector2(200, 500), size: Vector2(50, 40));

  @override
  void render(Canvas canvas) {
    // Draw a modern triangle spaceship with gradients and subtle effects
    final path = Path();
    path.moveTo(size.x / 2, 0); // Top center (nose)
    path.lineTo(0, size.y);     // Bottom left
    path.lineTo(size.x, size.y); // Bottom right
    path.close();

    // Main gradient body
    final gradient = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF00FFFF), Color(0xFF0055FF), Color(0xFF001133)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));
    canvas.drawPath(path, gradient);

    // Cockpit highlight
    final cockpitPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0x99FFFFFF), Color(0x00000000)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(size.x/2 - 7, 8, 14, 16));
    canvas.drawOval(Rect.fromLTWH(size.x/2 - 7, 8, 14, 16), cockpitPaint);

    // Side accents
    final accentPaint = Paint()..color = const Color(0x4400FFFF);
    canvas.drawRect(Rect.fromLTWH(4, size.y - 10, 8, 10), accentPaint);
    canvas.drawRect(Rect.fromLTWH(size.x - 12, size.y - 10, 8, 10), accentPaint);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += moveDirection * speed * dt;
    final screenWidth = findGame()!.size.x;
    final screenHeight = findGame()!.size.y;
    position.x = position.x.clamp(0, screenWidth - size.x);
    position.y = position.y.clamp(0, screenHeight - size.y);
    if (shootCooldown > 0) shootCooldown -= dt;
  }
} 