import 'encoding.dart';
import 'posit_base.dart';

/// Helper class for Posit arithmetic operations using only integers
class _PositComponents {
  final int sign; // 1 for negative, 0 for positive
  final int scale; // k * 2^es + e
  final int fraction; // integer fraction with hidden leading 1
  final int nbits;
  final int es;

  _PositComponents(this.sign, this.scale, this.fraction, this.nbits, this.es);

  static _PositComponents fromPosit(Posit posit) {
    final signBit = PositEncoding.extractSignBit(posit.bits, posit.nbits);
    final bitsPositive = PositEncoding.negateIfNegative(posit.bits, posit.nbits);
    final k = PositEncoding.extractKValue(bitsPositive, posit.nbits);
    final e = PositEncoding.extractExponentBits(bitsPositive, posit.nbits, posit.es);
    final fractionBits = PositEncoding.extractFractionBits(bitsPositive, posit.nbits, posit.es);

    // Calculate scale = k * 2^es + e
    final scale = k * (1 << posit.es) + e;

    // Use the raw fraction bits directly without normalization
    final fractionLength = posit.nbits - 1 - PositEncoding.extractRegimeBitLength(bitsPositive, posit.nbits) - posit.es;

    // Store the raw fraction bits with the hidden bit
    final finalFraction = fractionLength > 0 ? (1 << fractionLength) | fractionBits : (1 << fractionLength);

    return _PositComponents(signBit ? 1 : 0, scale, finalFraction, posit.nbits, posit.es);
  }

  /// Converts components back to a Posit using the existing encoding system
  /// TODO: Replace with pure bitwise operations
  Posit toPosit() {
    // Recompute k and e from scale
    final k = scale ~/ (1 << es);
    final e = scale % (1 << es);

    // Handle special cases
    if (k < -(nbits - 1)) {
      return sign == 1 ? Posit.naRWithConfig(nbits: nbits, es: es) : Posit.zeroWithConfig(nbits: nbits, es: es);
    }

    if (k > nbits - 2) {
      // Overflow - saturate to maxpos/minpos
      final maxPos = (1 << (nbits - 1)) - 1;
      return sign == 1 ? Posit.fromBits(maxPos, nbits: nbits, es: es) : Posit.fromBits(maxPos, nbits: nbits, es: es);
    }

    // Encode the result using pure bitwise operations
    int result = 0;
    int shift = nbits - 1;

    // Sign bit
    if (sign == 1) {
      result |= (1 << shift);
    }
    shift--;

    // Regime bits
    if (k >= 0) {
      // Positive regime: k+1 ones followed by a zero
      for (int i = 0; i < k + 1 && shift >= 0; i++) {
        result |= (1 << shift);
        shift--;
      }
      if (shift >= 0) {
        // terminating zero
        shift--;
      }
    } else {
      // Negative regime: leading zeros with terminating one
      for (int i = 0; i < -k && shift >= 0; i++) {
        shift--;
      }
      if (shift >= 0) {
        result |= (1 << shift);
        shift--;
      }
    }

    // Exponent bits
    for (int i = es - 1; i >= 0 && shift >= 0; i--) {
      if ((e & (1 << i)) != 0) {
        result |= (1 << shift);
      }
      shift--;
    }

    // Fraction bits
    final fractionLength = shift + 1;
    if (fractionLength > 0) {
      // Extract the fraction bits (without the hidden bit)
      final fractionBits = fraction & ((1 << fractionLength) - 1);
      result |= fractionBits;
    }

    return Posit.fromBits(result, nbits: nbits, es: es);
  }
}

