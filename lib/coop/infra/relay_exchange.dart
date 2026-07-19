import 'dart:convert';

import '../config/coop_relay_config.dart';
import '../core/relay_models.dart';
import 'coop_store.dart';
import 'trail_attribution.dart';
import 'yard_agent.dart';

class RelayExchange {
  RelayExchange(this._agent, this._store);

  final YardAgent _agent;
  final CoopStore _store;

  Future<RelayReply> request(Map<String, dynamic> payload) async {
    if (!CoopRelayConfig.grayCredentialsReady) {
      return RelayReply.rejected('credentials_unavailable');
    }
    try {
      henTrace(() => '[HYS.EXCHANGE] request ${jsonEncode(payload)}');
      final response = await _agent
          .post(
            Uri.parse(CoopRelayConfig.endpoint),
            headers: const <String, String>{
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 15));
      henTrace(
        () => '[HYS.EXCHANGE] response ${response.statusCode} ${response.body}',
      );
      if (response.statusCode != 200) {
        return RelayReply.rejected('http_${response.statusCode}');
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map) return RelayReply.rejected('invalid_response');
      final reply = RelayReply.fromJson(Map<String, dynamic>.from(decoded));
      if (reply.hasDestination) {
        await _store.cacheUrl(reply.url!, reply.expiresAt);
      }
      return reply;
    } catch (error) {
      henTrace(() => '[HYS.EXCHANGE] failed: $error');
      return RelayReply.rejected('network_failure');
    }
  }
}
