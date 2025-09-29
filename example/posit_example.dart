import 'package:posit/posit.dart';

void main() {
  print('Posit Number System Example');
  print('==========================');

  // Create Posit numbers from different sources
  final p1 = Posit.fromNum(3.14159);
  final p2 = Posit.fromNum(2.71828);
  final p3 = Posit.fromNum(1.0, nbits: 16, es: 1);

  print('Created Posit numbers:');
  print('p1 (32-bit, es=2): $p1');
  print('p2 (32-bit, es=2): $p2');
  print('p3 (16-bit, es=1): $p3');
  print('');

  // Basic arithmetic operations
  print('Arithmetic Operations:');
  final sum = p1 + p2;
  final diff = p1 - p2;
  final product = p1 * p2;
  final quotient = p1 / p2;

  print('p1 + p2 = $sum');
  print('p1 - p2 = $diff');
  print('p1 * p2 = $product');
  print('p1 / p2 = $quotient');
  print('');

  // Operations with regular numbers
  print('Operations with regular numbers:');
  final withInt = p1 + 5;
  final withDouble = p1 * 2.5;

  print('p1 + 5 = $withInt');
  print('p1 * 2.5 = $withDouble');
  print('');

  // Utility functions
  print('Utility Functions:');
  final abs = PositUtils.abs(Posit.fromNum(-3.14));
  final sqrt = PositUtils.sqrt(Posit.fromNum(16.0));
  final power = PositUtils.pow(Posit.fromNum(2.0), 3);
  final min = PositUtils.min(p1, p2);
  final max = PositUtils.max(p1, p2);

  print('abs(-3.14) = $abs');
  print('sqrt(16.0) = $sqrt');
  print('2.0^3 = $power');
  print('min(p1, p2) = $min');
  print('max(p1, p2) = $max');
  print('');

  // New getter properties
  print('Posit Properties:');
  print('p1.isZero: ${p1.isZero}');
  print('p1.isNegative: ${p1.isNegative}');
  print('p1.isPositive: ${p1.isPositive}');
  print('p1.isFinite: ${p1.isFinite}');
  print('p1.isNaR: ${p1.isNaR}');
  print('p1.toDebugString(): ${p1.toDebugString()}');
  print('p1.toDebugString(radix: 10): ${p1.toDebugString(radix: 10)}');
  print('p1.toDebugString(radix: 16): ${p1.toDebugString(radix: 16)}');
  print('');

  // Trigonometric functions
  print('Trigonometric Functions:');
  final angle = Posit.fromNum(1.5708); // π/2
  final sinValue = PositUtils.sin(angle);
  final cosValue = PositUtils.cos(angle);
  final tanValue = PositUtils.tan(angle);

  print('sin(π/2) = $sinValue');
  print('cos(π/2) = $cosValue');
  print('tan(π/2) = $tanValue');
  print('');

  // Comparison operations
  print('Comparison Operations:');
  print('p1 == p2: ${p1 == p2}');
  print('p1.compareTo(p2): ${p1.compareTo(p2)}');
  print('p1 > p2: ${p1.compareTo(p2) > 0}');
  print('p1 < p2: ${p1.compareTo(p2) < 0}');
  print('');

  // Special values
  print('Special Values:');
  final zero = Posit.zeroWithConfig();
  final negativeZero = Posit.zeroWithConfig();
  final infinity = Posit.naRWithConfig();
  final negativeInfinity = Posit.naRWithConfig();
  final nan = Posit.naRWithConfig();

  print('Zero: $zero');
  print('Negative Zero: $negativeZero');
  print('Infinity: $infinity');
  print('Negative Infinity: $negativeInfinity');
  print('NaN: $nan');

  // Static constants
  print('Static Constants:');
  print('Posit.zero: ${Posit.zero}');
  print('Posit.naR: ${Posit.naR}');
  print('Posit.zero.isZero: ${Posit.zero.isZero}');
  print('Posit.naR.isNaR: ${Posit.naR.isNaR}');
  print('');

  // Different bit sizes
  print('Different Bit Sizes:');
  final p4 = Posit.fromNum(1.0, nbits: 4, es: 0);
  final p8 = Posit.fromNum(2.0, nbits: 8, es: 1);
  final p16 = Posit.fromNum(3.0, nbits: 16, es: 2);
  final p64 = Posit.fromNum(4.0, nbits: 64, es: 3);

  print('4-bit posit: $p4 (nbits: ${p4.nbits}, es: ${p4.es})');
  print('8-bit posit: $p8 (nbits: ${p8.nbits}, es: ${p8.es})');
  print('16-bit posit: $p16 (nbits: ${p16.nbits}, es: ${p16.es})');
  print('64-bit posit: $p64 (nbits: ${p64.nbits}, es: ${p64.es})');
  print('');

  // Bitwise field extraction
  print('Bitwise Field Extraction:');
  final p = Posit.fromNum(2.5, nbits: 8, es: 1);
  print('Posit: $p');
  print('Bits: 0x${p.bits.toRadixString(16)}');
  print('Sign: ${p.sign}');
  print('Regime: ${p.regime}');
  print('Exponent: ${p.exponent}');
  print('Fraction: ${p.fraction}');
  print('');

  // Num interface compatibility
  print('Num Interface Compatibility:');
  print('Parse: ${Posit.parse("3.14")}');
  print('TryParse: ${Posit.tryParse("2.718")}');
  print('Remainder: ${p1.remainder(p2)}');
  print('Modulo: ${p1 % p2}');
  print('Truncating division: ${p1 ~/ p2}');
  print('Comparison: ${p1 > p2}');
  print('Properties: isFinite=${p1.isFinite}, isNegative=${p1.isNegative}');
  print('Sign: ${p1.sign}');
  print('Round: ${p1.round()}, Floor: ${p1.floor()}, Ceil: ${p1.ceil()}');
  print('Clamp: ${p1.clamp(1.0, 2.0)}');
  print('String formatting: ${p1.toStringAsFixed(2)}');
  print('');

  // Properties
  print('Properties:');
  print('p1.nbits: ${p1.nbits}');
  print('p1.es: ${p1.es}');
  print('p1.bits: 0x${p1.bits.toRadixString(16)}');
  print('p1.toDouble(): ${p1.toDouble()}');
  print('p1.toInt(): ${p1.toInt()}');
}
