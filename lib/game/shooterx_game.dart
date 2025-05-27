import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flame/input.dart';
import '../components/player.dart';
import '../components/bullet.dart';
import '../components/enemy.dart';
import 'package:flutter/painting.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screen/store_overlay.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'game_bloc.dart';

enum GameState { playing, gameOver }
enum FireStyle { normal, fire, plasma, laser, explosive }
enum StoreBulletType { classic, split, spread, group, explosive }

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
  static const double parallaxFactor = 0.2; // Background moves at 20% of player movement (slower)
  static const double bgScale = 1.5; // Background is scaled up 1.5x

  // List of all background image paths
  final List<String> backgroundPaths = [
    // Blue Nebula
    'Blue_Nebula/Blue_Nebula_01.png',
    'Blue_Nebula/Blue_Nebula_02.png',
    'Blue_Nebula/Blue_Nebula_03.png',
    'Blue_Nebula/Blue_Nebula_04.png',
    // Green Nebula
    'Green_Nebula/Green_Nebula_01.png',
    'Green_Nebula/Green_Nebula_02.png',
    'Green_Nebula/Green_Nebula_03.png',
    'Green_Nebula/Green_Nebula_04.png',
    // Purple Nebula
    'Purple_Nebula/Purple_Nebula_01.png',
    'Purple_Nebula/Purple_Nebula_02.png',
    'Purple_Nebula/Purple_Nebula_03.png',
    'Purple_Nebula/Purple_Nebula_04.png',
    'Purple_Nebula/Purple_Nebula_05.png',
    // Starfields
    'Starfields/Starfield_01.png',
    'Starfields/Starfield_02.png',
    'Starfields/Starfield_03.png',
    'Starfields/Starfield_04.png',
    'Starfields/Starfield_05.png',
  ];
  int currentBackgroundIndex = 0;
  double backgroundChangeTimer = 0;
  final double backgroundChangeInterval = 60.0; // seconds (1 minute)
  late Player player;
  SpriteComponent? gameBackground;
  double enemySpawnTimer = 0;
  double currentEnemySpawnInterval = 1.2; // seconds, will decrease
  double currentEnemySpeed = 120; // will increase
  final Random _random = Random();
  ValueNotifier<int> score = ValueNotifier<int>(0);
  GameState state = GameState.playing;
  late JoystickComponent joystick;
  late HudButtonComponent shootButton;
  late HudButtonComponent pauseButton;
  
  Vector2? _prevPlayerPosition; // For tracking player movement delta
  FireStyle fireStyle = FireStyle.normal;
  final GameBloc gameBloc;
  ShooterXGame({required this.gameBloc});

  // Skins and bullet types for the store
  final List<Map<String, dynamic>> skins = const [
    {'id': 0, 'name': 'Classic', 'price': 0, 'color': Colors.cyan},
    {'id': 1, 'name': 'Blue Nova', 'price': 2000, 'color': Colors.blueAccent},
    {'id': 2, 'name': 'Emerald', 'price': 2500, 'color': Colors.greenAccent},
    {'id': 3, 'name': 'Violet', 'price': 3000, 'color': Colors.purpleAccent},
    {'id': 4, 'name': 'Gold', 'price': 3500, 'color': Colors.amber},
  ];

  final List<Map<String, dynamic>> bulletTypes = const [
    {'id': 0, 'name': 'Classic', 'price': 0, 'icon': Icons.circle},
    {'id': 1, 'name': 'Split', 'price': 3000, 'icon': Icons.call_split},
    {'id': 2, 'name': 'Spread', 'price': 3500, 'icon': Icons.double_arrow},
    {'id': 3, 'name': 'Group', 'price': 4000, 'icon': Icons.burst_mode},
  ];

  @override
  Future<void> onLoad() async {
    // Ensure BLoC loads state from SharedPreferences first
    gameBloc.add(LoadGameState());
    await Future.delayed(Duration(milliseconds: 50)); // Give BLoC a moment to update state
    // Load a random background image and add as the first component
    currentBackgroundIndex = _random.nextInt(backgroundPaths.length);
    final bgSprite = await loadSprite(backgroundPaths[currentBackgroundIndex]);
    print('Background sprite loaded: $bgSprite');
    final bgComponent = SpriteComponent(
      sprite: bgSprite,
      size: bgSprite.srcSize * bgScale, // Scale up the background
      anchor: Anchor.topLeft,
      position: Vector2.zero(),
      priority: -1, // Ensure it renders behind everything
    );
    add(bgComponent);
    gameBackground = bgComponent;
    player = Player();
    player.shootCallback = shoot;
    add(player);
    await Future.delayed(Duration.zero); // Wait for game size
    player.position = Vector2((size.x - player.size.x) / 2, size.y - player.size.y - 20);
    _prevPlayerPosition = player.position.clone(); // Initialize previous position
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
      onPressed: () => player.shootCallback?.call(
        Vector2(
          player.position.x + player.size.x / 2,
          player.position.y,
        ),
      ),
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

    state = GameState.playing;
    overlays.add('Welcome');
    overlays.remove('Score');
    overlays.remove('GameOver');
    pauseEngine();
    await _loadUnlockedSkins();
    await _loadUnlockedBulletTypes();
    // Listen to GameBloc state changes for skin and bullet type
    gameBloc.stream.listen((state) {
      player.skinId = int.tryParse(state.selectedSkin) ?? 0;
      // If you have a bullet type property, update it here as well
      // selectedBulletType = int.tryParse(state.selectedBullet) ?? 0;
    });
    // Set initial skin and bullet type from bloc state
    player.skinId = int.tryParse(gameBloc.state.selectedSkin) ?? 0;
    // selectedBulletType = int.tryParse(gameBloc.state.selectedBullet) ?? 0;
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
    // --- Parallax enemy movement (match new background movement) ---
    if (_prevPlayerPosition != null) {
      final playerDelta = player.position - _prevPlayerPosition!;
      if (playerDelta.length != 0) {
        final parallaxDelta = playerDelta * parallaxFactor;
        for (final enemy in children.whereType<Enemy>()) {
          enemy.position -= parallaxDelta;
        }
      }
      _prevPlayerPosition = player.position.clone();
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
      final isAsteroid = _random.nextBool();
      add(Enemy(
        position: Vector2(x, 0),
        type: isAsteroid ? EnemyType.asteroid : EnemyType.spaceship,
        speed: currentEnemySpeed,
      ));
    }
    // Collision detection
    final bullets = children.whereType<Bullet>().toList();
    final enemies = children.whereType<Enemy>().toList();
    for (final bullet in bullets) {
      for (final enemy in enemies) {
        if (bullet.toRect().overlaps(enemy.toRect())) {
          bullet.removeFromParent();
          enemy.removeFromParent();
          gameBloc.add(AddPoints(1));
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
    // Move background with player (parallax)
    if (gameBackground != null) {
      // Calculate offset so player stays centered, but move background slower (parallax)
      final bgOffset = Vector2(
        -(player.position.x + player.size.x / 2 - size.x / 2) * parallaxFactor,
        -(player.position.y + player.size.y / 2 - size.y / 2) * parallaxFactor,
      );
      // Clamp so background doesn't show outside edges
      bgOffset.x = bgOffset.x.clamp(size.x - gameBackground!.size.x, 0);
      bgOffset.y = bgOffset.y.clamp(size.y - gameBackground!.size.y, 0);
      gameBackground!.position = bgOffset;
    }
    // Cycle background over time
    backgroundChangeTimer += dt;
    if (backgroundChangeTimer >= backgroundChangeInterval) {
      backgroundChangeTimer = 0;
      currentBackgroundIndex = (currentBackgroundIndex + 1) % backgroundPaths.length;
      _changeBackground(backgroundPaths[currentBackgroundIndex]);
    }
  }

  void shoot(Vector2 position) {
    if (state == GameState.playing) {
      final bulletType = int.tryParse(gameBloc.state.selectedBullet) ?? 0;
      switch (bulletType) {
        case 0: // Classic
          add(Bullet(position: position, type: BulletType.normal));
          break;
        case 1: // Split
          add(SplitBullet(position: position));
          break;
        case 2: // Spread
          for (final angle in [-0.25, 0.0, 0.25]) {
            add(BulletWithAngle(position: position, angle: angle));
          }
          break;
        case 3: // Group
          for (final offset in [-12.0, 0.0, 12.0]) {
            add(Bullet(position: position + Vector2(offset, 0), type: BulletType.normal));
          }
          break;
      }
    }
  }

  void gameOver() async {
    state = GameState.gameOver;
    overlays.remove('Score');
    overlays.add('GameOver');
    // Update high score if needed
    final prefs = await SharedPreferences.getInstance();
    final currentScore = gameBloc.state.score;
    final highScore = prefs.getInt('highScore') ?? 0;
    if (currentScore > highScore) {
      await prefs.setInt('highScore', currentScore);
    }
  }

  void restart() {
    children.whereType<Bullet>().forEach((b) => b.removeFromParent());
    children.whereType<Enemy>().forEach((e) => e.removeFromParent());
    player.position = Vector2((size.x - player.size.x) / 2, size.y - player.size.y - 20);
    gameBloc.add(ResetScore());
    state = GameState.playing;
    overlays.add('Score');
    overlays.remove('GameOver');
    // Pick a new random background and update it
    currentBackgroundIndex = _random.nextInt(backgroundPaths.length);
    _changeBackground(backgroundPaths[currentBackgroundIndex]);
    backgroundChangeTimer = 0;
    fireStyle = FireStyle.normal;
  }

  void startGame() {
    // Reset everything as in restart()
    children.whereType<Bullet>().forEach((b) => b.removeFromParent());
    children.whereType<Enemy>().forEach((e) => e.removeFromParent());
    player.position = Vector2((size.x - player.size.x) / 2, size.y - player.size.y - 20);
    gameBloc.add(ResetScore());
    state = GameState.playing;
    overlays.add('Score');
    overlays.remove('Welcome');
    overlays.remove('GameOver');
    // Pick a new random background and update it
    currentBackgroundIndex = _random.nextInt(backgroundPaths.length);
    _changeBackground(backgroundPaths[currentBackgroundIndex]);
    backgroundChangeTimer = 0;
    resumeEngine();
    fireStyle = FireStyle.normal;
  }

  void openStore() {
    overlays.add('Store');
    pauseEngine();
  }

  @override
  Color backgroundColor() => const Color(0xFF000010);

  @override
  void onGameResize(Vector2 newSize) {
    super.onGameResize(newSize);
    // Do NOT resize the background to the new size!
    // If you want to support different screen sizes, use a background image that is large enough.
  }

  Future<void> _changeBackground(String path) async {
    if (gameBackground != null) {
      final newSprite = await loadSprite(path);
      gameBackground!.sprite = newSprite;
      gameBackground!.size = newSprite.srcSize * bgScale;
    }
  }

  Future<void> _loadUnlockedSkins() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('unlockedSkins');
    if (list != null) {
      for (final id in list) {
        gameBloc.add(UnlockSkin(id));
      }
    } else {
      gameBloc.add(UnlockSkin('0'));
    }
  }

  bool isSkinUnlocked(int id) => gameBloc.state.unlockedSkins.contains(id.toString());

  void unlockSkin(int id) {
    gameBloc.add(UnlockSkin(id.toString()));
  }

  void selectSkin(int id, {bool unlockIfNeeded = false}) {
    if (!isSkinUnlocked(id) && unlockIfNeeded) {
      unlockSkin(id);
    }
    gameBloc.add(SelectSkin(id.toString()));
  }

  Future<void> _loadUnlockedBulletTypes() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('unlockedBulletTypes');
    if (list != null) {
      for (final id in list) {
        gameBloc.add(UnlockBullet(id));
      }
    } else {
      gameBloc.add(UnlockBullet('0'));
    }
  }

  Future<void> _saveUnlockedBulletTypes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('unlockedBulletTypes', gameBloc.state.unlockedBullets.map((e) => e.toString()).toList());
  }

  bool isBulletTypeUnlocked(int id) => gameBloc.state.unlockedBullets.contains(id.toString());

  void unlockBulletType(int id) {
    gameBloc.add(UnlockBullet(id.toString()));
  }

  Future<int?> _loadSelectedBulletType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('selectedBulletType');
  }

  Future<void> _saveSelectedBulletType(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedBulletType', id);
  }

  void selectBulletType(int id, {bool unlockIfNeeded = false}) {
    if (!isBulletTypeUnlocked(id) && unlockIfNeeded) {
      unlockBulletType(id);
    }
    gameBloc.add(SelectBullet(id.toString()));
    // selectedBulletType will be updated by the bloc listener if needed
  }
} 