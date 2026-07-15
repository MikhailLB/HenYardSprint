import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/hen_background.dart';
import '../widgets/pressable.dart';
import 'web_view_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const String privacyUrl =
      'https://henyardsprint.com/privacy-policy.html';
  static const String supportUrl = 'https://henyardsprint.com/support.html';

  @override
  Widget build(BuildContext context) {
    return HenBackground(
      topColor: HenColors.barnRed,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const HenHeader(
              title: 'More',
              subtitle: 'Privacy, support & info',
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                children: [
                  Center(
                    child: Image.asset('assets/images/chicken_face.png',
                        height: 96),
                  ),
                  const SizedBox(height: 8),
                  _SettingsTile(
                    icon: Icons.privacy_tip_rounded,
                    color: HenColors.leafDark,
                    title: 'Privacy Policy',
                    subtitle: 'How we handle your data',
                    onTap: () => _open(context, 'Privacy Policy', privacyUrl),
                  ),
                  const SizedBox(height: 12),
                  _SettingsTile(
                    icon: Icons.support_agent_rounded,
                    color: HenColors.skyDeep,
                    title: 'Support',
                    subtitle: 'Get help & contact us',
                    onTap: () => _open(context, 'Support', supportUrl),
                  ),
                  const SizedBox(height: 12),
                  _SettingsTile(
                    icon: Icons.info_rounded,
                    color: HenColors.sunOrange,
                    title: 'About',
                    subtitle: 'What is Hen Yard Sprint?',
                    onTap: () => _showAbout(context),
                  ),
                  const SizedBox(height: 24),
                  const Center(
                    child: Text(
                      'Hen Yard Sprint • Version 1.0.0',
                      style: TextStyle(
                        color: HenColors.coffeeSoft,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _open(BuildContext context, String title, String url) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WebViewScreen(title: title, url: url),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: HenColors.cardCream,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/chicken_main.png', height: 110),
              const SizedBox(height: 8),
              const Text('Hen Yard Sprint',
                  style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              const Text(
                'Your friendly poultry companion: plan feed, learn how to care '
                'for your flock, and enjoy a few fun chicken mini-games.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.5, color: HenColors.coffee),
              ),
              const SizedBox(height: 16),
              PressableScale(
                onTap: () => Navigator.of(ctx).pop(),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  decoration: BoxDecoration(
                    color: HenColors.sunOrange,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text('Got it!',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
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
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w700)),
                  Text(subtitle,
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
