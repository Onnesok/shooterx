import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- Events ---
abstract class GameEvent extends Equatable {
  const GameEvent();
  @override
  List<Object?> get props => [];
}

class AddPoints extends GameEvent {
  final int points;
  const AddPoints(this.points);
  @override
  List<Object?> get props => [points];
}

class GainLife extends GameEvent {
  final int amount;
  const GainLife([this.amount = 1]);
  @override
  List<Object?> get props => [amount];
}

class LoseLife extends GameEvent {
  final int amount;
  const LoseLife([this.amount = 1]);
  @override
  List<Object?> get props => [amount];
}

class SpendPoints extends GameEvent {
  final int points;
  const SpendPoints(this.points);
  @override
  List<Object?> get props => [points];
}

class SelectSkin extends GameEvent {
  final String skinId;
  const SelectSkin(this.skinId);
  @override
  List<Object?> get props => [skinId];
}

class UnlockSkin extends GameEvent {
  final String skinId;
  const UnlockSkin(this.skinId);
  @override
  List<Object?> get props => [skinId];
}

class SelectBullet extends GameEvent {
  final String bulletId;
  const SelectBullet(this.bulletId);
  @override
  List<Object?> get props => [bulletId];
}

class UnlockBullet extends GameEvent {
  final String bulletId;
  const UnlockBullet(this.bulletId);
  @override
  List<Object?> get props => [bulletId];
}

class ResetScore extends GameEvent {}
class LoadGameState extends GameEvent {}

// --- State ---
class GameState extends Equatable {
  final int score;
  final int totalPoints;
  final int life;
  final String selectedSkin;
  final Set<String> unlockedSkins;
  final String selectedBullet;
  final Set<String> unlockedBullets;

  const GameState({
    required this.score,
    required this.totalPoints,
    required this.life,
    required this.selectedSkin,
    required this.unlockedSkins,
    required this.selectedBullet,
    required this.unlockedBullets,
  });

  GameState copyWith({
    int? score,
    int? totalPoints,
    int? life,
    String? selectedSkin,
    Set<String>? unlockedSkins,
    String? selectedBullet,
    Set<String>? unlockedBullets,
  }) {
    return GameState(
      score: score ?? this.score,
      totalPoints: totalPoints ?? this.totalPoints,
      life: life ?? this.life,
      selectedSkin: selectedSkin ?? this.selectedSkin,
      unlockedSkins: unlockedSkins ?? this.unlockedSkins,
      selectedBullet: selectedBullet ?? this.selectedBullet,
      unlockedBullets: unlockedBullets ?? this.unlockedBullets,
    );
  }

  @override
  List<Object?> get props => [score, totalPoints, life, selectedSkin, unlockedSkins, selectedBullet, unlockedBullets];
}

// --- Bloc ---
class GameBloc extends Bloc<GameEvent, GameState> {
  GameBloc()
      : super(const GameState(
          score: 0,
          totalPoints: 0,
          life: 3,
          selectedSkin: '0',
          unlockedSkins: {'0'},
          selectedBullet: '0',
          unlockedBullets: {'0'},
        )) {
    on<LoadGameState>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      final totalPoints = prefs.getInt('totalPoints') ?? 0;
      final life = prefs.getInt('life') ?? 3;

      // Load selectedSkin and unlockedSkins
      dynamic selectedSkinRaw = prefs.get('selectedSkin');
      String selectedSkin = '0';
      if (selectedSkinRaw is String) {
        selectedSkin = selectedSkinRaw;
      } else if (selectedSkinRaw is int) {
        selectedSkin = selectedSkinRaw.toString();
      }
      final unlockedSkinsList = prefs.getStringList('unlockedSkins') ?? ['0'];
      final unlockedSkins = Set<String>.from(unlockedSkinsList);
      if (!unlockedSkins.contains('0')) unlockedSkins.add('0');
      if (!unlockedSkins.contains(selectedSkin)) selectedSkin = '0';

      // Load selectedBullet and unlockedBullets
      dynamic selectedBulletRaw = prefs.get('selectedBullet');
      String selectedBullet = '0';
      if (selectedBulletRaw is String) {
        selectedBullet = selectedBulletRaw;
      } else if (selectedBulletRaw is int) {
        selectedBullet = selectedBulletRaw.toString();
      }
      final unlockedBulletsList = prefs.getStringList('unlockedBullets') ?? ['0'];
      final unlockedBullets = Set<String>.from(unlockedBulletsList);
      if (!unlockedBullets.contains('0')) unlockedBullets.add('0');
      if (!unlockedBullets.contains(selectedBullet)) selectedBullet = '0';

      emit(state.copyWith(
        totalPoints: totalPoints,
        life: life,
        selectedSkin: selectedSkin,
        unlockedSkins: unlockedSkins,
        selectedBullet: selectedBullet,
        unlockedBullets: unlockedBullets,
      ));
    });
    on<AddPoints>((event, emit) async {
      final newTotal = state.totalPoints + event.points;
      emit(state.copyWith(
        score: state.score + event.points,
        totalPoints: newTotal,
      ));
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('totalPoints', newTotal);
    });
    on<GainLife>((event, emit) async {
      final newLife = state.life + event.amount;
      emit(state.copyWith(life: newLife));
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('life', newLife);
    });
    on<LoseLife>((event, emit) async {
      final newLife = state.life - event.amount;
      emit(state.copyWith(life: newLife));
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('life', newLife);
    });
    on<SpendPoints>((event, emit) async {
      final newTotal = state.totalPoints - event.points;
      emit(state.copyWith(
        totalPoints: newTotal,
      ));
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('totalPoints', newTotal);
    });
    on<SelectSkin>((event, emit) async {
      if (state.unlockedSkins.contains(event.skinId)) {
        emit(state.copyWith(selectedSkin: event.skinId));
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('selectedSkin', event.skinId);
      }
    });
    on<UnlockSkin>((event, emit) async {
      final newUnlocked = Set<String>.from(state.unlockedSkins)..add(event.skinId);
      emit(state.copyWith(unlockedSkins: newUnlocked));
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('unlockedSkins', newUnlocked.toList());
    });
    on<SelectBullet>((event, emit) async {
      if (state.unlockedBullets.contains(event.bulletId)) {
        emit(state.copyWith(selectedBullet: event.bulletId));
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('selectedBullet', event.bulletId);
      }
    });
    on<UnlockBullet>((event, emit) async {
      final newUnlocked = Set<String>.from(state.unlockedBullets)..add(event.bulletId);
      emit(state.copyWith(unlockedBullets: newUnlocked));
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('unlockedBullets', newUnlocked.toList());
    });
    on<ResetScore>((event, emit) {
      emit(state.copyWith(score: 0, life: 3));
    });
  }
} 