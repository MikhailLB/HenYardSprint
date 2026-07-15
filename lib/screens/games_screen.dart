import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/hen_background.dart';
import '../widgets/pressable.dart';
import '../games/feed_frenzy_game.dart';
import '../games/egg_catch_game.dart';
import '../games/memory_match_game.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final games = [
      _GameInfo(
        'Feed Frenzy',
        'Tap the hungry hens as fast as you can!',
        Icons.touch_app_rounded,
        HenColors.sunOrange,
        (c) => const FeedFrenzyGame(),
      ),
      _GameInfo(
        'Egg Catch',
        'Slide the basket and catch the falling eggs.',
        Icons.egg_rounded,
        HenColors.skyDeep,
        (c) => const EggCatchGame(),
      ),
      _GameInfo(
        'Memory Match',
        'Flip the cards and find the matching pairs.',
        Icons.grid_view_rounded,
        HenColors.leaf,
        (c) => const MemoryMatchGame(),
      ),
    ];

    return HenBackground(
      topColor: HenColors.skyDeep,
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
          children: [
            const HenHeader(
              title: 'Play',
              subtitle: 'Fun little chicken games',
            ),
            const SizedBox(height: 8),
            ...games.map((g) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _GameCard(info: g),
                )),
          ],
        ),
      ),
    );
  }
}

class _GameInfo {
  const _GameInfo(this.title, this.desc, this.icon, this.color, this.builder);
  final String title;
  final String desc;
  final IconData icon;
  final Color color;
  final WidgetBuilder builder;
}

class _GameCard extends StatelessWidget {
  const _GameCard({required this.info});
  final _GameInfo info;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: () =>
          Navigator.of(context).push(MaterialPageRoute(builder: info.builder)),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: HenColors.cardCream,
          borderRadius: BorderRadius.circular(24),
          boxShadow: henCardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [info.color.withValues(alpha: 0.85), info.color],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(info.icon, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(info.title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text(info.desc,
                      style: const TextStyle(
                          fontSize: 13, color: HenColors.coffeeSoft)),
                ],
              ),
            ),
            const Icon(Icons.play_circle_fill_rounded,
                color: HenColors.sunOrange, size: 34),
          ],
        ),
      ),
    );
  }
}
