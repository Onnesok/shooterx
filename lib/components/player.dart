import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/painting.dart';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flame/sprite.dart';

class Player extends PositionComponent {
  static const double speed = 300;
  Vector2 moveDirection = Vector2.zero();
  double shootCooldown = 0;
  void Function(Vector2 position)? shootCallback;
  int skinId = 0;
  int life = 1;

  Player() : super(position: Vector2(200, 500), size: Vector2(56, 56)) {
    debugMode = false;
    add(RectangleComponent(
      position: size * 0.2,
      size: size * 0.6,
      paint: Paint()..color = const Color(0x00000000), // transparent
      priority: 1,
    )..debugMode = false);
  }

  @override
  void render(Canvas canvas) {
    // Use the store's skins list for all player skins
    final skins = (findGame() as dynamic)?.skins;
    String? imagePath;
    if (skins != null) {
      final Map<String, dynamic> skin = (skins as List)
        .cast<Map<String, dynamic>>()
        .firstWhere(
          (s) => s['id'] == skinId,
          orElse: () => skins[0] as Map<String, dynamic>,
        );
      imagePath = skin['imagePath'] as String?;
    }
    imagePath ??= '01/Spaceship_01_GREEN.png'; // fallback default
    _renderSkinSprite(canvas, imagePath);
    return;
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

  static final Map<String, Sprite?> _playerSpriteCache = {};
  Future<Sprite> _getPlayerSprite(String path) async {
    if (_playerSpriteCache[path] != null) return _playerSpriteCache[path]!;
    final sprite = await Sprite.load(path);
    _playerSpriteCache[path] = sprite;
    return sprite;
  }

  void _renderSkinSprite(Canvas canvas, String path) {
    final sprite = _playerSpriteCache[path];
    if (sprite != null) {
      // Draw right-side up (no rotation)
      sprite.render(canvas, position: Vector2.zero(), size: size);
    } else {
      // Draw a placeholder and schedule sprite load
      final paint = Paint()..color = const Color(0xFF1976D2);
      canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), paint);
      _getPlayerSprite(path);
    }
  }
} 