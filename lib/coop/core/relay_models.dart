enum SprintRoute {
  browser,
  yard,
  undecided;

  String get storageValue => switch (this) {
    SprintRoute.browser => 'browser',
    SprintRoute.yard => 'yard',
    SprintRoute.undecided => 'undecided',
  };

  static SprintRoute parse(String? value) => switch (value) {
    'browser' || 'web' || 'portal' => SprintRoute.browser,
    'yard' || 'game' || 'native' => SprintRoute.yard,
    _ => SprintRoute.undecided,
  };
}

class RelayReply {
  const RelayReply({
    required this.accepted,
    this.url,
    this.expiresAt,
    this.reason,
  });

  factory RelayReply.fromJson(Map<String, dynamic> json) {
    final rawExpiry = json['expires'];
    return RelayReply(
      accepted: json['ok'] == true,
      url: json['url'] is String ? json['url'] as String : null,
      expiresAt: rawExpiry is num
          ? rawExpiry.toInt()
          : int.tryParse(rawExpiry?.toString() ?? ''),
      reason: json['message']?.toString(),
    );
  }

  factory RelayReply.rejected(String reason) =>
      RelayReply(accepted: false, reason: reason);

  final bool accepted;
  final String? url;
  final int? expiresAt;
  final String? reason;

  bool get hasDestination => accepted && (url?.isNotEmpty ?? false);
}

sealed class SprintTarget {
  const SprintTarget();
}

final class YardTarget extends SprintTarget {
  const YardTarget();
}

final class BrowserTarget extends SprintTarget {
  const BrowserTarget(this.url, {this.coldLaunch = false});

  final String url;
  final bool coldLaunch;
}

final class NoLineTarget extends SprintTarget {
  const NoLineTarget({required this.returnToYard});

  final bool returnToYard;
}
