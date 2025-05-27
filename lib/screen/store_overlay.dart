import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../game/shooterx_game.dart';
import '../game/game_bloc.dart' as bloc;
import 'store/store_skins_page.dart';
import 'store/store_bullets_page.dart';

class StoreOverlay extends StatefulWidget {
  final ShooterXGame game;
  StoreOverlay({Key? key, required this.game}) : super(key: key);

  @override
  State<StoreOverlay> createState() => _StoreOverlayState();
}

class _StoreOverlayState extends State<StoreOverlay> with SingleTickerProviderStateMixin {
  int page = 0; // 0 = main, 1 = skins, 2 = bullets
  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  void _goToPage(int p) {
    _controller.forward(from: 0);
    setState(() => page = p);
  }

  void _goToMain() {
    _controller.reverse();
    setState(() => page = 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background image (like welcome_overlay.dart)
        Positioned.fill(
          child: Image.asset(
            'assets/images/backgrounds/background1.png',
            fit: BoxFit.cover,
          ),
        ),
        // Semi-transparent dark overlay for readability
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.5),
          ),
        ),
        // Main content (no container, just cards and header)
        Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            child: page == 0
                ? _buildMainPage(context)
                : FadeTransition(
                    opacity: _fadeAnim,
                    child: page == 1
                        ? _buildDetailPage(context, 'Player Skins', Icons.person, Colors.cyan, () => _goToMain(), StoreSkinsPage(game: widget.game))
                        : _buildDetailPage(context, 'Bullet Types', Icons.bolt, Colors.amber, () => _goToMain(), StoreBulletsPage(game: widget.game)),
                  ),
          ),
        ),
        // Back button (persistent, floating)
        Positioned(
          left: 20,
          top: 0,
          child: SafeArea(
            child: FloatingActionButton(
              backgroundColor: Colors.black.withOpacity(0.7),
              foregroundColor: Colors.white,
              elevation: 8,
              mini: true,
              onPressed: () {
                if (page == 0) {
                  widget.game.overlays.remove('Store');
                  widget.game.resumeEngine();
                } else {
                  _goToMain();
                }
              },
              child: Icon(page == 0 ? Icons.arrow_back : Icons.arrow_back_ios, size: 28),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainPage(BuildContext context) {
    return BlocBuilder<bloc.GameBloc, bloc.GameState>(
      builder: (context, state) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('STORE', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 2)),
            const SizedBox(height: 8),
            Text(
              'Total Points: ${state.totalPoints}',
              style: const TextStyle(fontSize: 18, color: Colors.amber, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
            const SizedBox(height: 28),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 18,
                runSpacing: 18,
                children: [
                  _glassCard(
                    context,
                    icon: Icons.person,
                    color: Colors.cyan,
                    title: 'Player Skins',
                    subtitle: 'Unlock spaceship looks',
                    onTap: () => _goToPage(1),
                  ),
                  _glassCard(
                    context,
                    icon: Icons.bolt,
                    color: Colors.amber,
                    title: 'Bullet Types',
                    subtitle: 'Unlock bullet styles',
                    onTap: () => _goToPage(2),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _glassCard(BuildContext context, {required IconData icon, required Color color, required String title, required String subtitle, required VoidCallback onTap}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth * 0.28).clamp(90.0, 140.0);
    final cardHeight = 180.0; // Fixed height for all cards
    final iconSize = (cardWidth * 0.32).clamp(24.0, 38.0);
    final titleFontSize = (cardWidth * 0.13).clamp(11.0, 16.0);
    final subtitleFontSize = (cardWidth * 0.10).clamp(9.0, 13.0);

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: cardWidth,
            height: cardHeight,
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.25), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.10),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.18),
                    shape: BoxShape.circle,
                  ),
                  padding: EdgeInsets.all(iconSize * 0.31),
                  child: Icon(icon, color: Colors.white, size: iconSize),
                ),
                SizedBox(height: 10),
                Text(title, style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.bold, color: color, letterSpacing: 0.5)),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: subtitleFontSize, color: Colors.white70),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailPage(BuildContext context, String title, IconData icon, Color color, VoidCallback onBack, Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: color.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(8),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 10),
              Text(title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color, letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: child,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}