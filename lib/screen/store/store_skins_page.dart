import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../game/shooterx_game.dart';
import '../../game/game_bloc.dart' as bloc;

class StoreSkinsPage extends StatelessWidget {
  final ShooterXGame game;
  const StoreSkinsPage({Key? key, required this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<bloc.GameBloc, bloc.GameState>(
      builder: (context, state) {
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
          itemCount: game.skins.length,
          separatorBuilder: (context, idx) => const Divider(height: 1, color: Colors.white12),
          itemBuilder: (context, idx) {
            final skin = game.skins[idx];
            final isUnlocked = state.unlockedSkins.contains(skin['id'].toString());
            final isSelected = state.selectedSkin == skin['id'].toString();
            final canBuy = state.totalPoints >= (skin['price'] as int);
            return ListTile(
              leading: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: isSelected ? Colors.amber : Colors.white24, width: 3),
                  color: Colors.black,
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/${skin['imagePath']}',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              title: Text(
                skin['name'],
                style: TextStyle(
                  color: isSelected ? Colors.amber : Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  fontSize: 18,
                  letterSpacing: 0.5,
                ),
              ),
              subtitle: skin['price'] == 0
                  ? const Text('Default', style: TextStyle(color: Colors.white70, fontSize: 13))
                  : isUnlocked
                      ? const Text('Unlocked', style: TextStyle(color: Colors.greenAccent, fontSize: 13))
                      : Text('Price: ${skin['price']} pts', style: TextStyle(color: canBuy ? Colors.amber : Colors.redAccent, fontSize: 13)),
              trailing: isUnlocked
                  ? (isSelected
                      ? const Icon(Icons.check_circle, color: Colors.greenAccent, size: 28)
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.cyan,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          onPressed: () {
                            context.read<bloc.GameBloc>().add(bloc.SelectSkin(skin['id'].toString()));
                          },
                          child: const Text('Select'),
                        ))
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canBuy ? Colors.amber : Colors.grey.shade700,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      onPressed: canBuy
                          ? () {
                              context.read<bloc.GameBloc>().add(bloc.SpendPoints(skin['price'] as int));
                              context.read<bloc.GameBloc>().add(bloc.UnlockSkin(skin['id'].toString()));
                            }
                          : () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Not enough points to buy this skin!'),
                                  backgroundColor: Colors.redAccent,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                      child: const Text('Buy'),
                    ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              tileColor: isSelected ? Colors.white.withOpacity(0.07) : Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            );
          },
        );
      },
    );
  }
} 