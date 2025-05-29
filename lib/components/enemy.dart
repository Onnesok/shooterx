import 'package:flame/components.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'bullet.dart';
import 'enemy_shatter_particle.dart';

enum EnemyType { asteroid, spaceship }

class Enemy extends PositionComponent {
  final double speed;
  final EnemyType type;
  double shootTimer = 0;
  double nextShoot = 0;
  final Random _random = Random();
  late List<Offset> _asteroidPoints;
  bool _isShattering = false;
  double _shatterTimer = 0.0;
  static const double shatterDuration = 0.5; // seconds
  double _shatterScale = 1.0;
  double _shatterRotation = 0.0;
  double _shatterOpacity = 1.0;

  Enemy({required Vector2 position, this.type = EnemyType.asteroid, this.speed = 120})
      : super(
          position: position,
          size: Vector2(40, 40),
        ) {
    nextShoot = 1.5 + _random.nextDouble() * 2.0; // random between 1.5 and 3.5s
    if (type == EnemyType.asteroid) {
      _generateAsteroidShape();
    }
  }

  void _generateAsteroidShape() {
    // Generate a random, irregular polygon for the asteroid
    final int points = 8 + _random.nextInt(4); // 8-11 points
    final double r = size.x / 2;
    final Offset c = Offset(size.x / 2, size.y / 2);
    _asteroidPoints = List.generate(points, (i) {
      final angle = (2 * pi / points) * i;
      final radius = r * (0.7 + _random.nextDouble() * 0.5); // 0.7r to 1.2r
      return Offset(
        c.dx + radius * cos(angle),
        c.dy + radius * sin(angle),
      );
    });
  }

