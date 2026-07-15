import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';
import 'game_shell.dart';

class EggCatchGame extends StatefulWidget {
  const EggCatchGame({super.key});

  @override
  State<EggCatchGame> createState() => _EggCatchGameState();
}

class _Egg {
  _Egg(this.x, this.y, this.speed, this.golden);
  double x; // 0..1
  double y; // 0..1
  double speed; // fraction per second
  bool golden;
}

class _EggCatchGameState extends State<EggCatchGame> {
  final _rnd = math.Random();
  final List<_Egg> _eggs = [];

  double _basketX = 0.5;
  int _score = 0;
  int _lives = 3;
  bool _running = false;

  Timer? _loop;
  Timer? _spawner;
  DateTime _last = DateTime.now();

  static const double _basketY = 0.86;
  static const double _catchX = 0.14;

  @override
  void initState() {
    super.initState();
    _start();
  }

  void _start() {
    _loop?.cancel();
    _spawner?.cancel();
    setState(() {
      _eggs.clear();
      _score = 0;
      _lives = 3;
      _basketX = 0.5;
      _running = true;
    });
    _last = DateTime.now();

    _loop = Timer.periodic(const Duration(milliseconds: 16), (_) => _tick());
    _spawner = Timer.periodic(const Duration(milliseconds: 900), (_) {
      if (!_running) return;
      setState(() {
        final golden = _rnd.nextInt(6) == 0;
        _eggs.add(_Egg(
          0.1 + _rnd.nextDouble() * 0.8,
          -0.05,
          0.32 + _rnd.nextDouble() * 0.12 + _score * 0.004,
          golden,
        ));
      });
    });
  }

  void _tick() {
    if (!_running) return;
    final now = DateTime.now();
    final dt = now.difference(_last).inMicroseconds / 1e6;
    _last = now;

    final caught = <_Egg>[];
    for (final e in _eggs) {
      e.y += e.speed * dt;
      if (e.y >= _basketY && e.y <= _basketY + 0.08) {
        if ((e.x - _basketX).abs() < _catchX) {
          _score += e.golden ? 3 : 1;
          caught.add(e);
        }
      } else if (e.y > 1.05) {
        caught.add(e);
        if (!e.golden) _lives--;
      }
    }
    _eggs.removeWhere(caught.contains);

    if (_lives <= 0) {
      _end();
    } else {
      setState(() {});
    }
  }

  void _end() {
    _running = false;
    _loop?.cancel();
    _spawner?.cancel();
    if (!mounted) return;
    setState(() {});
    showGameResult(
      context,
      title: 'Game over',
      message: 'You caught $_score ${_score == 1 ? 'egg' : 'eggs'}! 🥚',
      onReplay: _start,
    );
  }

  @override
  void dispose() {
    _loop?.cancel();
    _spawner?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GameShell(
      title: 'Egg Catch',
      topColor: HenColors.skyDeep,
      trailing: GameChip(
        icon: Icons.favorite_rounded,
        label: '$_lives',
        color: HenColors.barnRed,
      ),
      child: Column(
        children: [
          GameChip(
            icon: Icons.star_rounded,
            label: 'Score: $_score',
            color: HenColors.sunOrange,
          ),
          const SizedBox(height: 6),
          const Text('Drag to move the bowl • golden eggs = 3 points',
              style: TextStyle(color: HenColors.coffeeSoft, fontSize: 12.5)),
          const SizedBox(height: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth;
                  final h = constraints.maxHeight;
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onHorizontalDragUpdate: (d) {
                      setState(() {
                        _basketX = (_basketX + d.delta.dx / w).clamp(0.08, 0.92);
                      });
                    },
                    onTapDown: (d) {
                      setState(() {
                        _basketX = (d.localPosition.dx / w).clamp(0.08, 0.92);
                      });
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        width: w,
                        height: h,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFFBDE6FB), Color(0xFFE8F7D6)],
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Stack(
                          children: [
                            for (final e in _eggs)
                              Positioned(
                                left: e.x * w - 17,
                                top: e.y * h - 22,
                                child: _EggWidget(golden: e.golden),
                              ),
                            Positioned(
                              left: _basketX * w - 42,
                              top: _basketY * h - 20,
                              child: Image.asset(
                                'assets/images/feedbowl.png',
                                width: 84,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EggWidget extends StatelessWidget {
  const _EggWidget({required this.golden});
  final bool golden;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 44,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: golden
              ? const [Color(0xFFFFE47A), Color(0xFFF6A21E)]
              : const [Colors.white, Color(0xFFF3E4C6)],
        ),
        borderRadius: const BorderRadius.all(Radius.elliptical(17, 22)),
        boxShadow: const [
          BoxShadow(color: Color(0x33000000), blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
    );
  }
}
