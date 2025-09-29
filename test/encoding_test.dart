import 'package:posit/posit.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  const epsilon = 1e-9;
  group('Posit Encoding Tests', () {
    group('decodeToDouble', () {
      test('should decode zero to 0.0', () {
        final posit = Posit.zero;
        final result = PositEncoding.decodeToDouble(posit, 32, 2);
        expect(result, equals(0.0));
      });

      test('should decode NaR to NaN', () {
        final posit = Posit.naR;
        final result = PositEncoding.decodeToDouble(posit, 32, 2);
        expect(result.isNaN, isTrue);
      });

      test('should decode positive numbers correctly', () {
        final testCases = [
          (value: 1.0, nbits: 8, es: 2),
          (value: 2.0, nbits: 8, es: 2),
          (value: 0.5, nbits: 8, es: 2),
          (value: 4.0, nbits: 8, es: 2),
          (value: 0.25, nbits: 8, es: 2),
          (value: 1.5, nbits: 8, es: 2),
          (value: 3.0, nbits: 8, es: 2),
          (value: 0.125, nbits: 8, es: 2),
          (value: 8.0, nbits: 8, es: 2),
        ];

        for (final testCase in testCases) {
          final posit = Posit.fromNum(testCase.value, nbits: testCase.nbits, es: testCase.es);
          final result = PositEncoding.decodeToDouble(posit, testCase.nbits, testCase.es);
          expect(result, closeTo(testCase.value, epsilon));
        }
      });

      test('should decode negative numbers correctly', () {
        final testCases = [
          (value: -1.0, nbits: 8, es: 2),
          (value: -2.0, nbits: 8, es: 2),
          (value: -0.5, nbits: 8, es: 2),
          (value: -4.0, nbits: 8, es: 2),
          (value: -0.25, nbits: 8, es: 2),
          (value: -1.5, nbits: 8, es: 2),
          (value: -3.0, nbits: 8, es: 2),
          (value: -0.125, nbits: 8, es: 2),
          (value: -8.0, nbits: 8, es: 2),
        ];

        for (final testCase in testCases) {
          final posit = Posit.fromNum(testCase.value, nbits: testCase.nbits, es: testCase.es);
          final result = PositEncoding.decodeToDouble(posit, testCase.nbits, testCase.es);
          expect(result, closeTo(testCase.value, epsilon));
        }
      });

      test('should work with different bit widths and es values', () {
        final testCases = [
          (value: 1.0, nbits: 4, es: 0),
          (value: 1.0, nbits: 4, es: 1),
          (value: 1.0, nbits: 4, es: 2),
          (value: 1.0, nbits: 6, es: 2),
          (value: 1.0, nbits: 8, es: 2),
          (value: 1.0, nbits: 8, es: 4),
          (value: 1.0, nbits: 16, es: 2),
          (value: 1.0, nbits: 32, es: 2),
        ];

        for (final testCase in testCases) {
          final posit = Posit.fromNum(testCase.value, nbits: testCase.nbits, es: testCase.es);
          final result = PositEncoding.decodeToDouble(posit, testCase.nbits, testCase.es);
          expect(result, closeTo(testCase.value, epsilon));
        }
      });
    });

    group('extractSignBit', () {
      test('should extract sign bit correctly', () {
        // Test with 8-bit numbers
        expect(PositEncoding.extractSignBit(00000000.b, 8), isFalse); // 0
        expect(PositEncoding.extractSignBit(10000000.b, 8), isTrue); // -0 (NaR)
        expect(PositEncoding.extractSignBit(01000000.b, 8), isFalse); // positive
        expect(PositEncoding.extractSignBit(11000000.b, 8), isTrue); // negative
      });

      test('should work with different bit widths', () {
        expect(PositEncoding.extractSignBit(0000.b, 4), isFalse);
        expect(PositEncoding.extractSignBit(1000.b, 4), isTrue);
        expect(PositEncoding.extractSignBit(0000000000000000.b, 16), isFalse);
        expect(PositEncoding.extractSignBit(1000000000000000.b, 16), isTrue);
      });
    });

    group('extractRegimeBitLength', () {
      test('should extract regime bit length correctly', () {
        // Test cases based on known posit patterns
        expect(PositEncoding.extractRegimeBitLength(00000000.b, 8), equals(7)); // all zeros
        expect(PositEncoding.extractRegimeBitLength(01000000.b, 8), equals(2)); // single 1
        expect(PositEncoding.extractRegimeBitLength(01100000.b, 8), equals(3)); // two 1s + terminating 0
        expect(PositEncoding.extractRegimeBitLength(01110000.b, 8), equals(4)); // three 1s + terminating 0
      });
    });

    group('extractRegimeBits', () {
      test('should extract regime bits correctly', () {
        // Test with known patterns
        expect(PositEncoding.extractRegimeBits(01000000.b, 8), equals(10.b));
        expect(PositEncoding.extractRegimeBits(01100000.b, 8), equals(110.b));
        expect(PositEncoding.extractRegimeBits(01110000.b, 8), equals(1110.b));
      });
    });

    group('extractExponentBits', () {
      test('should extract exponent bits correctly', () {
        // Test with different es values
        expect(PositEncoding.extractExponentBits(01000000.b, 8, 2), equals(0));
        expect(PositEncoding.extractExponentBits(01010000.b, 8, 2), equals(10.b));
        expect(PositEncoding.extractExponentBits(01011000.b, 8, 2), equals(11.b));
      });
    });

    group('extractFractionBits', () {
      test('should extract fraction bits correctly', () {
        // Test with different configurations
        expect(PositEncoding.extractFractionBits(01000000.b, 8, 2), equals(0));
        expect(PositEncoding.extractFractionBits(01000001.b, 8, 2), equals(1.b));
        expect(PositEncoding.extractFractionBits(01000010.b, 8, 2), equals(10.b));
      });
    });

    group('extractKValue', () {
      test('should extract k value correctly', () {
        // Test with known patterns
        expect(PositEncoding.extractKValue(01000000.b, 8), equals(0)); // single 1
        expect(PositEncoding.extractKValue(01100000.b, 8), equals(1)); // two 1s + terminating 0
        expect(PositEncoding.extractKValue(01110000.b, 8), equals(2)); // three 1s + terminating 0
        expect(PositEncoding.extractKValue(00000000.b, 8), equals(-7)); // all zeros
      });
    });

    group('calculateUseed', () {
      test('should calculate useed correctly', () {
        expect(PositEncoding.calculateUseed(0), equals(2)); // 2^(2^0) = 2^1 = 2
        expect(PositEncoding.calculateUseed(1), equals(4)); // 2^(2^1) = 2^2 = 4
        expect(PositEncoding.calculateUseed(2), equals(16)); // 2^(2^2) = 2^4 = 16
        expect(PositEncoding.calculateUseed(3), equals(256)); // 2^(2^3) = 2^8 = 256
      });
    });

    group('calculateFractionValue', () {
      test('should calculate fraction value correctly', () {
        // Test with no fraction bits
        expect(PositEncoding.calculateFractionValue(01000000.b, 8, 2), equals(1.0));

        // Test with fraction bits
        final result = PositEncoding.calculateFractionValue(01000001.b, 8, 2);
        expect(result, closeTo(1.125, epsilon)); // 1 + 1/8
      });
    });

    group('negate', () {
      test('should negate bits correctly', () {
        expect(PositEncoding.negate(00000000.b, 8), equals(00000000.b)); // 0 -> 0
        expect(PositEncoding.negate(00000001.b, 8), equals(11111111.b)); // 1 -> -1
        expect(PositEncoding.negate(00000010.b, 8), equals(11111110.b)); // 2 -> -2
        expect(PositEncoding.negate(10000000.b, 8), equals(10000000.b)); // -0 -> 0
      });
    });

    group('negateIfNegative', () {
      test('should negate only if negative', () {
        expect(PositEncoding.negateIfNegative(00000000.b, 8), equals(00000000.b)); // positive
        expect(PositEncoding.negateIfNegative(10000000.b, 8), equals(10000000.b)); // negative -> stays negative (NaR)
        expect(PositEncoding.negateIfNegative(01000000.b, 8), equals(01000000.b)); // positive
      });
    });

    group('encodeFromDouble', () {
      test('should encode zero correctly', () {
        final result = PositEncoding.encodeFromDouble(0.0, 8, 2);
        expect(result, equals(0));
      });

      test('should encode NaN as NaR', () {
        final result = PositEncoding.encodeFromDouble(double.nan, 8, 2);
        expect(result, equals(10000000.b)); // NaR pattern
      });

      test('should encode infinity as NaR', () {
        final result = PositEncoding.encodeFromDouble(double.infinity, 8, 2);
        expect(result, equals(10000000.b)); // NaR pattern
      });

      test('should encode negative infinity as NaR', () {
        final result = PositEncoding.encodeFromDouble(double.negativeInfinity, 8, 2);
        expect(result, equals(10000000.b)); // NaR pattern
      });

      test('should implement round-trip encoding/decoding', () {
        final testValues = [
          1.0,
          2.0,
          0.5,
          4.0,
          0.25,
          8.0,
          0.125,
          16.0,
          -1.0,
          -2.0,
          -0.5,
          -4.0,
          -0.25,
          -8.0,
          -0.125,
          -16.0,
        ];

        for (final value in testValues) {
          final encoded = PositEncoding.encodeFromDouble(value, 8, 2);
          final posit = Posit.fromBits(encoded, nbits: 8, es: 2);
          final decoded = PositEncoding.decodeToDouble(posit, 8, 2);

          if (value.isFinite) {
            expect(decoded, closeTo(value, 1e-10), reason: 'Round-trip failed for $value');
          }
        }
      });
    });

    group('_encodeNaR', () {
      test('should encode NaR correctly', () {
        expect(PositEncoding.encodeFromDouble(double.nan, 4, 0), equals(1000.b));
        expect(PositEncoding.encodeFromDouble(double.nan, 8, 2), equals(10000000.b));
        expect(PositEncoding.encodeFromDouble(double.nan, 16, 3), equals(1000000000000000.b));
      });
    });

    group('_encodeZero', () {
      test('should encode zero correctly', () {
        expect(PositEncoding.encodeFromDouble(0.0, 4, 0), equals(0000.b));
        expect(PositEncoding.encodeFromDouble(0.0, 8, 2), equals(00000000.b));
        expect(PositEncoding.encodeFromDouble(0.0, 16, 3), equals(0000000000000000.b));
      });
    });
  });
}
