import 'package:flutter/material.dart';

import '../data/content.dart';
import '../theme.dart';
import '../widgets/hen_background.dart';
import '../widgets/pressable.dart';
import 'article_screen.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return HenBackground(
      topColor: HenColors.leaf,
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
          children: [
            const HenHeader(
              title: 'Learn',
              subtitle: 'Poultry care, feeding & breeds',
            ),
            const SizedBox(height: 8),
            ...learnArticles.map((a) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ArticleCard(article: a),
                )),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Tap a topic to read more 🐣',
                style: TextStyle(color: HenColors.coffeeSoft, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  const _ArticleCard({required this.article});
  final LearnArticle article;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ArticleScreen(article: article)),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: HenColors.cardCream,
          borderRadius: BorderRadius.circular(22),
          boxShadow: henCardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: HenColors.cornLight.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(article.emoji, style: const TextStyle(fontSize: 28)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(article.title,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text(article.summary,
                      style: const TextStyle(
                          fontSize: 13, color: HenColors.coffeeSoft)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: HenColors.coffeeSoft),
          ],
        ),
      ),
    );
  }
}
