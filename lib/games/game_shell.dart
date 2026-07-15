import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/hen_background.dart';
import '../widgets/pressable.dart';

class GameShell extends StatelessWidget {
  const GameShell({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
    this.topColor = HenColors.sky,
  });

  final String title;
  final Widget child;
  final Widget? trailing;
  final Color topColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HenBackground(
        topColor: topColor,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 16, 4),
                child: Row(
                  children: [
                    PressableScale(
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
                            color: HenColors.sunOrange),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: HenColors.coffee,
                        ),
                      ),
                    ),
                    ?trailing,
                  ],
                ),
              ),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

/// A rounded stat chip used in game top bars (score, time, etc.).
class GameChip extends StatelessWidget {
  const GameChip({super.key, required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: henCardShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(fontWeight: FontWeight.w800, color: color, fontSize: 15)),
        ],
      ),
    );
  }
}

/// Shared end-of-game result dialog.
Future<void> showGameResult(
  BuildContext context, {
  required String title,
  required String message,
  required VoidCallback onReplay,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => Dialog(
      backgroundColor: HenColors.cardCream,
      shape: RoundedCornerShape(),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/chicken_happy.png', height: 90),
            const SizedBox(height: 8),
            Text(title,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: HenColors.coffee)),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _DialogButton(
                    label: 'Back',
                    color: HenColors.coffeeSoft,
                    onTap: () {
                      Navigator.of(ctx).pop();
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DialogButton(
                    label: 'Play again',
                    color: HenColors.sunOrange,
                    onTap: () {
                      Navigator.of(ctx).pop();
                      onReplay();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class RoundedCornerShape extends RoundedRectangleBorder {
  const RoundedCornerShape()
      : super(borderRadius: const BorderRadius.all(Radius.circular(28)));
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({required this.label, required this.color, required this.onTap});
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(label,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
      ),
    );
  }
}
