import 'package:flutter/material.dart';

import '../data/content.dart';
import '../theme.dart';
import '../widgets/hen_background.dart';
import '../widgets/pressable.dart';

class ArticleScreen extends StatelessWidget {
  const ArticleScreen({super.key, required this.article});
  final LearnArticle article;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HenBackground(
        topColor: HenColors.leaf,
        child: SafeArea(
          child: Column(
            children: [
              HenHeader(
                title: article.title,
                subtitle: article.summary,
                leading: PressableScale(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: henCardShadow,
                    ),
                    child: const Icon(Icons.arrow_back_rounded,
                        color: HenColors.leafDark),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  children: [
                    Center(
                      child: Text(article.emoji,
                          style: const TextStyle(fontSize: 56)),
                    ),
                    const SizedBox(height: 8),
                    ...article.sections.map((s) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _SectionCard(section: s),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.section});
  final LearnSection section;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: HenColors.cardCream,
        borderRadius: BorderRadius.circular(22),
        boxShadow: henCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(section.heading,
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: HenColors.leafDark)),
          const SizedBox(height: 6),
          Text(section.body,
              style: const TextStyle(
                  fontSize: 14.5, color: HenColors.coffee, height: 1.4)),
          if (section.bullets.isNotEmpty) const SizedBox(height: 10),
          ...section.bullets.map((b) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2, right: 8),
                      child: Image.asset('assets/images/wheat.png', width: 18),
                    ),
                    Expanded(
                      child: Text(b,
                          style: const TextStyle(
                              fontSize: 14, color: HenColors.coffee)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
