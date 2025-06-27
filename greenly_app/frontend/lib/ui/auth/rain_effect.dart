import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'rain_painter.dart';

class RainEffect extends StatefulWidget {
  const RainEffect({super.key});

  @override
  State<RainEffect> createState() => _RainEffectState();
}

class _RainEffectState extends State<RainEffect> {
  final List<RainDrop> _drops = [];
  final int dropCount = 80;
  final Random _random = Random();
  late Size screenSize;

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      screenSize = MediaQuery.of(context).size;
      _initDrops();
      _startRainLoop();
      _initialized = true;
    }
  }

  void _startRainLoop() {
    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      _updateDrops();
    });
  }

  void _initDrops() {
    for (int i = 0; i < dropCount; i++) {
      _drops.add(
        RainDrop(
          Offset(_random.nextDouble() * screenSize.width,
              _random.nextDouble() * screenSize.height),
          2 + _random.nextDouble() * 3,
        ),
      );
    }
  }

  void _updateDrops() {
    for (var drop in _drops) {
      drop.position = Offset(drop.position.dx, drop.position.dy + drop.speed);
      if (drop.position.dy > screenSize.height) {
        drop.position = Offset(_random.nextDouble() * screenSize.width, 0);
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: RainPainter(_drops),
      size: MediaQuery.of(context).size,
    );
  }
}
