import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/material.dart' as material;

class Hud extends Component with HasGameRef {
  late JoystickComponent joystick;
  late HudButtonComponent shootButton;
  final void Function()? onShoot;

  Hud({this.onShoot});

  @override
  Future<void> onLoad() async {
    // Joystick
    joystick = JoystickComponent(
      knob: CircleComponent(radius: 20, paint: Paint()..color = const Color(0xAA00FFFF)),
      background: CircleComponent(radius: 40, paint: Paint()..color = const Color(0x4400FFFF)),
      margin: const EdgeInsets.only(left: 40, bottom: 40),
    );
    add(joystick);

    // Shoot button
    shootButton = HudButtonComponent(
      button: CircleComponent(radius: 28, paint: Paint()..color = const Color(0xAAFFFF00)),
      buttonDown: CircleComponent(radius: 28, paint: Paint()..color = const Color(0xFFFFFF00)),
      margin: const EdgeInsets.only(right: 40, bottom: 40),
      onPressed: onShoot,
    );
    add(shootButton);
  }
} 