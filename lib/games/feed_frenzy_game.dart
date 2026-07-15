import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';
import 'game_shell.dart';

class FeedFrenzyGame extends StatefulWidget {
  const FeedFrenzyGame({super.key});

  @override
  State<FeedFrenzyGame> createState() => _FeedFrenzyGameState();
}

class _FeedFrenzyGameState extends State<FeedFrenzyGame> {
  static const _cells = 9;
  static const _roundSeconds = 30;

  final _rnd = math.Random();
  final List<bool> _active = List.filled(_cells, false);
  int _score = 0;
  int _timeLeft = _roundSeconds;
  Timer? _countdown;
  Timer? _spawner;

  @override
  void initState() {
    super.initState();
    _start();
  }

  void _start() {
    _countdown?.cancel();
    _spawner?.cancel();
    setState(() {
      _score = 0;
      _timeLeft = _roundSeconds;
      for (var i = 0; i < _cells; i++) {
        _active[i] = false;
      }
    });

    _countdown = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _timeLeft--);
      if (_timeLeft <= 0) _end();
    });

    _spawner = Timer.periodic(const Duration(milliseconds: 720), (_) {
      setState(() {
        for (var i = 0; i < _cells; i++) {
          _active[i] = false;
        }
        final a = _rnd.nextInt(_cells);
        var b = _rnd.nextInt(_cells);
        if (b == a) b = (b + 1) % _cells;
        _active[a] = true;
        _active[b] = true;
      });
    });
  }

  void _end() {
    _countdown?.cancel();
    _spawner?.cancel();
    for (var i = 0; i < _cells; i++) {
      _active[i] = false;
    }
    if (!mounted) return;
    setState(() {});
    showGameResult(
      context,
      title: "Time's up!",
      message: 'You fed $_score ${_score == 1 ? 'hen' : 'hens'}! 🌽',
      onReplay: _start,
    );
  }

  void _tap(int i) {
    if (!_active[i] || _timeLeft <= 0) return;
    setState(() {
      _active[i] = false;
      _score++;
    });
  }

  @override
  void dispose() {
    _countdown?.cancel();
    _spawner?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GameShell(
      title: 'Feed Frenzy',
      topColor: HenColors.sunOrange,
      trailing: GameChip(
        icon: Icons.timer_rounded,
        label: '$_timeLeft s',
        color: HenColors.barnRed,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GameChip(
                  icon: Icons.star_rounded,
                  label: 'Score: $_score',
                  color: HenColors.sunOrange,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text('Tap the hens the moment they pop up!',
              style: TextStyle(color: HenColors.coffeeSoft, fontSize: 13)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: GridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                physics: const NeverScrollableScrollPhysics(),
                children: List.generate(_cells, (i) => _nest(i)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _nest(int i) {
    final active = _active[i];
    return GestureDetector(
      onTap: () => _tap(i),
      child: Container(
        decoration: BoxDecoration(
          color: HenColors.cream,
          shape: BoxShape.circle,
          border: Border.all(color: HenColors.cornLight, width: 3),
          boxShadow: henCardShadow,
        ),
        child: Center(
          child: AnimatedScale(
            scale: active ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOutBack,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Image.asset('assets/images/chicken_face.png'),
            ),
          ),
        ),
      ),
    );
  }
}
