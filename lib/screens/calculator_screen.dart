import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/hen_background.dart';
import '../widgets/pressable.dart';

enum BirdStage {
  chicks('Chicks', '0–8 weeks', 45),
  growers('Growers', '8–20 weeks', 90),
  layers('Layers', '20+ weeks', 120);

  const BirdStage(this.label, this.hint, this.defaultGrams);
  final String label;
  final String hint;
  final int defaultGrams;
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen>
    with SingleTickerProviderStateMixin {
  int birds = 12;
  BirdStage stage = BirdStage.layers;
  int gramsPerBird = BirdStage.layers.defaultGrams;
  int days = 30;
  int bagSize = 25;
  double pricePerKg = 0.60;

  late final AnimationController _bob;

  @override
  void initState() {
    super.initState();
    _bob = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bob.dispose();
    super.dispose();
  }

  double get dailyKg => birds * gramsPerBird / 1000.0;
  double get totalKg => dailyKg * days;
  int get bags => bagSize > 0 ? (totalKg / bagSize).ceil() : 0;
  double get cost => totalKg * pricePerKg;

  @override
  Widget build(BuildContext context) {
    return HenBackground(
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const HenHeader(
              title: 'Hen Yard Sprint',
              subtitle: 'Poultry Feed Calculator',
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 120),
                children: [
                    _Mascot(bob: _bob),
                    const SizedBox(height: 12),
                    _flockCard(),
                    const SizedBox(height: 14),
                    _birdTypeCard(),
                    const SizedBox(height: 14),
                    _periodCard(),
                    const SizedBox(height: 14),
                    _costCard(),
                    const SizedBox(height: 18),
                    _ResultCard(
                      dailyKg: dailyKg,
                      totalKg: totalKg,
                      days: days,
                      bags: bags,
                      bagSize: bagSize,
                      cost: cost,
                      showCost: pricePerKg > 0,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Estimates are guidance only. Real intake varies with '
                      'breed, weather and housing.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: HenColors.coffeeSoft,
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

  Widget _flockCard() {
    return _SectionCard(
      icon: 'assets/images/chicken_face.png',
      title: 'Flock size',
      subtitle: 'How many birds are you feeding?',
      child: Column(
        children: [
          _Stepper(
            value: birds,
            suffix: birds == 1 ? 'bird' : 'birds',
            onDec: () => setState(() => birds = math.max(1, birds - 1)),
            onInc: () => setState(() => birds = math.min(1000, birds + 1)),
          ),
          Slider(
            value: birds.toDouble().clamp(1, 300),
            min: 1,
            max: 300,
            onChanged: (v) => setState(() => birds = v.round()),
          ),
        ],
      ),
    );
  }

  Widget _birdTypeCard() {
    return _SectionCard(
      icon: 'assets/images/feedbowl.png',
      title: 'Bird type',
      subtitle: 'Sets a typical daily intake — fine-tune below.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: BirdStage.values.map((s) {
              final selected = s == stage;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: PressableScale(
                    onTap: () => setState(() {
                      stage = s;
                      gramsPerBird = s.defaultGrams;
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        gradient: selected
                            ? const LinearGradient(
                                colors: [HenColors.sunOrange, HenColors.barnRed],
                              )
                            : null,
                        color: selected ? null : HenColors.cream,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selected ? Colors.transparent : HenColors.cornLight,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            s.label,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: selected ? Colors.white : HenColors.coffee,
                            ),
                          ),
                          Text(
                            s.hint,
                            style: TextStyle(
                              fontSize: 11,
                              color: selected
                                  ? Colors.white.withValues(alpha: 0.9)
                                  : HenColors.coffeeSoft,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Image.asset('assets/images/wheat.png', width: 30),
              const SizedBox(width: 8),
              const Text('Feed per bird',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              const Spacer(),
              _Pill(text: '$gramsPerBird g/day', color: HenColors.barnRed),
            ],
          ),
          Slider(
            value: gramsPerBird.toDouble().clamp(10, 250),
            min: 10,
            max: 250,
            onChanged: (v) => setState(() => gramsPerBird = v.round()),
          ),
        ],
      ),
    );
  }

  Widget _periodCard() {
    return _SectionCard(
      icon: 'assets/images/chicken_wink.png',
      title: 'Planning period',
      subtitle: _weeksText(days),
      child: Column(
        children: [
          _Stepper(
            value: days,
            suffix: days == 1 ? 'day' : 'days',
            onDec: () => setState(() => days = math.max(1, days - 1)),
            onInc: () => setState(() => days = math.min(365, days + 1)),
          ),
          Slider(
            value: days.toDouble().clamp(1, 90),
            min: 1,
            max: 90,
            onChanged: (v) => setState(() => days = v.round()),
          ),
        ],
      ),
    );
  }

  Widget _costCard() {
    return _SectionCard(
      icon: 'assets/images/feedsack.png',
      title: 'Cost & packaging',
      subtitle: 'Optional — for budgeting your feed.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Bag size',
              style: TextStyle(fontSize: 13, color: HenColors.coffeeSoft)),
          const SizedBox(height: 8),
          Row(
            children: [10, 25, 50].map((size) {
              final selected = bagSize == size;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: PressableScale(
                    onTap: () => setState(() => bagSize = size),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected ? HenColors.leafDark : HenColors.cream,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected ? Colors.transparent : HenColors.cornLight,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        '$size kg',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: selected ? Colors.white : HenColors.coffee,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Price per kg',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              const Spacer(),
              _Pill(
                text: '\$${pricePerKg.toStringAsFixed(2)}',
                color: HenColors.leafDark,
              ),
            ],
          ),
          Slider(
            value: pricePerKg.clamp(0, 3),
            min: 0,
            max: 3,
            onChanged: (v) => setState(() => pricePerKg = (v * 20).round() / 20),
          ),
        ],
      ),
    );
  }

  String _weeksText(int days) {
    final weeks = days ~/ 7;
    final rem = days % 7;
    if (weeks == 0) return '$days days';
    if (rem == 0) {
      return '$days days (~$weeks ${weeks == 1 ? 'week' : 'weeks'})';
    }
    return '$days days (~$weeks w $rem d)';
  }
}

// ---------------------------------------------------------------------------
// Pieces
// ---------------------------------------------------------------------------

class _Mascot extends StatelessWidget {
  const _Mascot({required this.bob});
  final Animation<double> bob;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 168,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: _SpeechBubble(),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedBuilder(
              animation: bob,
              builder: (context, child) {
                final dy = math.sin(bob.value * math.pi) * -8;
                return Transform.translate(offset: Offset(0, dy), child: child);
              },
              child: Image.asset('assets/images/chicken_main.png', height: 138),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpeechBubble extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: henCardShadow,
      ),
      child: const Text(
        "Let's plan the feed! 🌽",
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: HenColors.coffee,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
    this.subtitle,
  });

  final String icon;
  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: HenColors.cardCream,
        borderRadius: BorderRadius.circular(24),
        boxShadow: henCardShadow,
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: HenColors.cornLight.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: Image.asset(icon, width: 34, height: 34),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700)),
                    if (subtitle != null)
                      Text(subtitle!,
                          style: const TextStyle(
                              fontSize: 12.5, color: HenColors.coffeeSoft)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.value,
    required this.suffix,
    required this.onDec,
    required this.onInc,
  });

