// ignore_for_file: avoid_print

import 'dart:typed_data';

// Per-project cipher seed. MUST stay in sync with `_coopSeed` in
// lib/coop/core/grain_cipher.dart. Unique to Hen Yard Sprint.
const List<int> _coopSeed = <int>[
  0x48, // H
  0x59, // Y
  0x53, // S
  0x70, // p
  0x72, // r
  0x69, // i
  0x6E, // n
  0x74, // t
  0x2E, // .
  0x32, // 2
  0x30, // 0
  0x32, // 2
  0x36, // 6
];

Uint8List _buildGrainStream(int length) {
  final state = List<int>.generate(256, (index) => index);
  var cursor = 0;
  for (var index = 0; index < state.length; index++) {
    cursor =
        (cursor + state[index] + _coopSeed[index % _coopSeed.length]) & 0xff;
    final swap = state[index];
    state[index] = state[cursor];
    state[cursor] = swap;
  }
  final result = Uint8List(length);
  var left = 0;
  var right = 0;
  for (var index = 0; index < length; index++) {
    left = (left + 1) & 0xff;
    right = (right + state[left] + index) & 0xff;
    final swap = state[left];
    state[left] = state[right];
    state[right] = swap;
    result[index] = state[(state[left] + state[right]) & 0xff];
  }
  return result;
}

List<int> scramble(String value) {
  final bytes = Uint8List.fromList(value.codeUnits);
  final stream = _buildGrainStream(bytes.length);
  return List<int>.generate(
    bytes.length,
    (index) => (bytes[index] + stream[index] + (index * 17)) & 0xff,
  );
}

String unscramble(List<int> encoded) {
  final stream = _buildGrainStream(encoded.length);
  return String.fromCharCodes(
    List<int>.generate(
      encoded.length,
      (index) => (encoded[index] - stream[index] - (index * 17)) & 0xff,
    ),
  );
}

void main() {
  const values = <String, String>{
    'config': 'https://henyardsprint.com/config.php',
    'privacy': 'https://henyardsprint.com/privacy-policy.html',
    'support': 'https://henyardsprint.com/support.html',
    'gcd': 'https://gcdsdk.appsflyer.com/install_data/v5.0/',
    'webkit': '605.1.15',
    'safari': '18.5',
    'safariTail': '604.1',
    'appsFlyerDevKey': 'B9PsHxGS7JgMjBuuvT4HP6',
    'firebaseProjectNumber': '678053926329',
    'oneLinkHost': 'henyardsprint.onelink.me',
  };

  for (final entry in values.entries) {
    final encoded = scramble(entry.value);
    print('${entry.key}: <int>[${encoded.join(', ')}]');
    if (unscramble(encoded) != entry.value) {
      throw StateError('Round-trip failed for ${entry.key}');
    }
  }
  print('VERIFY: all values round-tripped');
}
