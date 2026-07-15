import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/content.dart';
import '../theme.dart';
import '../widgets/hen_background.dart';
import '../widgets/pressable.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onGoto});
  final ValueChanged<int> onGoto;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _rnd = math.Random();
  late int _factIndex = _rnd.nextInt(chickenFacts.length);

  void _newFact() => setState(
        () => _factIndex = (_factIndex + 1 + _rnd.nextInt(chickenFacts.length - 1)) %
            chickenFacts.length,
      );

  @override
  Widget build(BuildContext context) {
    return HenBackground(
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
          children: [
            const HenHeader(
              title: 'Hen Yard Sprint',
              subtitle: 'Welcome back, farmer!',
            ),
            const SizedBox(height: 8),
            _bannerCard(),
            const SizedBox(height: 16),
            _factCard(),
            const SizedBox(height: 16),
            const Text('  Quick actions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            _quickGrid(),
          ],
        ),
      ),
    );
  }

  Widget _bannerCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: Stack(
        children: [
          Image.asset(
            'assets/images/farm_scene.png',
            height: 190,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withValues(alpha: 0.35),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 18,
            top: 20,
            right: 120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Raise a happy flock',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    shadows: [Shadow(color: Colors.black54, blurRadius: 6)],
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Plan feed, learn care tips and have fun.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    shadows: [Shadow(color: Colors.black54, blurRadius: 6)],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: -6,
            bottom: -6,
            child: Image.asset('assets/images/chicken_main.png', height: 150),
          ),
        ],
      ),
    );
  }

  Widget _factCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: HenColors.cardCream,
        borderRadius: BorderRadius.circular(24),
        boxShadow: henCardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: HenColors.cornLight.withValues(alpha: 0.7),
              shape: BoxShape.circle,
            ),
            child: Image.asset('assets/images/chicken_wink.png', width: 44),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Did you know?',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w800)),
                    const Spacer(),
                    PressableScale(
                      onTap: _newFact,
                      child: const Icon(Icons.refresh_rounded,
                          color: HenColors.sunOrange),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  child: Text(
                    chickenFacts[_factIndex],
                    key: ValueKey(_factIndex),
                    style: const TextStyle(
                        fontSize: 14.5, color: HenColors.coffee, height: 1.35),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickGrid() {
    final actions = [
      _Qa('Feed Calculator', 'Plan daily feed', Icons.calculate_rounded,
          HenColors.sunOrange, 1),
      _Qa('Learn', 'Care & breeds', Icons.menu_book_rounded, HenColors.leaf, 2),
      _Qa('Play', 'Fun mini-games', Icons.sports_esports_rounded,
          HenColors.skyDeep, 3),
      _Qa('Settings', 'Privacy & support', Icons.settings_rounded,
          HenColors.barnRed, 4),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: actions.map((a) {
        return PressableScale(
          onTap: () => widget.onGoto(a.tab),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: HenColors.cardCream,
              borderRadius: BorderRadius.circular(22),
              boxShadow: henCardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: a.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(a.icon, color: a.color, size: 26),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.title,
                        style: const TextStyle(
                            fontSize: 15.5, fontWeight: FontWeight.w800)),
                    Text(a.subtitle,
                        style: const TextStyle(
                            fontSize: 12, color: HenColors.coffeeSoft)),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _Qa {
  const _Qa(this.title, this.subtitle, this.icon, this.color, this.tab);
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final int tab;
}