  void shatterAndDestroy() {
    if (_isShattering) return;
    _isShattering = true;
    // Spawn particles
    final parentGame = findGame();
    if (parentGame != null) {
      if (type == EnemyType.asteroid) {
        // Use asteroid polygon fragments
        final paint = Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFFBCAAA4), Color(0xFF6D4C41), Color(0xFF3E2723)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));
        // Break asteroid into polygon fragments
        final List<Path> shapes = [];
        for (int i = 0; i < _asteroidPoints.length; i++) {
          final p0 = _asteroidPoints[i];
          final p1 = _asteroidPoints[(i + 1) % _asteroidPoints.length];
          final center = Offset(size.x / 2, size.y / 2);
          final frag = Path()
            ..moveTo(center.dx, center.dy)
            ..lineTo(p0.dx, p0.dy)
            ..lineTo(p1.dx, p1.dy)
            ..close();
          shapes.add(frag);
        }
        final particles = EnemyShatterParticle.burst(
          position: position,
          paint: paint,
          count: shapes.length,
          size: 16,
          shapes: shapes,
        );
        for (final p in particles) {
          parentGame.add(p);
        }
      } else {
        // Spaceship: use rectangles/triangles as fragments
        final paint = Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFFFF5252), Color(0xFFB71C1C), Color(0xFF232526)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));
        final List<Path> shapes = [
          // Triangle fragments
          (() {
            final path = Path();
            path.moveTo(size.x / 2, size.y);
            path.lineTo(size.x * 0.92, size.y * 0.18);
            path.lineTo(size.x * 0.08, size.y * 0.18);
            path.close();
            return path;
          })(),
          (() {
            final path = Path();
            path.moveTo(size.x / 2, size.y * 0.92);
            path.lineTo(size.x * 0.78, size.y * 0.22);
            path.lineTo(size.x * 0.22, size.y * 0.22);
            path.close();
            return path;
          })(),
        ];
        final particles = EnemyShatterParticle.burst(
          position: position,
          paint: paint,
          count: 8,
          size: 12,
          shapes: shapes,
        );
        for (final p in particles) {
          parentGame.add(p);
        }
      }
    }
    removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    if (_isShattering) {
      // Don't render the enemy if shattering (particles will show)
      return;
    }
    if (type == EnemyType.asteroid) {
      _renderAsteroid(canvas);
    } else {
      _renderSpaceship(canvas);
    }
  }

  void _renderAsteroid(Canvas canvas) {
    final path = Path()..moveTo(_asteroidPoints[0].dx, _asteroidPoints[0].dy);
    for (final p in _asteroidPoints.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    path.close();

    // Main asteroid body
    final gradient = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFBCAAA4), Color(0xFF6D4C41), Color(0xFF3E2723)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));
    canvas.drawPath(path, gradient);

    // Rocky highlights
    final highlightPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0x66FFFFFF), Color(0x00FFFFFF)],
        radius: 0.7,
      ).createShader(Rect.fromCircle(center: Offset(size.x * 0.7, size.y * 0.3), radius: 10));
    canvas.drawCircle(Offset(size.x * 0.7, size.y * 0.3), 10, highlightPaint);

    // Shadow
    final shadowPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0x44000000), Color(0x00000000)],
        radius: 1.0,
      ).createShader(Rect.fromCircle(center: Offset(size.x * 0.4, size.y * 0.8), radius: 16));
    canvas.drawCircle(Offset(size.x * 0.4, size.y * 0.8), 16, shadowPaint);
  }

  void _renderSpaceship(Canvas canvas) {
    // Main body (downward triangle)
    final bodyPath = Path();
    bodyPath.moveTo(size.x / 2, size.y); // Bottom (nose, facing down)
    bodyPath.lineTo(size.x * 0.92, size.y * 0.18); // Top right
    bodyPath.lineTo(size.x * 0.08, size.y * 0.18); // Top left
    bodyPath.close();

    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFF5252), Color(0xFFB71C1C), Color(0xFF232526)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));
    canvas.drawPath(bodyPath, bodyPaint);

    // Layered inner body for depth
    final innerBodyPath = Path();
    innerBodyPath.moveTo(size.x / 2, size.y * 0.92);
    innerBodyPath.lineTo(size.x * 0.78, size.y * 0.22);
    innerBodyPath.lineTo(size.x * 0.22, size.y * 0.22);
    innerBodyPath.close();
    final innerBodyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFEF9A9A), Color(0xFFB71C1C)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));
    canvas.drawPath(innerBodyPath, innerBodyPaint);

    // Cockpit (ellipse near the tip, with reflection)
    final cockpitRect = Rect.fromLTWH(size.x/2 - 7, size.y - 22, 14, 16);
    final cockpitPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xCCFFFFFF), Color(0xFFB3E5FC), Color(0x00000000)],
        stops: [0.0, 0.5, 1.0],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(cockpitRect);
    canvas.drawOval(cockpitRect, cockpitPaint);
    // Cockpit reflection
    final reflectionPaint = Paint()..color = Colors.white.withOpacity(0.18);
    canvas.drawArc(cockpitRect.deflate(2), -0.8, 1.2, false, reflectionPaint);

    // Wings (sharper, with highlights)
    final wingPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFB0BEC5), Color(0xFF263238)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));
    final leftWing = Path()
      ..moveTo(size.x * 0.13, size.y * 0.22)
      ..lineTo(0, size.y * 0.75)
      ..lineTo(size.x * 0.28, size.y * 0.7)
      ..close();
    final rightWing = Path()
      ..moveTo(size.x * 0.87, size.y * 0.22)
      ..lineTo(size.x, size.y * 0.75)
      ..lineTo(size.x * 0.72, size.y * 0.7)
      ..close();
    canvas.drawPath(leftWing, wingPaint);
    canvas.drawPath(rightWing, wingPaint);
    // Wing highlights
    final wingHighlightPaint = Paint()..color = Colors.white.withOpacity(0.10);
    canvas.drawLine(
      Offset(size.x * 0.13, size.y * 0.22),
      Offset(size.x * 0.28, size.y * 0.7),
      wingHighlightPaint..strokeWidth = 2,
    );
    canvas.drawLine(
      Offset(size.x * 0.87, size.y * 0.22),
      Offset(size.x * 0.72, size.y * 0.7),
      wingHighlightPaint..strokeWidth = 2,
    );

    // Central accent
    final accentPaint = Paint()..color = const Color(0x44FF5252);
    canvas.drawRect(Rect.fromLTWH(size.x/2 - 4, size.y * 0.3, 8, size.y * 0.45), accentPaint);

    // Glowing engine at the tip
    final enginePaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFFFF176), Color(0x00FFF176)],
        radius: 1.0,
      ).createShader(Rect.fromCircle(center: Offset(size.x/2, size.y), radius: 8));
    canvas.drawCircle(Offset(size.x/2, size.y), 8, enginePaint);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_isShattering) {
      // Don't update if shattering (removed instantly)
      return;
    }
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