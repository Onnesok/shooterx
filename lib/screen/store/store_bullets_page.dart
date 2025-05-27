import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../game/shooterx_game.dart';
import '../../game/game_bloc.dart' as bloc;

class StoreBulletsPage extends StatelessWidget {
  final ShooterXGame game;
  const StoreBulletsPage({Key? key, required this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<bloc.GameBloc, bloc.GameState>(
      builder: (context, state) {
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
          itemCount: game.bulletTypes.length,
          separatorBuilder: (context, idx) => const Divider(height: 1, color: Colors.white12),
          itemBuilder: (context, idx) {
            final bt = game.bulletTypes[idx];
            final isUnlocked = state.unlockedBullets.contains(bt['id'].toString());
            final isSelected = state.selectedBullet == bt['id'].toString();
            final canBuy = state.totalPoints >= (bt['price'] as int);
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.amber.withOpacity(0.13),
                radius: 28,
                child: Icon(bt['icon'], color: Colors.amber, size: 28),
              ),
              title: Text(
                bt['name'],
                style: TextStyle(
                  color: isSelected ? Colors.amber : Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  fontSize: 18,
                  letterSpacing: 0.5,
                ),
              ),
              subtitle: bt['price'] == 1
                  ? const Text('Default', style: TextStyle(color: Colors.white70, fontSize: 13))
                  : isUnlocked
                      ? const Text('Unlocked', style: TextStyle(color: Colors.greenAccent, fontSize: 13))
                      : Text('Price: ${bt['price']} pts', style: TextStyle(color: canBuy ? Colors.amber : Colors.redAccent, fontSize: 13)),
              trailing: isUnlocked
                  ? (isSelected
                      ? const Icon(Icons.check_circle, color: Colors.greenAccent, size: 28)
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          onPressed: () {
                            context.read<bloc.GameBloc>().add(bloc.SelectBullet(bt['id'].toString()));
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
                              context.read<bloc.GameBloc>().add(bloc.SpendPoints(bt['price'] as int));
                              context.read<bloc.GameBloc>().add(bloc.UnlockBullet(bt['id'].toString()));
                            }
                          : () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Not enough points to buy this bullet type!'),
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