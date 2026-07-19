import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'coop/boot/sprint_gate.dart';
import 'coop/config/coop_relay_config.dart';
import 'coop/infra/coop_signal_hub.dart';
import 'coop/infra/coop_store.dart';
import 'coop/infra/link_probe.dart';
import 'coop/infra/relay_exchange.dart';
import 'coop/infra/trail_attribution.dart';
import 'coop/infra/yard_agent.dart';
import 'coop/sprint_coordinator.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final store = CoopStore();
  final agent = YardAgent();
  await Future.wait<void>(<Future<void>>[
    store.initialize(),
    agent.prepare(),
  ]);

  assert(() {
    debugPrint(
      '[HYS.BOOT] credentialsReady=${CoopRelayConfig.grayCredentialsReady} '
      'endpoint=${CoopRelayConfig.endpoint} '
      'afKeyLen=${CoopRelayConfig.appsFlyerKey.length} '
      'fbNum=${CoopRelayConfig.firebaseProjectNumber}',
    );
    return true;
  }());

  var productionServicesReady = false;
  if (CoopRelayConfig.grayCredentialsReady) {
    try {
      await Firebase.initializeApp();
      productionServicesReady = true;
    } catch (error) {
      assert(() {
        debugPrint('[HYS.BOOT] Firebase.initializeApp failed: $error');
        return true;
      }());
    }
    if (productionServicesReady) {
      try {
        await FirebaseAppCheck.instance.activate(
          providerApple: kDebugMode
              ? const AppleDebugProvider()
              : const AppleAppAttestWithDeviceCheckFallbackProvider(),
        );
      } catch (error) {
        // App Check must never block FCM / gray routing.
        assert(() {
          debugPrint('[HYS.BOOT] AppCheck skipped: $error');
          return true;
        }());
      }
    }
  }

  final probe = LinkProbe();
  // Attribution + config POST must run even if Firebase failed to init; only
  // push/FCM needs productionServicesReady.
  final notifications = CoopSignalHub(store, enabled: productionServicesReady);
  final attribution = TrailAttribution(agent);
  final coordinator = SprintCoordinator(
    store: store,
    probe: probe,
    attribution: attribution,
    exchange: RelayExchange(agent, store),
    notifications: notifications,
    agent: agent,
    runtimeEnabled: CoopRelayConfig.grayCredentialsReady,
  );

  // Allow both orientations while the boot screen is shown; the game locks
  // portrait once routing decides (see SprintGate).
  SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  runApp(HenYardSprintApp(coordinator: coordinator));
}

class HenYardSprintApp extends StatelessWidget {
  const HenYardSprintApp({super.key, this.coordinator});

  final SprintCoordinator? coordinator;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hen Yard Sprint',
      debugShowCheckedModeBanner: false,
      theme: HenTheme.build(),
      home: SprintGate(coordinator: coordinator),
    );
  }
}
