import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/pressable.dart';
import 'home_screen.dart';
import 'calculator_screen.dart';
import 'learn_screen.dart';
import 'games_screen.dart';
import 'settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  void _go(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(onGoto: _go),
          const CalculatorScreen(),
          const LearnScreen(),
          const GamesScreen(),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: _HenNavBar(index: _index, onTap: _go),
    );
  }
}

class _NavItem {
  const _NavItem(this.icon, this.label);
  final IconData icon;
  final String label;
}

const _navItems = [
  _NavItem(Icons.home_rounded, 'Home'),
  _NavItem(Icons.calculate_rounded, 'Feed'),
  _NavItem(Icons.menu_book_rounded, 'Learn'),
  _NavItem(Icons.sports_esports_rounded, 'Play'),
  _NavItem(Icons.settings_rounded, 'More'),
];

class _HenNavBar extends StatelessWidget {
  const _HenNavBar({required this.index, required this.onTap});
  final int index;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: [
          BoxShadow(color: Color(0x33935E2A), blurRadius: 18, offset: Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_navItems.length, (i) {
              final selected = i == index;
              final item = _navItems[i];
              return Expanded(
                child: PressableScale(
                  pressedScale: 0.9,
                  onTap: () => onTap(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      gradient: selected
                          ? const LinearGradient(
                              colors: [HenColors.corn, HenColors.sunOrange],
                            )
                          : null,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.icon,
                          size: 24,
                          color: selected ? Colors.white : HenColors.coffeeSoft,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: selected ? Colors.white : HenColors.coffeeSoft,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
