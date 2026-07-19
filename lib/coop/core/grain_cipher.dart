import 'dart:typed_data';

// Per-project cipher seed. Keep in sync with tool/encode_coop_values.dart.
// Unique to Hen Yard Sprint — never reuse across sibling apps.
const List<int> _coopSeed = <int>[
  0x48,
  0x59,
  0x53,
  0x70,
  0x72,
  0x69,
  0x6E,
  0x74,
  0x2E,
  0x32,
  0x30,
  0x32,
  0x36,
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

String unscrambleGrain(List<int> encoded) {
  if (encoded.isEmpty) return '';
  final stream = _buildGrainStream(encoded.length);
  final plain = Uint8List(encoded.length);
  for (var index = 0; index < encoded.length; index++) {
    plain[index] = (encoded[index] - stream[index] - (index * 17)) & 0xff;
  }
  return String.fromCharCodes(plain);
}
