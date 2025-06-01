import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'dart:ui';

class BackgroundComponent extends Component with HasGameRef<FlameGame> {
  final String imagePath;
  final double bgScale;
  final int priority;
  Sprite? sprite;
  Vector2? size;
  double scrollY = 0;
  static const double scrollSpeed = 80; // pixels per second

  BackgroundComponent({
    required this.imagePath,
    required this.bgScale,
    this.priority = -1,
  });

  Future<void> loadSprite([String? overridePath]) async {
    final path = overridePath ?? imagePath;
    sprite = await gameRef.loadSprite(path);
    size = sprite!.srcSize * bgScale;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (sprite == null || size == null) return;
    scrollY -= scrollSpeed * dt;
    if (scrollY < 0) {
      scrollY += size!.y;
    }
  }

  @override
  void render(Canvas canvas) {
    if (sprite == null || size == null) return;
    final y1 = -scrollY;
    final y2 = y1 + size!.y;
    sprite!.render(
      canvas,
      position: Vector2(0, y1),
      size: size!,
    );
    // Draw a second copy above if needed
    if (y2 < gameRef.size.y) {
      sprite!.render(
        canvas,
        position: Vector2(0, y2),
        size: size!,
      );
    }
  }
} 