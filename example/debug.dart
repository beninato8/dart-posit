import 'package:posit/posit.dart';

extension Binary on int {
  int get b {
    return int.parse(toRadixString(10), radix: 2);
  }
}

void main() {
  int nbits = 3;
  int es = 0;
  final tests = [
    (bits: 000.b, regime: 00.b),
    (bits: 001.b, regime: 01.b),
    (bits: 010.b, regime: 10.b),
    (bits: 011.b, regime: 11.b),
    (bits: 100.b, regime: 00.b),
    (bits: 101.b, regime: 01.b),
    (bits: 110.b, regime: 10.b),
    (bits: 111.b, regime: 11.b),
  ];
  for (final test in tests) {
    final a = PositEncoding.extractRegimeBits(test.bits, nbits);
    print(
      '${test.bits.toRadixString(2).padLeft(nbits, '0')}, regime: ${test.regime.toRadixString(2).padLeft(nbits, '0')}, extracted: ${a.toRadixString(2).padLeft(nbits, '0')}',
    );
  }
}
