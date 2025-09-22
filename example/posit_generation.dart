// Generates all posits for a given bit size and exponent size
// Example: dart run example/posit_generation.dart 4 1
import 'package:posit/posit.dart';

void main(List<String> args) {
  // default to 8 bits and 2 exponent bits, but use command line arguments if provided
  final nbits = args.isNotEmpty ? int.parse(args[0]) : 8;
  final es = args.length > 1 ? int.parse(args[1]) : 2;
  final nPosits = 1 << nbits;
  for (int i = 0; i < nPosits; i++) {
    final posit = Posit.fromBits(i, nbits: nbits, es: es);
    final comma = i < nPosits - 1 ? ',' : '';
    print(
      '(bits: ${posit.bits.toRadixString(2).padLeft(nbits, '0')}.b, sign: ${posit.signBit.toRadixString(2)}.b, k: ${posit.k}, regime: ${posit.regime.toRadixString(2)}.b, exponent: ${posit.exponent}, fraction: ${posit.fractionValue}, value: ${posit.toDouble()})$comma',
    );
  }
}
