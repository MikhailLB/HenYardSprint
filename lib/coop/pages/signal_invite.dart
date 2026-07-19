import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/coop_relay_config.dart';
import '../infra/coop_signal_hub.dart';
import '../infra/coop_store.dart';

class SignalInvite extends StatefulWidget {
  const SignalInvite({
    super.key,
    required this.store,
    required this.notifications,
    required this.nextBuilder,
    this.onTokenReady,
  });

  final CoopStore store;
  final CoopSignalHub notifications;
  final WidgetBuilder nextBuilder;
  final Future<void> Function(String token)? onTokenReady;

  @override
  State<SignalInvite> createState() => _SignalInviteState();
}

class _SignalInviteState extends State<SignalInvite> {
  bool _working = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    // SprintGate locks portrait before routing here; the invite screen must
    // re-enable landscape so it rotates with the device (matches WebView).
    SystemChrome.setPreferredOrientations(const <DeviceOrientation>[
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  Future<void> _accept() async {
    if (_working) return;
    setState(() => _working = true);
    final granted = await widget.notifications.askPermission();
    final token = widget.notifications.token;
    if (granted && token != null && token.isNotEmpty) {
      await widget.onTokenReady?.call(token);
    }
    if (!granted) await _snooze();
    _continue();
  }

  Future<void> _skip() async {
    if (_working) return;
    setState(() => _working = true);
    await _snooze();
    _continue();
  }

  Future<void> _snooze() {
    final until =
        DateTime.now().millisecondsSinceEpoch ~/ 1000 +
        CoopRelayConfig.pushSnoozeSeconds;
    return widget.store.snoozePushInvite(until);
  }

  void _continue() {
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute<void>(builder: widget.nextBuilder));
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final landscape = media.orientation == Orientation.landscape;
    final background = landscape
        ? 'assets/Horizontal_Notifications_Screen.webp'
        : 'assets/Vertical_Notifications_Screen.webp';
    // Bigger, easy-to-hit buttons. Landscape: centred horizontally with NO
    // safe-area so the notch never shifts the horizontal centre.
    // Buttons scaled down 15% per design request.
    const scale = 0.85;
    final width = (landscape
            ? (media.size.width * 0.42).clamp(320.0, 560.0)
            : (media.size.width * 0.80).clamp(280.0, 440.0)) *
        scale;
    final acceptH = (landscape ? 66.0 : 74.0) * scale;
    final skipH = (landscape ? 58.0 : 64.0) * scale;
    final acceptFont = (landscape ? 22.0 : 25.0) * scale;
    final skipFont = (landscape ? 20.0 : 22.0) * scale;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.asset(
            background,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
          ),
          Align(
            alignment: Alignment(0, landscape ? 0.80 : 0.90),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _InviteButton(
                  width: width,
                  height: acceptH,
                  fontSize: acceptFont,
                  label: 'Accept',
                  emphasized: true,
                  busy: _working,
                  onTap: _accept,
                ),
                SizedBox(height: landscape ? 12 : 16),
                _InviteButton(
                  width: width * 0.9,
                  height: skipH,
                  fontSize: skipFont,
                  label: 'Skip',
                  emphasized: false,
                  busy: false,
                  onTap: _skip,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InviteButton extends StatelessWidget {
  const _InviteButton({
    required this.width,
    required this.height,
    required this.fontSize,
    required this.label,
    required this.emphasized,
    required this.busy,
    required this.onTap,
  });

  final double width;
  final double height;
  final double fontSize;
  final String label;
  final bool emphasized;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = height / 2;
    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          gradient: LinearGradient(
            colors: emphasized
                ? const <Color>[Color(0xFFFFCF4A), Color(0xFFFF7D2C)]
                : const <Color>[Color(0xFFFFA63D), Color(0xFFD94A2A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          border: Border.all(color: const Color(0xFF6E301B), width: 3),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Colors.black45,
              blurRadius: 12,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(radius),
            onTap: busy ? null : onTap,
            child: Center(
              child: busy
                  ? const SizedBox.square(
                      dimension: 26,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.6,
                        color: Color(0xFF4A2315),
                      ),
                    )
                  : Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF3D1C12),
                        fontSize: fontSize,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
                        height: 1.0,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
