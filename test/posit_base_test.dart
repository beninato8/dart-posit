import 'dart:math';

import 'package:posit/posit.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  group('Posit', () {
    group('fromNum', () {
      test('with default parameters', () {
        final p = Posit.fromNum(3.14);
        expect(p.nbits, equals(32));
        expect(p.es, equals(2));
        expect(p.toDouble(), closeTo(3.14, 0.01));
      });

      test('with custom parameters', () {
        final p = Posit.fromNum(1.0, nbits: 16, es: 1);
        expect(p.nbits, equals(16));
        expect(p.es, equals(1));
        expect(p.toDouble(), closeTo(1.0, 0.01));
      });

      test('with zero', () {
        final p = Posit.fromNum(0.0);
        expect(p.isZero, isTrue);
        expect(p.toDouble(), equals(0.0));
      });

      test('with negative number', () {
        final p = Posit.fromNum(-2.5);
        expect(p.isNegative, isTrue);
        expect(p.toDouble(), closeTo(-2.5, 0.01));
      });

      test('with infinity', () {
        final p = Posit.fromNum(double.infinity);
        expect(p.isNaR, isTrue);
      });

      test('with negative infinity', () {
        final p = Posit.fromNum(double.negativeInfinity);
        expect(p.isNaR, isTrue);
      });

      test('with NaN', () {
        final p = Posit.fromNum(double.nan);
        expect(p.isNaR, isTrue);
      });
    });

    group('fromBits', () {
      test('with default parameters', () {
        final p = Posit.fromBits(0x40000000); // 1.0 in 32-bit posit
        expect(p.nbits, equals(32));
        expect(p.es, equals(2));
        expect(p.toDouble(), closeTo(1.0, 0.01));
      });

      test('with custom parameters', () {
        final p = Posit.fromBits(0x40, nbits: 8, es: 1);
        expect(p.nbits, equals(8));
        expect(p.es, equals(1));
      });

      test('with zero', () {
        final p = Posit.fromBits(0);
        expect(p.isZero, isTrue);
        expect(p.toDouble(), equals(0.0));
      });

      test('with NaR pattern', () {
        final p = Posit.fromBits(0x80000000);
        expect(p.isNaR, isTrue);
      });
    });

    group('fromComponents', () {
      test('with positive regime', () {
        final p = Posit.fromComponents(0, 1, 0, 0, nbits: 8, es: 2);
        expect(p.nbits, equals(8));
        expect(p.es, equals(2));
        expect(p.signBit, equals(0));
        expect(p.regime, equals(10.b));
        expect(p.exponent, equals(0));
        expect(p.fraction, equals(0));
      });

      test('with negative regime', () {
        final p = Posit.fromComponents(1, 0, 0, 0, nbits: 8, es: 2);
        expect(p.signBit, equals(1));
        expect(p.regime, equals(0));
        expect(p.exponent, equals(0));
        expect(p.fraction, equals(0));
      });

      test('with custom parameters', () {
        final p = Posit.fromComponents(0, 2, 1, 0, nbits: 16, es: 1);
        expect(p.bits, equals(0110100000000000.b));
        expect(p.nbits, equals(16));
        expect(p.es, equals(1));
        expect(p.signBit, equals(0));
        expect(p.regime, equals(110.b));
        expect(p.exponent, equals(1.b));
        expect(p.fraction, equals(0));
      });
    });

    group('naRWithConfig', () {
      test('with default parameters', () {
        final p = Posit.naRWithConfig();
        expect(p.nbits, equals(32));
        expect(p.es, equals(2));
        expect(p.isNaR, isTrue);
      });

      test('with custom parameters', () {
        final p = Posit.naRWithConfig(nbits: 16, es: 1);
        expect(p.nbits, equals(16));
        expect(p.es, equals(1));
        expect(p.isNaR, isTrue);
      });
    });

    group('zeroWithConfig', () {
      test('with default parameters', () {
        final p = Posit.zeroWithConfig();
        expect(p.nbits, equals(32));
        expect(p.es, equals(2));
        expect(p.isZero, isTrue);
      });

      test('with custom parameters', () {
        final p = Posit.zeroWithConfig(nbits: 16, es: 1);
        expect(p.nbits, equals(16));
        expect(p.es, equals(1));
        expect(p.isZero, isTrue);
      });
    });

    group('parse', () {
      test('with integer string', () {
        final p = Posit.parse('42');
        expect(p.toDouble(), closeTo(42.0, 0.01));
      });

      test('with decimal string', () {
        final p = Posit.parse('3.14');
        expect(p.toDouble(), closeTo(3.14, 0.01));
      });

      test('with negative string', () {
        final p = Posit.parse('-2.5');
        expect(p.isNegative, isTrue);
        expect(p.toDouble(), closeTo(-2.5, 0.01));
      });

      test('with custom parameters', () {
        final p = Posit.parse('1.0', nbits: 16, es: 1);
        expect(p.toDouble(), closeTo(1.0, 0.01));
        expect(p.nbits, equals(16));
        expect(p.es, equals(1));
      });

      test('with invalid string throws FormatException', () {
        expect(() => Posit.parse('invalid'), throwsA(isA<FormatException>()));
      });
    });

    group('tryParse', () {
      test('with valid string', () {
        final p = Posit.tryParse('42');
        expect(p, isNotNull);
        expect(p!.toDouble(), closeTo(42.0, 0.01));
      });

      test('with invalid string returns null', () {
        final p = Posit.tryParse('invalid');
        expect(p, isNull);
      });

      test('with custom parameters', () {
        final p = Posit.tryParse('1.0', nbits: 16, es: 1);
        expect(p, isNotNull);
        expect(p!.nbits, equals(16));
        expect(p.es, equals(1));
      });
    });

    group('Parameter Validation', () {
      test('nbits too small throws ArgumentError', () {
        expect(() => Posit.fromNum(1.0, nbits: 1), throwsA(isA<ArgumentError>()));
      });

      test('nbits too large throws ArgumentError', () {
        expect(() => Posit.fromNum(1.0, nbits: 65), throwsA(isA<ArgumentError>()));
      });

      test('es negative throws ArgumentError', () {
        expect(() => Posit.fromNum(1.0, es: -1), throwsA(isA<ArgumentError>()));
      });

      test('es too large throws ArgumentError', () {
        expect(() => Posit.fromNum(1.0, es: 90), throwsA(isA<ArgumentError>()));
      });

      test('valid parameters do not throw', () {
        expect(() => Posit.fromNum(1.0, nbits: 8, es: 2), returnsNormally);
      });
    });

    group('Boolean Properties', () {
      test('isNaR for NaR', () {
        final p = Posit.naR;
        expect(p.isNaR, isTrue);
      });

      test('isNaR for non-NaR', () {
        final p = Posit.fromNum(1.0);
        expect(p.isNaR, isFalse);
      });

      test('isSpecial for NaR', () {
        final p = Posit.naR;
        expect(p.isSpecial, isTrue);
      });

      test('isSpecial for zero', () {
        final p = Posit.zero;
        expect(p.isSpecial, isTrue);
      });

      test('isSpecial for regular number', () {
        final p = Posit.fromNum(1.0);
        expect(p.isSpecial, isFalse);
      });

      test('isZero for zero', () {
        final p = Posit.zero;
        expect(p.isZero, isTrue);
      });

      test('isZero for non-zero', () {
        final p = Posit.fromNum(1.0);
        expect(p.isZero, isFalse);
      });

      test('isNegative for negative number', () {
        final p = Posit.fromNum(-1.0);
        expect(p.isNegative, isTrue);
      });

      test('isNegative for positive number', () {
        final p = Posit.fromNum(1.0);
        expect(p.isNegative, isFalse);
      });

      test('isPositive for positive number', () {
        final p = Posit.fromNum(1.0);
        expect(p.isPositive, isTrue);
      });

      test('isPositive for negative number', () {
        final p = Posit.fromNum(-1.0);
        expect(p.isPositive, isFalse);
      });

      test('isPositive for zero', () {
        final p = Posit.zero;
        expect(p.isPositive, isFalse);
      });

      test('isPositive for NaR', () {
        final p = Posit.naR;
        expect(p.isPositive, isFalse);
      });

      test('isFinite for regular number', () {
        final p = Posit.fromNum(1.0);
        expect(p.isFinite, isTrue);
      });

      test('isFinite for NaR', () {
        final p = Posit.naR;
        expect(p.isFinite, isFalse);
      });
    });

    group('Conversion', () {
      test('toDouble for positive number', () {
        final p = Posit.fromNum(3.14);
        final result = p.toDouble();
        expect(result, closeTo(3.14, 0.01));
      });

      test('toDouble for negative number', () {
        final p = Posit.fromNum(-2.5);
        final result = p.toDouble();
        expect(result, closeTo(-2.5, 0.01));
      });

      test('toDouble for zero', () {
        final p = Posit.zero;
        final result = p.toDouble();
        expect(result, equals(0.0));
      });

      test('toDouble for NaR', () {
        final p = Posit.naR;
        final result = p.toDouble();
        expect(result.isNaN, isTrue);
      });

      test('toInt for positive number', () {
        final p = Posit.fromNum(3.7);
        final result = p.toInt();
        expect(result, equals(4));
      });

      test('toInt for negative number', () {
        final p = Posit.fromNum(-2.3);
        final result = p.toInt();
        expect(result, equals(-2));
      });
    });

    group('Arithmetic Operators', () {
      test('addition with Posit', () {
        final a = Posit.fromNum(2.0);
        final b = Posit.fromNum(3.0);
        final result = a + b;
        expect(result.toDouble(), closeTo(5.0, 0.01));
      });

      test('addition with num', () {
        final a = Posit.fromNum(2.0);
        final result = a + 3.0;
        expect(result.toDouble(), closeTo(5.0, 0.01));
      });

      test('subtraction with Posit', () {
        final a = Posit.fromNum(5.0);
        final b = Posit.fromNum(3.0);
        final result = a - b;
        expect(result.toDouble(), closeTo(2.0, 0.01));
      });

      test('subtraction with num', () {
        final a = Posit.fromNum(5.0);
        final result = a - 3.0;
        expect(result.toDouble(), closeTo(2.0, 0.01));
      });

      test('multiplication with Posit', () {
        final a = Posit.fromNum(2.0);
        final b = Posit.fromNum(3.0);
        final result = a * b;
        expect(result.toDouble(), closeTo(6.0, 0.01));
      });

      test('multiplication with num', () {
        final a = Posit.fromNum(2.0);
        final result = a * 3.0;
        expect(result.toDouble(), closeTo(6.0, 0.01));
      });

      test('division with Posit', () {
        final a = Posit.fromNum(6.0);
        final b = Posit.fromNum(2.0);
        final result = a / b;
        expect(result.toDouble(), closeTo(3.0, 0.01));
      });

      test('division with num', () {
        final a = Posit.fromNum(6.0);
        final result = a / 2.0;
        expect(result.toDouble(), closeTo(3.0, 0.01));
      });

      test('unary minus', () {
        final a = Posit.fromNum(3.0);
        final result = -a;
        expect(result.toDouble(), closeTo(-3.0, 0.01));
      });

      test('addition with unsupported type throws UnsupportedError', () {
        final a = Posit.fromNum(1.0);
        expect(() => a + 'string', throwsA(isA<UnsupportedError>()));
      });
    });

    group('Comparison Operators', () {
      test('less than with Posit', () {
        final a = Posit.fromNum(2.0);
        final b = Posit.fromNum(3.0);
        expect(a < b, isTrue);
      });

      test('less than with num', () {
        final a = Posit.fromNum(2.0);
        expect(a < 3.0, isTrue);
      });

      test('less than or equal with Posit', () {
        final a = Posit.fromNum(2.0);
        final b = Posit.fromNum(3.0);
        expect(a <= b, isTrue);
        expect(a <= a, isTrue);
      });

      test('less than or equal with num', () {
        final a = Posit.fromNum(2.0);
        expect(a <= 3.0, isTrue);
        expect(a <= 2.0, isTrue);
      });

      test('greater than with Posit', () {
        final a = Posit.fromNum(3.0);
        final b = Posit.fromNum(2.0);
        expect(a > b, isTrue);
      });

      test('greater than with num', () {
        final a = Posit.fromNum(3.0);
        expect(a > 2.0, isTrue);
      });

      test('greater than or equal with Posit', () {
        final a = Posit.fromNum(3.0);
        final b = Posit.fromNum(2.0);
        expect(a >= b, isTrue);
        expect(a >= a, isTrue);
      });

      test('greater than or equal with num', () {
        final a = Posit.fromNum(3.0);
        expect(a >= 2.0, isTrue);
        expect(a >= 3.0, isTrue);
      });

      test('equality with Posit', () {
        final a = Posit.fromNum(2.0);
        final b = Posit.fromNum(2.0);
        expect(a == b, isTrue);
      });

      test('equality with different types', () {
        final a = Posit.fromNum(2.0);
        expect(a == 2.0, isFalse);
        expect(a == 'string', isFalse);
      });
    });

    group('Mathematical Methods', () {
      test('abs for positive number', () {
        final p = Posit.fromNum(2.5);
        final result = p.abs();
        expect(result.toDouble(), closeTo(2.5, 0.01));
      });

      test('abs for negative number', () {
        final p = Posit.fromNum(-2.5);
        final result = p.abs();
        expect(result.toDouble(), greaterThan(0));
      });

      test('sign for positive number', () {
        final p = Posit.fromNum(2.5);
        final result = p.sign;
        expect(result.toDouble(), closeTo(1.0, 0.01));
      });

      test('sign for negative number', () {
        final p = Posit.fromNum(-2.5);
        final result = p.sign;
        expect(result.toDouble(), closeTo(-1.0, 0.01));
      });

      test('sign for zero', () {
        final p = Posit.zero;
        final result = p.sign;
        expect(result.toDouble(), equals(0.0));
      });

      test('round for positive number', () {
        final p = Posit.fromNum(3.7);
        final result = p.round();
        expect(result, equals(4));
      });

      test('round for negative number', () {
        final p = Posit.fromNum(-2.3);
        final result = p.round();
        expect(result, equals(-2));
      });

      test('floor for positive number', () {
        final p = Posit.fromNum(3.7);
        final result = p.floor();
        expect(result, equals(3));
      });

      test('floor for negative number', () {
        final p = Posit.fromNum(-2.3);
        final result = p.floor();
        expect(result, equals(-3));
      });

      test('ceil for positive number', () {
        final p = Posit.fromNum(3.2);
        final result = p.ceil();
        expect(result, equals(4));
      });

      test('ceil for negative number', () {
        final p = Posit.fromNum(-2.7);
        final result = p.ceil();
        expect(result, equals(-2));
      });

      test('truncate for positive number', () {
        final p = Posit.fromNum(3.7);
        final result = p.truncate();
        expect(result, equals(3));
      });

      test('truncate for negative number', () {
        final p = Posit.fromNum(-2.7);
        final result = p.truncate();
        expect(result, equals(-2));
      });

      test('roundToDouble for positive number', () {
        final p = Posit.fromNum(3.7);
        final result = p.roundToDouble();
        expect(result, closeTo(4.0, 0.01));
      });

      test('floorToDouble for positive number', () {
        final p = Posit.fromNum(3.7);
        final result = p.floorToDouble();
        expect(result, closeTo(3.0, 0.01));
      });

      test('ceilToDouble for positive number', () {
        final p = Posit.fromNum(3.2);
        final result = p.ceilToDouble();
        expect(result, closeTo(4.0, 0.01));
      });

      test('truncateToDouble for positive number', () {
        final p = Posit.fromNum(3.7);
        final result = p.truncateToDouble();
        expect(result, closeTo(3.0, 0.01));
      });

      test('remainder with Posit', () {
        final a = Posit.fromNum(7.0);
        final b = Posit.fromNum(3.0);
        final result = a.remainder(b);
        expect(result.toDouble(), closeTo(1.0, 0.01));
      });

      test('remainder with num', () {
        final a = Posit.fromNum(7.0);
        final result = a.remainder(3.0);
        expect(result.toDouble(), closeTo(1.0, 0.01));
      });

      test('modulo with Posit', () {
        final a = Posit.fromNum(7.0);
        final b = Posit.fromNum(3.0);
        final result = a % b;
        expect(result.toDouble(), closeTo(1.0, 0.01));
      });

      test('modulo with num', () {
        final a = Posit.fromNum(7.0);
        final result = a % 3.0;
        expect(result.toDouble(), closeTo(1.0, 0.01));
      });

      test('truncating division with Posit', () {
        final a = Posit.fromNum(7.0);
        final b = Posit.fromNum(3.0);
        final result = a ~/ b;
        expect(result, equals(2));
      });

      test('truncating division with num', () {
        final a = Posit.fromNum(7.0);
        final result = a ~/ 3.0;
        expect(result, equals(2));
      });

      test('remainder with unsupported type throws UnsupportedError', () {
        final a = Posit.fromNum(7.0);
        expect(() => a.remainder('string'), throwsA(isA<UnsupportedError>()));
      });

      test('addPosits', () {
        final a = Posit.fromNum(2.0);
        final b = Posit.fromNum(3.0);
        final result = Posit.addPosits(a, b);
        expect(result.toDouble(), closeTo(5.0, 0.01));
      });

      test('subtractPosits', () {
        final a = Posit.fromNum(5.0);
        final b = Posit.fromNum(3.0);
        final result = Posit.subtractPosits(a, b);
        expect(result.toDouble(), closeTo(2.0, 0.01));
      });

      test('multiplyPosits', () {
        final a = Posit.fromNum(2.0);
        final b = Posit.fromNum(3.0);
        final result = Posit.multiplyPosits(a, b);
        expect(result.toDouble(), closeTo(6.0, 0.01));
      });

      test('dividePosits', () {
        final a = Posit.fromNum(6.0);
        final b = Posit.fromNum(2.0);
        final result = Posit.dividePosits(a, b);
        expect(result.toDouble(), closeTo(3.0, 0.01));
      });

      test('negatePosit', () {
        final a = Posit.fromNum(3.0);
        final result = Posit.negatePosit(a);
        expect(result.toDouble(), closeTo(-3.0, 0.01));
      });
    });

    group('Clamp', () {
      test('clamp with Posit limits', () {
        final p = Posit.fromNum(5.0);
        final lower = Posit.fromNum(2.0);
        final upper = Posit.fromNum(8.0);
        final result = p.clamp(lower, upper);
        expect(result.toDouble(), closeTo(5.0, 0.01));
      });

      test('clamp with num limits', () {
        final p = Posit.fromNum(5.0);
        final result = p.clamp(2.0, 8.0);
        expect(result.toDouble(), closeTo(5.0, 0.01));
      });

      test('clamp below minimum', () {
        final p = Posit.fromNum(1.0);
        final result = p.clamp(2.0, 8.0);
        expect(result.toDouble(), closeTo(2.0, 0.01));
      });

      test('clamp above maximum', () {
        final p = Posit.fromNum(10.0);
        final result = p.clamp(2.0, 8.0);
        expect(result.toDouble(), closeTo(8.0, 0.01));
      });
    });

    group('String Formatting', () {
      test('toStringAsFixed', () {
        final p = Posit.fromNum(3.14159);
        final result = p.toStringAsFixed(2);
        expect(result, equals('3.14'));
      });

      test('toStringAsExponential', () {
        final p = Posit.fromNum(1234.0);
        final result = p.toStringAsExponential(2);
        expect(result, equals('1.23e+3'));
      });

      test('toStringAsExponential with custom digits', () {
        final p = Posit.fromNum(1234.0);
        final result = p.toStringAsExponential(3);
        expect(result, equals('1.234e+3'));
      });

      test('toStringAsPrecision', () {
        final p = Posit.fromNum(3.14159);
        final result = p.toStringAsPrecision(3);
        expect(result, equals('3.14'));
      });

      test('toString returns exact format', () {
        final p = Posit.fromNum(3.14);
        final str = p.toString();
        expect(str, equals('Posit(3.1399999856948853)'));
      });

      test('toDebugString returns exact format', () {
        final p = Posit.fromNum(1.0);
        final str = p.toDebugString();
        expect(
          str,
          equals('Posit(sign: 0, k: 0, regime: 10, exponent: 0, fraction: 0, bits: 01000000000000000000000000000000)'),
        );
      });

      test('toDebugString with custom radix', () {
        final p = Posit.fromNum(1.0);
        final str = p.toDebugString(radix: 16);
        expect(str, equals('Posit(sign: 0, k: 0, regime: 2, exponent: 0, fraction: 0, bits: 40000000)'));
      });
    });

    group('compareTo', () {
      test('with equal Posits', () {
        final a = Posit.fromNum(2.0);
        final b = Posit.fromNum(2.0);
        expect(a.compareTo(b), equals(0));
      });

      test('with smaller Posit', () {
        final a = Posit.fromNum(2.0);
        final b = Posit.fromNum(3.0);
        expect(a.compareTo(b), lessThan(0));
      });

      test('with larger Posit', () {
        final a = Posit.fromNum(3.0);
        final b = Posit.fromNum(2.0);
        expect(a.compareTo(b), greaterThan(0));
      });

      test('with NaR', () {
        final a = Posit.fromNum(2.0);
        final b = Posit.naR;
        expect(a.compareTo(b), lessThan(0));
      });

      test('NaR with regular', () {
        final a = Posit.naR;
        final b = Posit.fromNum(2.0);
        expect(a.compareTo(b), greaterThan(0));
      });

      test('NaR with NaR', () {
        final a = Posit.naR;
        final b = Posit.naR;
        expect(a.compareTo(b), equals(0));
      });

      test('with zero', () {
        final a = Posit.fromNum(2.0);
        final b = Posit.zero;
        expect(a.compareTo(b), greaterThan(0));
      });

      test('zero with zero', () {
        final a = Posit.zero;
        final b = Posit.zero;
        expect(a.compareTo(b), equals(0));
      });

      test('with negative numbers', () {
        final a = Posit.fromNum(-2.0);
        final b = Posit.fromNum(-3.0);
        expect(a.compareTo(b), greaterThan(0));
      });

      test('random numbers', () {
        final random = Random(0);
        (num, num) getMinMax(num a, num b) {
          final big = max(a, b);
          final small = min(a, b);
          return (small, big);
        }

        for (int i = 0; i < 100; i++) {
          final (big, small) = getMinMax(-50 + random.nextDouble() * 100, -50 + random.nextDouble() * 100);
          final a = Posit.fromNum(big);
          final b = Posit.fromNum(small);
          expect(a.compareTo(b), lessThan(0));
        }
      });
    });

    group('HashCode', () {
      test('hashCode for equal Posits', () {
        final a = Posit.fromNum(2.0);
        final b = Posit.fromNum(2.0);
        expect(a.hashCode, equals(b.hashCode));
      });

      test('hashCode for different Posits', () {
        final a = Posit.fromNum(2.0);
        final b = Posit.fromNum(3.0);
        expect(a.hashCode, isNot(equals(b.hashCode)));
      });

      test('hashCode includes nbits and es', () {
        final a = Posit.fromNum(2.0, nbits: 16, es: 1);
        final b = Posit.fromNum(2.0, nbits: 32, es: 2);
        expect(a.hashCode, isNot(equals(b.hashCode)));
      });
    });
  });
}
