import 'dart:math' as math;

import 'package:posit/posit.dart';
import 'package:test/test.dart';

void main() {
  group('abs', () {
    test('positive number returns same value', () {
      final p = Posit.fromNum(3.14);
      final result = PositUtils.abs(p);
      expect(result.toDouble(), closeTo(3.14, 0.001));
    });

    test('negative number returns positive', () {
      final p = Posit.fromNum(-3.14);
      final result = PositUtils.abs(p);
      expect(result.toDouble(), closeTo(3.14, 0.001));
    });

    test('zero returns zero', () {
      final p = Posit.zero;
      final result = PositUtils.abs(p);
      expect(result.toDouble(), equals(0.0));
    });

    test('NaR returns NaR', () {
      final p = Posit.naR;
      final result = PositUtils.abs(p);
      expect(result.isNaR, isTrue);
    });
  });

  group('sqrt', () {
    test('positive number returns correct square root', () {
      final p = Posit.fromNum(4.0);
      final result = PositUtils.sqrt(p);
      expect(result.toDouble(), closeTo(2.0, 0.001));
    });

    test('perfect square returns exact value', () {
      final p = Posit.fromNum(9.0);
      final result = PositUtils.sqrt(p);
      expect(result.toDouble(), closeTo(3.0, 0.001));
    });

    test('zero returns zero', () {
      final p = Posit.zero;
      final result = PositUtils.sqrt(p);
      expect(result.toDouble(), equals(0.0));
    });

    test('negative number returns NaR', () {
      final p = Posit.fromNum(-4.0);
      final result = PositUtils.sqrt(p);
      expect(result.isNaR, isTrue);
    });

    test('fractional square root', () {
      final p = Posit.fromNum(2.0);
      final result = PositUtils.sqrt(p);
      expect(result.toDouble(), closeTo(math.sqrt(2.0), 0.001));
    });
  });

  group('pow', () {
    test('positive base with positive integer exponent', () {
      final base = Posit.fromNum(2.0);
      final result = PositUtils.pow(base, 3);
      expect(result.toDouble(), closeTo(8.0, 0.001));
    });

    test('positive base with negative exponent', () {
      final base = Posit.fromNum(2.0);
      final result = PositUtils.pow(base, -2);
      expect(result.toDouble(), closeTo(0.25, 0.001));
    });

    test('zero base with positive exponent returns zero', () {
      final base = Posit.zero;
      final result = PositUtils.pow(base, 3);
      expect(result.toDouble(), equals(0.0));
    });

    test('zero base with negative exponent returns NaR', () {
      final base = Posit.zero;
      final result = PositUtils.pow(base, -1);
      expect(result.isNaR, isTrue);
    });

    test('base to the power of zero returns one', () {
      final base = Posit.fromNum(5.0);
      final result = PositUtils.pow(base, 0);
      expect(result.toDouble(), closeTo(1.0, 0.001));
    });

    test('fractional exponent', () {
      final base = Posit.fromNum(4.0);
      final result = PositUtils.pow(base, 0.5);
      expect(result.toDouble(), closeTo(2.0, 0.001));
    });

    test('with Posit exponent', () {
      final base = Posit.fromNum(2.0);
      final exp = Posit.fromNum(3.0);
      final result = PositUtils.pow(base, exp);
      expect(result.toDouble(), closeTo(8.0, 0.001));
    });
  });

  group('log', () {
    test('natural log of e returns one', () {
      final p = Posit.fromNum(math.e);
      final result = PositUtils.log(p);
      expect(result.toDouble(), closeTo(1.0, 0.001));
    });

    test('natural log of one returns zero', () {
      final p = Posit.fromNum(1.0);
      final result = PositUtils.log(p);
      expect(result.toDouble(), closeTo(0.0, 0.001));
    });

    test('natural log of positive number', () {
      final p = Posit.fromNum(2.0);
      final result = PositUtils.log(p);
      expect(result.toDouble(), closeTo(math.log(2.0), 0.001));
    });

    test('zero returns NaR', () {
      final p = Posit.zero;
      final result = PositUtils.log(p);
      expect(result.isNaR, isTrue);
    });

    test('negative number returns NaR', () {
      final p = Posit.fromNum(-1.0);
      final result = PositUtils.log(p);
      expect(result.isNaR, isTrue);
    });
  });

  group('log10', () {
    test('base-10 log of 10 returns one', () {
      final p = Posit.fromNum(10.0);
      final result = PositUtils.log10(p);
      expect(result.toDouble(), closeTo(1.0, 0.001));
    });

    test('base-10 log of 100 returns two', () {
      final p = Posit.fromNum(100.0);
      final result = PositUtils.log10(p);
      expect(result.toDouble(), closeTo(2.0, 0.001));
    });

    test('base-10 log of one returns zero', () {
      final p = Posit.fromNum(1.0);
      final result = PositUtils.log10(p);
      expect(result.toDouble(), closeTo(0.0, 0.001));
    });

    test('zero returns NaR', () {
      final p = Posit.zero;
      final result = PositUtils.log10(p);
      expect(result.isNaR, isTrue);
    });

    test('negative number returns NaR', () {
      final p = Posit.fromNum(-1.0);
      final result = PositUtils.log10(p);
      expect(result.isNaR, isTrue);
    });
  });

  group('sin', () {
    test('sin of zero returns zero', () {
      final p = Posit.zero;
      final result = PositUtils.sin(p);
      expect(result.toDouble(), closeTo(0.0, 0.001));
    });

    test('sin of pi/2 returns one', () {
      final p = Posit.fromNum(math.pi / 2);
      final result = PositUtils.sin(p);
      expect(result.toDouble(), closeTo(1.0, 0.001));
    });

    test('sin of pi returns zero', () {
      final p = Posit.fromNum(math.pi);
      final result = PositUtils.sin(p);
      expect(result.toDouble(), closeTo(0.0, 0.001));
    });

    test('sin of 3*pi/2 returns negative one', () {
      final p = Posit.fromNum(3 * math.pi / 2);
      final result = PositUtils.sin(p);
      expect(result.toDouble(), closeTo(-1.0, 0.001));
    });

    test('sin of small angle', () {
      final p = Posit.fromNum(0.1);
      final result = PositUtils.sin(p);
      expect(result.toDouble(), closeTo(math.sin(0.1), 0.001));
    });
  });

  group('cos', () {
    test('cos of zero returns one', () {
      final p = Posit.zero;
      final result = PositUtils.cos(p);
      expect(result.toDouble(), closeTo(1.0, 0.001));
    });

    test('cos of pi/2 returns zero', () {
      final p = Posit.fromNum(math.pi / 2);
      final result = PositUtils.cos(p);
      expect(result.toDouble(), closeTo(0.0, 0.001));
    });

    test('cos of pi returns negative one', () {
      final p = Posit.fromNum(math.pi);
      final result = PositUtils.cos(p);
      expect(result.toDouble(), closeTo(-1.0, 0.001));
    });

    test('cos of 3*pi/2 returns zero', () {
      final p = Posit.fromNum(3 * math.pi / 2);
      final result = PositUtils.cos(p);
      expect(result.toDouble(), closeTo(0.0, 0.001));
    });

    test('cos of small angle', () {
      final p = Posit.fromNum(0.1);
      final result = PositUtils.cos(p);
      expect(result.toDouble(), closeTo(math.cos(0.1), 0.001));
    });
  });

  group('tan', () {
    test('tan of zero returns zero', () {
      final p = Posit.zero;
      final result = PositUtils.tan(p);
      expect(result.toDouble(), closeTo(0.0, 0.001));
    });

    test('tan of pi/4 returns one', () {
      final p = Posit.fromNum(math.pi / 4);
      final result = PositUtils.tan(p);
      expect(result.toDouble(), closeTo(1.0, 0.001));
    });

    test('tan of small angle', () {
      final p = Posit.fromNum(0.1);
      final result = PositUtils.tan(p);
      expect(result.toDouble(), closeTo(math.tan(0.1), 0.001));
    });
  });

  group('asin', () {
    test('asin of zero returns zero', () {
      final p = Posit.zero;
      final result = PositUtils.asin(p);
      expect(result.toDouble(), closeTo(0.0, 0.001));
    });

    test('asin of one returns pi/2', () {
      final p = Posit.fromNum(1.0);
      final result = PositUtils.asin(p);
      expect(result.toDouble(), closeTo(math.pi / 2, 0.001));
    });

    test('asin of negative one returns negative pi/2', () {
      final p = Posit.fromNum(-1.0);
      final result = PositUtils.asin(p);
      expect(result.toDouble(), closeTo(-math.pi / 2, 0.001));
    });

    test('asin of 0.5 returns pi/6', () {
      final p = Posit.fromNum(0.5);
      final result = PositUtils.asin(p);
      expect(result.toDouble(), closeTo(math.pi / 6, 0.001));
    });

    test('value greater than one returns NaR', () {
      final p = Posit.fromNum(2.0);
      final result = PositUtils.asin(p);
      expect(result.isNaR, isTrue);
    });

    test('value less than negative one returns NaR', () {
      final p = Posit.fromNum(-2.0);
      final result = PositUtils.asin(p);
      expect(result.isNaR, isTrue);
    });
  });

  group('acos', () {
    test('acos of one returns zero', () {
      final p = Posit.fromNum(1.0);
      final result = PositUtils.acos(p);
      expect(result.toDouble(), closeTo(0.0, 0.001));
    });

    test('acos of zero returns pi/2', () {
      final p = Posit.zero;
      final result = PositUtils.acos(p);
      expect(result.toDouble(), closeTo(math.pi / 2, 0.001));
    });

    test('acos of negative one returns pi', () {
      final p = Posit.fromNum(-1.0);
      final result = PositUtils.acos(p);
      expect(result.toDouble(), closeTo(math.pi, 0.001));
    });

    test('acos of 0.5 returns pi/3', () {
      final p = Posit.fromNum(0.5);
      final result = PositUtils.acos(p);
      expect(result.toDouble(), closeTo(math.pi / 3, 0.001));
    });

    test('value greater than one returns NaR', () {
      final p = Posit.fromNum(2.0);
      final result = PositUtils.acos(p);
      expect(result.isNaR, isTrue);
    });

    test('value less than negative one returns NaR', () {
      final p = Posit.fromNum(-2.0);
      final result = PositUtils.acos(p);
      expect(result.isNaR, isTrue);
    });
  });

  group('atan', () {
    test('atan of zero returns zero', () {
      final p = Posit.zero;
      final result = PositUtils.atan(p);
      expect(result.toDouble(), closeTo(0.0, 0.001));
    });

    test('atan of one returns pi/4', () {
      final p = Posit.fromNum(1.0);
      final result = PositUtils.atan(p);
      expect(result.toDouble(), closeTo(math.pi / 4, 0.001));
    });

    test('atan of negative one returns negative pi/4', () {
      final p = Posit.fromNum(-1.0);
      final result = PositUtils.atan(p);
      expect(result.toDouble(), closeTo(-math.pi / 4, 0.001));
    });

    test('atan of large positive number', () {
      final p = Posit.fromNum(1000.0);
      final result = PositUtils.atan(p);
      expect(result.toDouble(), closeTo(math.pi / 2, 0.01));
    });

    test('atan of large negative number', () {
      final p = Posit.fromNum(-1000.0);
      final result = PositUtils.atan(p);
      expect(result.toDouble(), closeTo(-math.pi / 2, 0.01));
    });
  });

  group('ceil', () {
    test('positive decimal rounds up', () {
      final p = Posit.fromNum(1.2);
      final result = PositUtils.ceil(p);
      expect(result.toDouble(), equals(2.0));
    });

    test('negative decimal rounds up', () {
      final p = Posit.fromNum(-1.2);
      final result = PositUtils.ceil(p);
      expect(result.toDouble(), equals(-1.0));
    });

    test('integer returns same value', () {
      final p = Posit.fromNum(5.0);
      final result = PositUtils.ceil(p);
      expect(result.toDouble(), equals(5.0));
    });

    test('zero returns zero', () {
      final p = Posit.zero;
      final result = PositUtils.ceil(p);
      expect(result.toDouble(), equals(0.0));
    });
  });

  group('floor', () {
    test('positive decimal rounds down', () {
      final p = Posit.fromNum(1.8);
      final result = PositUtils.floor(p);
      expect(result.toDouble(), equals(1.0));
    });

    test('negative decimal rounds down', () {
      final p = Posit.fromNum(-1.8);
      final result = PositUtils.floor(p);
      expect(result.toDouble(), equals(-2.0));
    });

    test('integer returns same value', () {
      final p = Posit.fromNum(5.0);
      final result = PositUtils.floor(p);
      expect(result.toDouble(), equals(5.0));
    });

    test('zero returns zero', () {
      final p = Posit.zero;
      final result = PositUtils.floor(p);
      expect(result.toDouble(), equals(0.0));
    });
  });

  group('round', () {
    test('positive decimal rounds to nearest', () {
      final p = Posit.fromNum(1.5);
      final result = PositUtils.round(p);
      expect(result.toDouble(), equals(2.0));
    });

    test('negative decimal rounds to nearest', () {
      final p = Posit.fromNum(-1.5);
      final result = PositUtils.round(p);
      expect(result.toDouble(), equals(-2.0));
    });

    test('positive decimal less than 0.5 rounds down', () {
      final p = Posit.fromNum(1.4);
      final result = PositUtils.round(p);
      expect(result.toDouble(), equals(1.0));
    });

    test('negative decimal greater than -0.5 rounds up', () {
      final p = Posit.fromNum(-1.4);
      final result = PositUtils.round(p);
      expect(result.toDouble(), equals(-1.0));
    });

    test('integer returns same value', () {
      final p = Posit.fromNum(5.0);
      final result = PositUtils.round(p);
      expect(result.toDouble(), equals(5.0));
    });

    test('zero returns zero', () {
      final p = Posit.zero;
      final result = PositUtils.round(p);
      expect(result.toDouble(), equals(0.0));
    });
  });

  group('min', () {
    test('first number is smaller', () {
      final a = Posit.fromNum(2.0);
      final b = Posit.fromNum(5.0);
      final result = PositUtils.min(a, b);
      expect(result, equals(a));
    });

    test('second number is smaller', () {
      final a = Posit.fromNum(5.0);
      final b = Posit.fromNum(2.0);
      final result = PositUtils.min(a, b);
      expect(result, equals(b));
    });

    test('equal numbers returns first', () {
      final a = Posit.fromNum(3.0);
      final b = Posit.fromNum(3.0);
      final result = PositUtils.min(a, b);
      expect(result, equals(a));
    });

    test('negative and positive numbers', () {
      final a = Posit.fromNum(-2.0);
      final b = Posit.fromNum(3.0);
      final result = PositUtils.min(a, b);
      expect(result, equals(a));
    });
  });

  group('max', () {
    test('first number is larger', () {
      final a = Posit.fromNum(5.0);
      final b = Posit.fromNum(2.0);
      final result = PositUtils.max(a, b);
      expect(result, equals(a));
    });

    test('second number is larger', () {
      final a = Posit.fromNum(2.0);
      final b = Posit.fromNum(5.0);
      final result = PositUtils.max(a, b);
      expect(result, equals(b));
    });

    test('equal numbers returns first', () {
      final a = Posit.fromNum(3.0);
      final b = Posit.fromNum(3.0);
      final result = PositUtils.max(a, b);
      expect(result, equals(a));
    });

    test('negative and positive numbers', () {
      final a = Posit.fromNum(-2.0);
      final b = Posit.fromNum(3.0);
      final result = PositUtils.max(a, b);
      expect(result, equals(b));
    });
  });

  group('clamp', () {
    test('value within range returns same value', () {
      final value = Posit.fromNum(3.0);
      final min = Posit.fromNum(1.0);
      final max = Posit.fromNum(5.0);
      final result = PositUtils.clamp(value, min, max);
      expect(result, equals(value));
    });

    test('value below minimum returns minimum', () {
      final value = Posit.fromNum(0.5);
      final min = Posit.fromNum(1.0);
      final max = Posit.fromNum(5.0);
      final result = PositUtils.clamp(value, min, max);
      expect(result, equals(min));
    });

    test('value above maximum returns maximum', () {
      final value = Posit.fromNum(6.0);
      final min = Posit.fromNum(1.0);
      final max = Posit.fromNum(5.0);
      final result = PositUtils.clamp(value, min, max);
      expect(result, equals(max));
    });

    test('value equals minimum returns minimum', () {
      final value = Posit.fromNum(1.0);
      final min = Posit.fromNum(1.0);
      final max = Posit.fromNum(5.0);
      final result = PositUtils.clamp(value, min, max);
      expect(result, equals(min));
    });

    test('value equals maximum returns maximum', () {
      final value = Posit.fromNum(5.0);
      final min = Posit.fromNum(1.0);
      final max = Posit.fromNum(5.0);
      final result = PositUtils.clamp(value, min, max);
      expect(result, equals(max));
    });

    test('negative values', () {
      final value = Posit.fromNum(-3.0);
      final min = Posit.fromNum(-2.0);
      final max = Posit.fromNum(2.0);
      final result = PositUtils.clamp(value, min, max);
      expect(result, equals(min));
    });
  });
}
