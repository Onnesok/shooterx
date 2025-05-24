import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flame/input.dart';
import '../components/player.dart';
import '../components/bullet.dart';
import '../components/enemy.dart';

enum GameState { playing, gameOver }

// Custom arc highlight component for glassy effect
class GlassyArcComponent extends PositionComponent {
  final double radius;
  final double startAngle;
  final double sweepAngle;
  final double strokeWidth;
  final Color color;
  GlassyArcComponent({
    required Vector2 center,
    required this.radius,
    required this.startAngle,
    required this.sweepAngle,
    required this.strokeWidth,
    required this.color,
  }) : super(
          position: center - Vector2.all(radius),
          size: Vector2.all(radius * 2),
        );

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(radius, radius), radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }
}

class ShooterXGame extends FlameGame {
  late Player player;
  double enemySpawnTimer = 0;
  double currentEnemySpawnInterval = 1.2; // seconds, will decrease
  double currentEnemySpeed = 120; // will increase
  final Random _random = Random();
  ValueNotifier<int> score = ValueNotifier<int>(0);
  GameState state = GameState.playing;
  late JoystickComponent joystick;
  late HudButtonComponent shootButton;
  late HudButtonComponent pauseButton;

  @override
  Future<void> onLoad() async {
    player = Player();
    player.shootCallback = shoot;
    add(player);
    await Future.delayed(Duration.zero); // Wait for game size
    player.position = Vector2((size.x - player.size.x) / 2, size.y - player.size.y - 20);
    joystick = JoystickComponent(
      knob: CircleComponent(
        radius: 36,
        paint: Paint()
          ..shader = ui.Gradient.radial(
            const Offset(36, 36),
            36,
            [
              const Color(0xFFFFFFFF),
              const Color(0xFF4F8FFF),
              const Color(0xFF1E2A78),
            ],
            [0.0, 0.5, 1.0],
          )
          ..style = PaintingStyle.fill,
      )
        ..add(CircleComponent(
          radius: 36,
          paint: Paint()
            ..color = const Color(0xFF4F8FFF).withOpacity(0.2)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4,
        )),
      background: CircleComponent(
        radius: 70,
        paint: Paint()
          ..shader = ui.Gradient.radial(
            const Offset(70, 70),
            70,
            [
              const Color(0x334F8FFF),
              const Color(0x11000000),
            ],
          ),
      )
        ..add(CircleComponent(
          radius: 70,
          paint: Paint()
            ..color = const Color(0xFF4F8FFF).withOpacity(0.15)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4,
        )),
      margin: const EdgeInsets.only(left: 56, bottom: 56),
    );
    add(joystick);

    shootButton = HudButtonComponent(
      button: CircleComponent(
        radius: 40,
        paint: Paint()
          ..shader = ui.Gradient.radial(
            const Offset(40, 40),
            40,
            [
              const Color(0x33FFF176),
              const Color(0x99FFA000),
              const Color(0xFFFF6F00),
              const Color(0xFFB74D00),
            ],
            [0.0, 0.4, 0.8, 1.0],
          )
          ..style = PaintingStyle.fill,
        children: [
          // Outer colored glow
          CircleComponent(
            radius: 44,
            paint: Paint()
              ..color = const Color(0x33FF9800)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
          ),
          // Inner shadow (for glassy depth)
          CircleComponent(
            radius: 40,
            paint: Paint()
              ..shader = ui.Gradient.radial(
                const Offset(40, 40),
                40,
                [
                  Colors.transparent,
                  const Color(0x22000000),
                ],
                [0.7, 1.0],
              )
              ..blendMode = BlendMode.darken,
          ),
    

          GlassyArcComponent(
            center: Vector2(40, 40),
            radius: 32,
            startAngle: -2.2,
            sweepAngle: 1.2,
            strokeWidth: 8,
            color: Colors.white.withOpacity(0.18),
          ),

          // Outer flame/arrow (soft glow)
          PolygonComponent(
            [
              Vector2(40, 20),
              Vector2(26, 44),
              Vector2(40, 36),
              Vector2(54, 44),
            ],
            paint: Paint()
              ..color = const Color(0x66FFB300)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
          ),
          // Inner flame/arrow (sharp, bright)
          PolygonComponent(
            [
              Vector2(40, 24),
              Vector2(30, 40),
              Vector2(40, 34),
              Vector2(50, 40),
            ],
            paint: Paint()
              ..color = const Color(0xFFFFF176)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
          ),
        ],
      ),
      buttonDown: CircleComponent(
        radius: 40,
        paint: Paint()
          ..shader = ui.Gradient.radial(
            const Offset(40, 40),
            40,
            [
              const Color(0xCCFFA000),
              const Color(0xFFFFF176),
            ],
          )
          ..style = PaintingStyle.fill,
        children: [
          CircleComponent(
            radius: 44,
            paint: Paint()
              ..color = const Color(0x44FF9800)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
          ),
          GlassyArcComponent(
            center: Vector2(40, 40),
            radius: 32,
            startAngle: -2.2,
            sweepAngle: 1.2,
            strokeWidth: 8,
            color: Colors.white.withOpacity(0.22),
          ),
          PolygonComponent(
            [
              Vector2(40, 20),
              Vector2(26, 44),
              Vector2(40, 36),
              Vector2(54, 44),
            ],
            paint: Paint()
              ..color = const Color(0x99FFB300)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
          ),
          PolygonComponent(
            [
              Vector2(40, 24),
              Vector2(30, 40),
              Vector2(40, 34),
              Vector2(50, 40),
            ],
            paint: Paint()
              ..color = const Color(0xFFFFF176)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
          ),
        ],
      ),
      margin: const EdgeInsets.only(right: 56, bottom: 56),
      onPressed: () => player.shootCallback?.call(player.position + Vector2(player.size.x / 2 - 4, -10)),
    );
    add(shootButton);

    // Add pause button (top right)
    pauseButton = HudButtonComponent(
      button: CircleComponent(
        radius: 28,
        paint: Paint()..color = const Color.fromRGBO(255, 255, 255, 0.4),
        children: [
          RectangleComponent(
            position: Vector2(18, 16),
            size: Vector2(6, 24),
            paint: Paint()..color = Colors.black,
          ),
          RectangleComponent(
            position: Vector2(32, 16),
            size: Vector2(6, 24),
            paint: Paint()..color = Colors.black,
          ),
        ],
      ),
      buttonDown: CircleComponent(
        radius: 28,
        paint: Paint()..color = const Color.fromRGBO(255, 255, 255, 0.7),
        children: [
          RectangleComponent(
            position: Vector2(18, 16),
            size: Vector2(6, 24),
            paint: Paint()..color = Colors.black,
          ),
          RectangleComponent(
            position: Vector2(32, 16),
            size: Vector2(6, 24),
            paint: Paint()..color = Colors.black,
          ),
        ],
      ),
      margin: const EdgeInsets.only(top: 40, right: 40),
      onPressed: () {
        pauseEngine();
        overlays.add('Paused');
      },
    );
    add(pauseButton);

    score.value = 0;
    state = GameState.playing;
    overlays.add('Welcome');
    overlays.remove('Score');
    overlays.remove('GameOver');
    pauseEngine();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (state != GameState.playing) return;
    // Joystick movement (all directions)
    if (joystick.delta.length > 0.1) {
      player.moveDirection = joystick.relativeDelta.normalized();
    } else {
      player.moveDirection = Vector2.zero();
    }
    // Dynamic difficulty scaling
    currentEnemySpeed = 120 + score.value * 4;
    if (currentEnemySpeed > 350) currentEnemySpeed = 350;
    currentEnemySpawnInterval = 1.2 - (score.value * 0.015);
    if (currentEnemySpawnInterval < 0.5) currentEnemySpawnInterval = 0.5;
    // Enemy spawn logic
    enemySpawnTimer += dt;
    if (enemySpawnTimer >= currentEnemySpawnInterval) {
      enemySpawnTimer = 0;
      final x = (size.x - 40) * (_random.nextDouble());
      final type = EnemyType.values[_random.nextInt(EnemyType.values.length)];
      add(Enemy(position: Vector2(x, 0), type: type, speed: currentEnemySpeed));
    }
    // Collision detection
    final bullets = children.whereType<Bullet>().toList();
    final enemies = children.whereType<Enemy>().toList();
    for (final bullet in bullets) {
      for (final enemy in enemies) {
        if (bullet.toRect().overlaps(enemy.toRect())) {
          bullet.removeFromParent();
          enemy.removeFromParent();
          score.value += 1;
        }
      }
    }
    // Game over if player collides with any enemy (only if enemy is above player's bottom)
    for (final enemy in enemies) {
      if (
        enemy.position.y + enemy.size.y > player.position.y &&
        enemy.toRect().overlaps(player.toRect())
      ) {
        gameOver();
        break;
      }
    }
    // Game over if player is hit by any enemy bullet
    final enemyBullets = children.whereType<EnemyBullet>().toList();
    for (final bullet in enemyBullets) {
      if (bullet.toRect().overlaps(player.toRect())) {
        gameOver();
        break;
      }
    }
  }

  void shoot(Vector2 position) {
    if (state == GameState.playing) {
      add(Bullet(position: position));
    }
  }

  void gameOver() {
    state = GameState.gameOver;
    overlays.remove('Score');
    overlays.add('GameOver');
  }

  void restart() {
    children.whereType<Bullet>().forEach((b) => b.removeFromParent());
    children.whereType<Enemy>().forEach((e) => e.removeFromParent());
    player.position = Vector2((size.x - player.size.x) / 2, size.y - player.size.y - 20);
    score.value = 0;
    state = GameState.playing;
    overlays.add('Score');
    overlays.remove('GameOver');
  }

  void startGame() {
    score.value = 0;
    state = GameState.playing;
    overlays.add('Score');
    overlays.remove('Welcome');
    overlays.remove('GameOver');
    resumeEngine();
  }

  @override
  Color backgroundColor() => const Color(0xFF000010);
} 