/// Arithmetic operations for Posit numbers.
///
/// This module implements the core arithmetic operations including
/// addition, subtraction, multiplication, and division.
class PositArithmetic {
  /// Adds two Posit numbers using pure bitwise operations.
  ///
  /// [a] - first operand
  /// [b] - second operand
  static Posit add(Posit a, Posit b) {
    // Handle special cases
    if (a.isNaR || b.isNaR) {
      return Posit.naRWithConfig(nbits: a.nbits, es: a.es);
    }

    if (a.isZero) return b;
    if (b.isZero) return a;

    // Parse each posit operand
    final aComp = _PositComponents.fromPosit(a);
    final bComp = _PositComponents.fromPosit(b);

    // If signs are different, this becomes subtraction
    if (aComp.sign != bComp.sign) {
      if (aComp.sign == 1) {
        // a is negative, b is positive: a + b = b - |a|
        final absA = PositArithmetic.negate(a);
        return subtract(b, absA);
      } else {
        // a is positive, b is negative: a + b = a - |b|
        final absB = PositArithmetic.negate(b);
        return subtract(a, absB);
      }
    }

    // Both have same sign - perform addition
    // Align operands by comparing scales
    final scaleDiff = (aComp.scale - bComp.scale).abs();
    final (larger, smaller) = aComp.scale >= bComp.scale ? (aComp, bComp) : (bComp, aComp);

    // Shift fraction of smaller operand right by the scale difference
    final alignedSmallerFraction = smaller.fraction >> scaleDiff;

    // Add aligned fractions
    final resultFraction = larger.fraction + alignedSmallerFraction;

    // Normalize result
    var finalScale = larger.scale;
    var finalFraction = resultFraction;

    // If fraction overflowed, shift right and increment scale
    // The fraction should be in the range [1 << fractionLength, 2 << fractionLength)
    final fractionLength = a.nbits - 1 - PositEncoding.extractRegimeBitLength(a.bits, a.nbits) - a.es;
    final maxFraction = 2 << fractionLength;
    if (finalFraction >= maxFraction) {
      finalFraction = finalFraction >> 1;
      finalScale++;
    }

    // Create result components
    return _PositComponents(aComp.sign, finalScale, finalFraction, a.nbits, a.es).toPosit();
  }

  /// Subtracts two Posit numbers using pure bitwise operations.
  ///
  /// [a] - first operand
  /// [b] - second operand
  static Posit subtract(Posit a, Posit b) {
    // Handle special cases
    if (a.isNaR || b.isNaR) {
      return Posit.naRWithConfig(nbits: a.nbits, es: a.es);
    }

    if (b.isZero) return a;
    if (a.isZero) return PositArithmetic.negate(b);

    // Parse each posit operand
    final aComp = _PositComponents.fromPosit(a);
    final bComp = _PositComponents.fromPosit(b);

    // If signs are different, this becomes addition
    if (aComp.sign != bComp.sign) {
      if (aComp.sign == 1) {
        // a is negative, b is positive: a - b = -(|a| + b)
        final absA = PositArithmetic.negate(a);
        final result = add(absA, b);
        return PositArithmetic.negate(result);
      } else {
        // a is positive, b is negative: a - b = a + |b|
        final absB = PositArithmetic.negate(b);
        return add(a, absB);
      }
    }

    // Both have same sign - perform subtraction
    // Compare magnitudes to determine which is larger
    final (
      larger,
      smaller,
      resultSign,
    ) = aComp.scale > bComp.scale || (aComp.scale == bComp.scale && aComp.fraction > bComp.fraction)
        ? (aComp, bComp, aComp.sign)
        : (bComp, aComp, 1 - bComp.sign);

    final scaleDiff = (larger.scale - smaller.scale).abs();

    // Align the smaller number by shifting its fraction
    final alignedSmallerFraction = smaller.fraction >> scaleDiff;

    // Subtract the aligned fractions
    final resultFraction = larger.fraction - alignedSmallerFraction;

    // Normalize result
    var finalScale = larger.scale;
    var finalFraction = resultFraction;

    // If fraction underflowed, shift left and decrement scale
    final fractionLength = a.nbits - 1 - PositEncoding.extractRegimeBitLength(a.bits, a.nbits) - a.es;
    final minFraction = 1 << fractionLength;
    final minScale = -(a.nbits - 1) * (1 << a.es);
    while (finalFraction < minFraction && finalScale > minScale) {
      finalFraction = finalFraction << 1;
      finalScale--;
    }

    // Create result components
    return _PositComponents(resultSign, finalScale, finalFraction, a.nbits, a.es).toPosit();
  }

