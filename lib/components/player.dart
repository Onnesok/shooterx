import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/painting.dart';
import 'dart:math';

class Player extends PositionComponent {
  static const double speed = 300;
  Vector2 moveDirection = Vector2.zero();
  double shootCooldown = 0;
  void Function(Vector2 position)? shootCallback;
  int skinId = 0;

  Player() : super(position: Vector2(200, 500), size: Vector2(50, 40));

  @override
  void render(Canvas canvas) {
    // Draw a unique spaceship shape and color for each skin
    Paint gradient;
    Path path;
    switch (skinId) {
      case 1: // Blue Nova - Arrow shape
        gradient = Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFF42A5F5), Color(0xFF1976D2), Color(0xFF0D47A1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Rect.fromLTWH(0, 0, 50, 40));
        path = Path();
        path.moveTo(size.x / 2, 0); // Tip
        path.lineTo(size.x * 0.15, size.y * 0.7); // Left mid
        path.lineTo(size.x / 2, size.y * 0.55); // Center
        path.lineTo(size.x * 0.85, size.y * 0.7); // Right mid
        path.close();
        break;
      case 2: // Emerald - Delta shape
        gradient = Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFF00FFB0), Color(0xFF00C853), Color(0xFF004D40)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Rect.fromLTWH(0, 0, 50, 40));
        path = Path();
        path.moveTo(size.x / 2, 0); // Tip
        path.lineTo(0, size.y * 0.85); // Left
        path.lineTo(size.x / 2, size.y * 0.65); // Center
        path.lineTo(size.x, size.y * 0.85); // Right
        path.close();
        break;
      case 3: // Violet - Sleek ship shape
        gradient = Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFFB388FF), Color(0xFF7C4DFF), Color(0xFF311B92)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Rect.fromLTWH(0, 0, 50, 40));
        path = Path();
        path.moveTo(size.x / 2, 0); // Nose
        path.lineTo(size.x * 0.18, size.y * 0.55); // Left cockpit
        path.lineTo(size.x * 0.32, size.y * 0.85); // Left wing
        path.lineTo(size.x / 2, size.y * 0.7); // Rear center
        path.lineTo(size.x * 0.68, size.y * 0.85); // Right wing
        path.lineTo(size.x * 0.82, size.y * 0.55); // Right cockpit
        path.close();
        break;
      case 4: // Gold - Wide swept-back ship
        gradient = Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFFFFF176), Color(0xFFFFD600), Color(0xFFFFA000)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Rect.fromLTWH(0, 0, 50, 40));
        path = Path();
        path.moveTo(size.x / 2, 0); // Nose
        path.lineTo(size.x * 0.10, size.y * 0.55); // Left front
        path.lineTo(size.x * 0.22, size.y * 0.95); // Left rear
        path.lineTo(size.x / 2, size.y * 0.8); // Rear center
        path.lineTo(size.x * 0.78, size.y * 0.95); // Right rear
        path.lineTo(size.x * 0.90, size.y * 0.55); // Right front
        path.close();
        break;
      default: // Classic - Triangle
        gradient = Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFF00FFFF), Color(0xFF0055FF), Color(0xFF001133)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Rect.fromLTWH(0, 0, 50, 40));
        path = Path();
        path.moveTo(size.x / 2, 0); // Top center (nose)
        path.lineTo(0, size.y);     // Bottom left
        path.lineTo(size.x, size.y); // Bottom right
        path.close();
    }
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