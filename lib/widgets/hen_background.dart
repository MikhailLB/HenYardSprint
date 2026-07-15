import 'package:flutter/material.dart';

import '../theme.dart';

/// Shared chicken-themed backdrop: warm gradient + subtle repeating pattern.
class HenBackground extends StatelessWidget {
  const HenBackground({super.key, required this.child, this.topColor = HenColors.sky});

  final Widget child;
  final Color topColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [topColor, HenColors.cornLight, HenColors.cream],
          stops: const [0.0, 0.3, 0.6],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg_pattern.png',
              repeat: ImageRepeat.repeat,
              opacity: const AlwaysStoppedAnimation(0.30),
              alignment: Alignment.topCenter,
            ),
          ),
          child,
        ],
      ),
    );
  }
}

/// Reusable big screen title.
class HenHeader extends StatelessWidget {
  const HenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.leading,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 16, 6),
      child: Row(
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 12)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: HenColors.coffee,
                    shadows: [
                      Shadow(
                        color: Colors.white.withValues(alpha: 0.6),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: HenColors.barnRed,
                    ),
                  ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
