import 'dart:async';

import 'package:flutter/material.dart';

import '../theme.dart';
import 'game_shell.dart';

const _faces = [
  'assets/images/chicken_face.png',
  'assets/images/chicken_wink.png',
  'assets/images/chicken_happy.png',
  'assets/images/chicken_surprised.png',
  'assets/images/chicken_worried.png',
  'assets/images/feedbowl.png',
];

class _Card {
  _Card(this.asset);
  final String asset;
  bool flipped = false;
  bool matched = false;
}

class MemoryMatchGame extends StatefulWidget {
  const MemoryMatchGame({super.key});

  @override
  State<MemoryMatchGame> createState() => _MemoryMatchGameState();
}

class _MemoryMatchGameState extends State<MemoryMatchGame> {
  late List<_Card> _cards;
  int _moves = 0;
  int? _firstIndex;
  bool _lock = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  void _start() {
    final list = [..._faces, ..._faces].map((a) => _Card(a)).toList()..shuffle();
    setState(() {
      _cards = list;
      _moves = 0;
      _firstIndex = null;
      _lock = false;
    });
  }

  void _flip(int i) {
    if (_lock) return;
    final card = _cards[i];
    if (card.flipped || card.matched) return;

    setState(() => card.flipped = true);

    if (_firstIndex == null) {
      _firstIndex = i;
      return;
    }

    _moves++;
    final first = _cards[_firstIndex!];
    if (first.asset == card.asset) {
      setState(() {
        first.matched = true;
        card.matched = true;
        _firstIndex = null;
      });
      if (_cards.every((c) => c.matched)) _win();
    } else {
      _lock = true;
      final prev = _firstIndex!;
      _firstIndex = null;
      Timer(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        setState(() {
          _cards[prev].flipped = false;
          card.flipped = false;
          _lock = false;
        });
      });
    }
  }

  void _win() {
    Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      showGameResult(
        context,
        title: 'You win! 🎉',
        message: 'Solved in $_moves moves.',
        onReplay: _start,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return GameShell(
      title: 'Memory Match',
      topColor: HenColors.leaf,
      trailing: GameChip(
        icon: Icons.swap_horiz_rounded,
        label: 'Moves: $_moves',
        color: HenColors.leafDark,
      ),
      child: Column(
        children: [
          const Text('Find all matching pairs of chicken cards',
              style: TextStyle(color: HenColors.coffeeSoft, fontSize: 13)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                itemCount: _cards.length,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.82,
                ),
                itemBuilder: (context, i) => _cardTile(i),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardTile(int i) {
    final card = _cards[i];
    final showFace = card.flipped || card.matched;
    return GestureDetector(
      onTap: () => _flip(i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: showFace ? HenColors.cardCream : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: card.matched ? HenColors.leaf : HenColors.cornLight,
            width: 3,
          ),
          boxShadow: henCardShadow,
          gradient: showFace
              ? null
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [HenColors.corn, HenColors.sunOrange],
                ),
        ),
        padding: const EdgeInsets.all(10),
        child: showFace
            ? Image.asset(card.asset)
            : const Center(
                child: Icon(Icons.egg_rounded, color: Colors.white, size: 34),
              ),
      ),
    );
  }
}