  /// Multiplies two Posit numbers using pure bitwise operations.
  ///
  /// [a] - first operand
  /// [b] - second operand
  static Posit multiply(Posit a, Posit b) {
    // Handle special cases
    if (a.isNaR || b.isNaR) {
      return Posit.naRWithConfig(nbits: a.nbits, es: a.es);
    }

    if (a.isZero || b.isZero) {
      return Posit.zeroWithConfig(nbits: a.nbits, es: a.es);
    }

    // Extract components
    final aComp = _PositComponents.fromPosit(a);
    final bComp = _PositComponents.fromPosit(b);

    // XOR signs for result sign
    final resultSign = aComp.sign ^ bComp.sign;

    // Add scales
    final resultScale = aComp.scale + bComp.scale;

    // Multiply fractions
    final fractionLength = a.nbits - 1 - PositEncoding.extractRegimeBitLength(a.bits, a.nbits) - a.es;
    final resultFraction = (aComp.fraction * bComp.fraction) >> fractionLength;

    // Normalize result
    var finalScale = resultScale;
    var finalFraction = resultFraction;

    // If fraction overflowed, shift right and increment scale
    final maxFraction = 2 << fractionLength;
    if (finalFraction >= maxFraction) {
      finalFraction = finalFraction >> 1;
      finalScale++;
    }

    // Create result components
    return _PositComponents(resultSign, finalScale, finalFraction, a.nbits, a.es).toPosit();
  }

  /// Divides two Posit numbers using pure bitwise operations.
  ///
  /// [a] - dividend
  /// [b] - divisor
  static Posit divide(Posit a, Posit b) {
    // Handle special cases
    if (a.isNaR || b.isNaR) {
      return Posit.naRWithConfig(nbits: a.nbits, es: a.es);
    }

    if (a.isZero && b.isZero) {
      return Posit.naRWithConfig(nbits: a.nbits, es: a.es);
    }

    if (a.isZero) {
      return Posit.zeroWithConfig(nbits: a.nbits, es: a.es);
    }

    if (b.isZero) {
      return Posit.naRWithConfig(nbits: a.nbits, es: a.es);
    }

    // Extract components
    final aComp = _PositComponents.fromPosit(a);
    final bComp = _PositComponents.fromPosit(b);

    // XOR signs for result sign
    final resultSign = aComp.sign ^ bComp.sign;

    // Subtract scales
    final resultScale = aComp.scale - bComp.scale;

    // Divide fractions
    final fractionLength = a.nbits - 1 - PositEncoding.extractRegimeBitLength(a.bits, a.nbits) - a.es;
    final resultFraction = (aComp.fraction << fractionLength) ~/ bComp.fraction;

    // Normalize result
    var finalScale = resultScale;
    var finalFraction = resultFraction;

    // If fraction underflowed, shift left and decrement scale
    final minFraction = 1 << fractionLength;
    final minScale = -(a.nbits - 1) * (1 << a.es);
    while (finalFraction < minFraction && finalScale > minScale) {
      finalFraction = finalFraction << 1;
      finalScale--;
    }

    // Create result components
    return _PositComponents(resultSign, finalScale, finalFraction, a.nbits, a.es).toPosit();
  }

  /// Negates a Posit number using 2's complement.
  ///
  /// [a] - the number to negate
  static Posit negate(Posit a) {
    if (a.isNaR) {
      return Posit.naRWithConfig(nbits: a.nbits, es: a.es);
    }

    if (a.isZero) {
      return a; // Zero is its own negation
    }

    // Use 2's complement for negation
    final twosComplement = PositEncoding.negate(a.bits, a.nbits);
    return Posit.fromBits(twosComplement, nbits: a.nbits, es: a.es);
  }
}
