import 'package:flame/components.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'bullet.dart';
import 'enemy_shatter_particle.dart';
import '../game/shooterx_game.dart';

enum EnemyType { asteroid, spaceship, red2, red3 }

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
          size: type == EnemyType.asteroid
              ? Vector2(32, 32)
              : (type == EnemyType.red2)
                  ? Vector2(56, 56)
                  : (type == EnemyType.red3)
                      ? Vector2(64, 64)
                      : Vector2(52, 52),
        ) {
    debugMode = false;
    nextShoot = 1 + _random.nextDouble() * 1.5; // random between 0.7 and 1.7s
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
      } else if (type == EnemyType.red2 || type == EnemyType.red3) {
        // Red ships: improved shatter effect, more particles, color variation
        final baseColors = [Color(0xFFD32F2F), Color(0xFFB71C1C), Color(0xFF232526)];
        final paint = Paint()
          ..shader = LinearGradient(
            colors: [
              baseColors[0],
              baseColors[1],
              baseColors[2],
              Color.lerp(baseColors[0], Colors.white, 0.18)!,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));
        final List<Path> shapes = [
          // Small triangle
          (() {
            final path = Path();
            path.moveTo(3, 0);
            path.lineTo(6, 6);
            path.lineTo(0, 6);
            path.close();
            return path;
          })(),
          // Small rectangle
          (() {
            final path = Path();
            path.addRect(Rect.fromLTWH(0, 0, 6, 3));
            return path;
          })(),
          // Skewed rectangle
          (() {
            final path = Path();
            path.moveTo(0, 0);
            path.lineTo(6, 1);
            path.lineTo(5, 6);
            path.lineTo(1, 5);
            path.close();
            return path;
          })(),
        ];
        final center = position + size / 2;
        final particles = [
          ...EnemyShatterParticle.burst(
            position: center,
            paint: paint,
            count: 18,
            size: 7,
            shapes: shapes,
          ),
          ...EnemyShatterParticle.burst(
            position: center,
            paint: Paint()
              ..shader = LinearGradient(
                colors: [
                  Color.lerp(baseColors[0], Colors.yellow, 0.18)!,
                  baseColors[1],
                  baseColors[2],
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(Rect.fromLTWH(0, 0, size.x, size.y)),
            count: 8,
            size: 11,
            shapes: shapes,
          ),
        ];
        for (final p in particles) {
          parentGame.add(p);
        }
      } else {
        // Spaceship: use asteroid-like polygonal fragments for shatter
        final paint = Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFFFF5252), Color(0xFFB71C1C), Color(0xFF232526)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));
        final int fragCount = 8;
        final double r = size.x / 2;
        final Offset c = Offset(size.x / 2, size.y / 2);
        final List<Path> shapes = List.generate(fragCount, (i) {
          final angle = (2 * pi / fragCount) * i;
          final nextAngle = (2 * pi / fragCount) * (i + 1);
          final radius1 = r * (0.7 + _random.nextDouble() * 0.3);
          final radius2 = r * (0.7 + _random.nextDouble() * 0.3);
          final p0 = Offset(c.dx + radius1 * cos(angle), c.dy + radius1 * sin(angle));
          final p1 = Offset(c.dx + radius2 * cos(nextAngle), c.dy + radius2 * sin(nextAngle));
          final path = Path()
            ..moveTo(c.dx, c.dy)
            ..lineTo(p0.dx, p0.dy)
            ..lineTo(p1.dx, p1.dy) 
            ..close();
          return path;
        });
        final particles = EnemyShatterParticle.burst(
          position: position,
          paint: paint,
          count: fragCount,
          size: 10,
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
    } else if (type == EnemyType.spaceship) {
      _renderSpaceship(canvas);
    } else if (type == EnemyType.red2) {
      _renderRedSpaceship(canvas, '02/Spaceship_02_RED.png');
    } else if (type == EnemyType.red3) {
      _renderRedSpaceship(canvas, '03/Spaceship_03_RED.png');
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

  static final Map<String, Sprite?> _spriteCache = {};
  Future<Sprite> _getSprite(String path) async {
    if (_spriteCache[path] != null) return _spriteCache[path]!;
    final game = findGame();
    final sprite = await Sprite.load(path);
    _spriteCache[path] = sprite;
    return sprite;
  }

  void _renderRedSpaceship(Canvas canvas, String path) {
    // This is a hack: Flame's render is not async, so we draw a placeholder and schedule a repaint
    final sprite = _spriteCache[path];
    if (sprite != null) {
      canvas.save();
      // Move to center, rotate 180deg, move back
      canvas.translate(size.x / 2, size.y / 2);
      canvas.rotate(pi); // 180 degrees
      canvas.translate(-size.x / 2, -size.y / 2);
      sprite.render(canvas, position: Vector2.zero(), size: size);
      canvas.restore();
    } else {
      // Draw a placeholder
      final paint = Paint()..color = const Color(0xFFB71C1C);
      canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), paint);
      // Schedule sprite load and repaint
      _getSprite(path);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_isShattering) {
      // Don't update if shattering (removed instantly)
      return;
    }
    // --- Attraction to player ---
    final game = findGame() as ShooterXGame?;
    if (game != null && game.player.parent != null) {
      final playerPos = game.player.position + game.player.size / 2;
      final enemyPos = position + size / 2;
      final toPlayer = (playerPos - enemyPos);
      if (toPlayer.length > 1) {
        // Attraction strength (smaller = more subtle)
        final steer = toPlayer.normalized() * (speed * 0.6) * dt;
        position += Vector2(steer.x, 0); // Only adjust x (horizontal) for classic shooter feel
      }
    }
    position.y += speed * dt;
    if (position.y > findGame()!.size.y) {
      removeFromParent();
    }
    // Shooting logic
    shootTimer += dt;
    if ((type == EnemyType.spaceship || type == EnemyType.red2 || type == EnemyType.red3) && shootTimer >= nextShoot && position.y > 0 && position.y < findGame()!.size.y - size.y) {
      shootTimer = 0;
      nextShoot = 0.7 + _random.nextDouble() * 1.0;
      parent?.add(EnemyBullet(position: position + Vector2(size.x / 2 - 4, size.y)));
    }
  }
} 