  final int value;
  final String suffix;
  final VoidCallback onDec;
  final VoidCallback onInc;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _RoundButton(icon: Icons.remove_rounded, onTap: onDec),
        Column(
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: value.toDouble(), end: value.toDouble()),
              duration: Duration.zero,
              builder: (context, v, _) => Text(
                '$value',
                style: const TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w800,
                  color: HenColors.coffee,
                ),
              ),
            ),
            Text(suffix,
                style: const TextStyle(
                    fontSize: 13, color: HenColors.coffeeSoft)),
          ],
        ),
        _RoundButton(icon: Icons.add_rounded, onTap: onInc),
      ],
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [HenColors.corn, HenColors.sunOrange],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Color(0x55E2492B), blurRadius: 8, offset: Offset(0, 4)),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.w800, color: color, fontSize: 15),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.dailyKg,
    required this.totalKg,
    required this.days,
    required this.bags,
    required this.bagSize,
    required this.cost,
    required this.showCost,
  });

  final double dailyKg;
  final double totalKg;
  final int days;
  final int bags;
  final int bagSize;
  final double cost;
  final bool showCost;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [HenColors.sunOrange, HenColors.barnRed],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(color: Color(0x55E2492B), blurRadius: 20, offset: Offset(0, 10)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Your feed plan',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.w800)),
                    Text('for $days ${days == 1 ? 'day' : 'days'}',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 13)),
                  ],
                ),
              ),
              Image.asset('assets/images/chicken_happy.png', width: 62),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _MetricTile(label: 'Daily', value: dailyKg, unit: ' kg', decimals: 1),
              const SizedBox(width: 12),
              _MetricTile(label: 'Total', value: totalKg, unit: ' kg', decimals: 1),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _MetricTile(
                label: 'Bags ($bagSize kg)',
                value: bags.toDouble(),
                unit: '',
                decimals: 0,
              ),
              const SizedBox(width: 12),
              _MetricTile(
                label: 'Est. cost',
                value: showCost ? cost : null,
                unit: '',
                prefix: '\$',
                decimals: 2,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.unit,
    this.prefix = '',
    this.decimals = 1,
  });

  final String label;
  final double? value;
  final String unit;
  final String prefix;
  final int decimals;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9), fontSize: 12.5)),
            const SizedBox(height: 4),
            value == null
                ? const Text('—',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800))
                : TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: value),
                    duration: const Duration(milliseconds: 450),
                    curve: Curves.easeOutCubic,
                    builder: (context, v, _) => Text(
                      '$prefix${v.toStringAsFixed(decimals)}$unit',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
