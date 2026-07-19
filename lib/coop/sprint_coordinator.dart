import 'dart:async';
import 'dart:io';

import 'config/coop_relay_config.dart';
import 'core/relay_models.dart';
import 'infra/cold_tap_reader.dart';
import 'infra/coop_signal_hub.dart';
import 'infra/coop_store.dart';
import 'infra/link_probe.dart';
import 'infra/relay_exchange.dart';
import 'infra/trail_attribution.dart';
import 'infra/yard_agent.dart';

class SprintCoordinator {
  SprintCoordinator({
    required this.store,
    required this.probe,
    required this.attribution,
    required this.exchange,
    required this.notifications,
    required this.agent,
    required this.runtimeEnabled,
  });

  final CoopStore store;
  final LinkProbe probe;
  final TrailAttribution attribution;
  final RelayExchange exchange;
  final CoopSignalHub notifications;
  final YardAgent agent;
  final bool runtimeEnabled;

  bool get enabled => runtimeEnabled && CoopRelayConfig.grayCredentialsReady;

  Future<SprintTarget>? _decideFuture;

  /// De-duplicates only *concurrent* calls (the boot screen can build twice at
  /// startup → avoids a double attribution / config POST). The cache is
  /// cleared once the pipeline finishes, so a later call — e.g. Retry from the
  /// offline screen after Wi-Fi returns — runs the whole pipeline again
  /// instead of replaying the cached NoLineTarget forever.
  Future<SprintTarget> decide({
    required void Function(double value) onProgress,
  }) =>
      _decideFuture ??= _decide(onProgress: onProgress)
          .whenComplete(() => _decideFuture = null);

  Future<SprintTarget> _decide({
    required void Function(double value) onProgress,
  }) async {
    if (!enabled) {
      assert(() {
        // ignore: avoid_print
        print(
          '[HYS.RELAY] gate disabled '
          'runtime=$runtimeEnabled creds=${CoopRelayConfig.grayCredentialsReady}',
        );
        return true;
      }());
      onProgress(1);
      return const YardTarget();
    }

    assert(() {
      // ignore: avoid_print
      print('[HYS.RELAY] decide start route=${store.route}');
      return true;
    }());

    notifications.onTokenChanged = _refreshForToken;
    final coldRoute = await ColdTapReader.consume();
    if (coldRoute != null) {
      await store.saveRoute(SprintRoute.browser);
      await store.consumePushUrl();
      unawaited(_backgroundDispatch());
      onProgress(1);
      return BrowserTarget(coldRoute, coldLaunch: true);
    }

    onProgress(0.12);
    return switch (store.route) {
      SprintRoute.undecided => _firstDecision(onProgress),
      SprintRoute.browser => _returningBrowser(onProgress),
      SprintRoute.yard => _returningYard(onProgress),
    };
  }

  Future<SprintTarget> _firstDecision(
    void Function(double) progress,
  ) async {
    if (!await probe.hasInterface()) {
      assert(() {
        // ignore: avoid_print
        print('[HYS.RELAY] first: no interface → offline');
        return true;
      }());
      return const NoLineTarget(returnToYard: false);
    }
    progress(0.28);
    try {
      await notifications.boot();
    } catch (_) {}
    if (!await probe.canReachNetwork()) {
      assert(() {
        // ignore: avoid_print
        print('[HYS.RELAY] first: DNS probe failed → offline');
        return true;
      }());
      return const NoLineTarget(returnToYard: false);
    }
    progress(0.48);
    await attribution.awaitSignals();
    progress(0.72);
    final reply = await _requestConfig();
    progress(1);
    assert(() {
      // ignore: avoid_print
      print(
        '[HYS.RELAY] first: config hasDest=${reply.hasDestination} '
        'url=${reply.url}',
      );
      return true;
    }());
    if (reply.hasDestination) {
      await store.saveRoute(SprintRoute.browser);
      return BrowserTarget(reply.url!);
    }
    await store.saveRoute(SprintRoute.yard);
    return const YardTarget();
  }

  Future<SprintTarget> _returningBrowser(
    void Function(double) progress,
  ) async {
    if (!await probe.hasInterface()) {
      return const NoLineTarget(returnToYard: false);
    }
    final pending = await store.consumePushUrl();
    if (pending != null && pending.isNotEmpty) {
      progress(1);
      return BrowserTarget(pending);
    }
    final cached = await store.savedUrl();
    if (cached != null && !store.cachedUrlExpired) {
      progress(1);
      return BrowserTarget(cached);
    }

    await Future.wait<void>(<Future<void>>[
      notifications.boot(),
      attribution.start(),
    ]);
    if (!await probe.canReachNetwork()) {
      return const NoLineTarget(returnToYard: false);
    }
    progress(0.62);
    await attribution.awaitSignals(installTimeout: const Duration(seconds: 5));
    final reply = await _requestConfig();
    progress(1);
    if (reply.hasDestination) return BrowserTarget(reply.url!);
    if (cached != null) return BrowserTarget(cached);
    return const NoLineTarget(returnToYard: false);
  }

  Future<SprintTarget> _returningYard(
    void Function(double) progress,
  ) async {
    if (!await probe.hasInterface()) {
      progress(1);
      return const YardTarget();
    }
    await Future.wait<void>(<Future<void>>[
      notifications.boot(),
      attribution.start(),
    ]);
    if (!await probe.canReachNetwork()) {
      progress(1);
      return const YardTarget();
    }
    progress(0.55);
    await attribution.awaitSignals();
    final reply = await _requestConfig();
    progress(1);
    if (!reply.hasDestination) return const YardTarget();
    await store.saveRoute(SprintRoute.browser);
    return BrowserTarget(reply.url!);
  }

  Future<RelayReply> _requestConfig({String? token}) async {
    final body = await attribution.compose(
      locale: Platform.localeName.replaceAll('-', '_'),
      pushToken: token ?? notifications.token,
    );
    return exchange.request(body);
  }

  Future<void> _backgroundDispatch() async {
    try {
      await Future.wait<void>(<Future<void>>[
        notifications.boot(),
        attribution.awaitSignals(),
      ]);
      await _requestConfig();
    } catch (_) {}
  }

  Future<void> _refreshForToken(String token) async {
    try {
      await _requestConfig(token: token);
    } catch (_) {}
  }
}
