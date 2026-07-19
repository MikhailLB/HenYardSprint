import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../screens/main_shell.dart';
import '../../theme.dart';
import '../core/relay_models.dart';
import '../pages/no_line_page.dart';
import '../pages/signal_invite.dart';
import '../pages/yard_browser.dart';
import '../sprint_coordinator.dart';

/// Splash / boot screen — the loading experience AND the gray/white routing
/// point. It plays the loading art (orientation-aware) while
/// [SprintCoordinator.decide] runs the attribution → config pipeline, then
/// routes to the WebView (gray) or the white game (organic).
class SprintGate extends StatefulWidget {
  const SprintGate({super.key, this.coordinator});

  final SprintCoordinator? coordinator;

  @override
  State<SprintGate> createState() => _SprintGateState();
}

class _SprintGateState extends State<SprintGate> {
  double _pipelineProgress = 0;
  SprintTarget? _target;
  bool _started = false;
  bool _navigating = false;
  late final DateTime _startTime;
  Timer? _hardDeadline;
  static const Duration _minSplash = Duration(milliseconds: 1600);

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    // Loading screen supports both orientations.
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    // Safety net only. Must exceed the pipeline's own internal budget
    // (ATT prompt + awaitSignals install timeout 8s + config POST timeout 15s),
    // otherwise it fires mid-flight and wrongly routes non-organic users to the
    // white game before the config URL arrives.
    _hardDeadline = Timer(const Duration(seconds: 30), () {
      if (mounted && !_navigating) {
        _target ??= const YardTarget();
        _maybeNavigate();
      }
    });
  }

  @override
  void dispose() {
    _hardDeadline?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      _resolveTarget();
    }
  }

  Future<void> _resolveTarget() async {
    final coordinator = widget.coordinator;
    if (coordinator == null) {
      _target = const YardTarget();
      _pipelineProgress = 1;
      _maybeNavigate();
      return;
    }
    try {
      _target = await coordinator.decide(
        onProgress: (value) {
          if (mounted) {
            setState(() => _pipelineProgress = value.clamp(0.0, 1.0));
          }
        },
      );
    } catch (_) {
      _target = const YardTarget();
    }
    if (mounted) setState(() => _pipelineProgress = 1);
    _hardDeadline?.cancel();
    _maybeNavigate();
  }

  void _maybeNavigate() async {
    if (_navigating || _target == null) return;
    final elapsed = DateTime.now().difference(_startTime);
    if (elapsed < _minSplash) {
      await Future<void>.delayed(_minSplash - elapsed);
    }
    if (!mounted || _navigating) return;
    _navigating = true;
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await Future<void>.delayed(const Duration(milliseconds: 60));
    if (!mounted) return;
    await _openTarget(_target!);
  }

  Future<void> _openTarget(SprintTarget target) async {
    final coordinator = widget.coordinator;

    // Organic / gate disabled → white game.
    if (target is YardTarget || coordinator == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const MainShell()),
      );
      return;
    }

    if (target is NoLineTarget) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => NoLinePage(
            probe: coordinator.probe,
            retryBuilder: (_) => SprintGate(coordinator: coordinator),
          ),
        ),
      );
      return;
    }

    if (target is BrowserTarget) {
      Widget browserBuilder(BuildContext _) => YardBrowser(
        url: target.url,
        coldLaunch: target.coldLaunch,
        store: coordinator.store,
        probe: coordinator.probe,
        notifications: coordinator.notifications,
        agent: coordinator.agent,
      );

      void openBrowser() {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute<void>(builder: browserBuilder));
      }

      if (coordinator.store.shouldShowPushInvite &&
          await coordinator.notifications.canOfferPermission()) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => SignalInvite(
              store: coordinator.store,
              notifications: coordinator.notifications,
              nextBuilder: browserBuilder,
            ),
          ),
        );
      } else {
        openBrowser();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;
    final hero = isLandscape
        ? 'assets/images/hero_horizontal.png'
        : 'assets/images/hero_vertical.png';
    final screenW = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: HenColors.sky,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            hero,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
            gaplessPlayback: true,
            errorBuilder: (_, _, _) =>
                const ColoredBox(color: HenColors.sky),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: 0.42,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xB3000000)],
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(bottom: isLandscape ? 22 : 60),
                child: _LoadingBar(
                  progress: _pipelineProgress,
                  width: isLandscape ? screenW * 0.42 : screenW * 0.74,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingBar extends StatelessWidget {
  const _LoadingBar({required this.progress, required this.width});

  final double progress;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: width,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.30),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.6),
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOut,
                  tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
                  builder: (context, value, _) {
                    return FractionallySizedBox(
                      widthFactor: value <= 0 ? 0.001 : value,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              HenColors.corn,
                              HenColors.sunOrange,
                              HenColors.barnRed,
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        _LoadingLabel(),
      ],
    );
  }
}

class _LoadingLabel extends StatefulWidget {
  @override
  State<_LoadingLabel> createState() => _LoadingLabelState();
}

class _LoadingLabelState extends State<_LoadingLabel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final dots = '.' * ((_ctrl.value * 4).floor() % 4);
        return Text(
          'Loading$dots',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            shadows: [Shadow(color: Colors.black54, blurRadius: 6)],
          ),
        );
      },
    );
  }
}
