import 'dart:math' as math;

import '../posit.dart';

/// Encoding and decoding utilities for Posit numbers.
///
/// This module handles the bit-level operations for converting between
/// Posit representations and standard numeric types.
class PositEncoding {
  /// Converts a Posit representation to a double.
  ///
  /// [a] - the Posit number
  /// [nbits] - total number of bits
  /// [es] - number of exponent bits
  static double decodeToDouble(Posit a, int nbits, int es) {
    if (a.isNaR) {
      return double.nan;
    }

    if (a.isZero) {
      return 0.0;
    }

    final sign = extractSignBit(a.bits, nbits);

    if (sign) {
      // undo two's complement
      a = PositArithmetic.negate(a);
    }

    // Extract components
    int e = extractExponentBits(a.bits, nbits, es);
    int k = extractKValue(a.bits, nbits);

    // Calculate fraction value
    double f = calculateFractionValue(a.bits, nbits, es);

    int useed = calculateUseed(es);

    double value = math.pow(-1, sign ? 1 : 0) * math.pow(useed, k) * math.pow(2, e) * f;
    return value;
  }

  /// Extracts the sign bit.
  static bool extractSignBit(int bits, int nbits) {
    return (bits & (1 << (nbits - 1))) != 0;
  }

  /// Extracts the length of the regime field.
  static int extractRegimeBitLength(int bits, int nbits) {
    bits = negateIfNegative(bits, nbits);
    int signMask = (1 << (nbits - 1)) - 1; // 0b0111... to remove sign bit
    int remainingBits = bits & signMask; // 0x1010 & 0x0111... = 0x0010
    int firstBit = (remainingBits >> (nbits - 2)) & 1; // shift to get the first bit of regime

    // XOR with firstBit so that trailing zeros mark end of regime
    int xor = remainingBits ^ ((firstBit == 1) ? signMask : 0);

    if (xor == 0) {
      // All remaining bits are the same (no exponent or fraction bits)
      return nbits - 1; // all regime except sign
    }

    // Count leading zeros of xor (position of first different bit)
    int leadingZeros = (nbits - 1) - xor.bitLength;

    return leadingZeros + 1;
  }

  /// Extracts the regime field.
  /// This is a run of identical bits which may be terminated by a different bit if one exists
  static int extractRegimeBits(int bits, int nbits) {
    bits = negateIfNegative(bits, nbits);
    final int regimeLength = extractRegimeBitLength(bits, nbits);
    // Shift down so the regime is at the bottom
    int shifted = bits >> (nbits - 1 - regimeLength);
    // Mask off only the regimeLength bits
    return shifted & ((1 << regimeLength) - 1);
  }

  /// Extracts the exponent field.
  static int extractExponentBits(int bits, int nbits, int es) {
    bits = negateIfNegative(bits, nbits);
    // Skip sign bit and regime bits
    int regimeBitLength = extractRegimeBitLength(bits, nbits);
    int exponentStart = nbits - 1 - regimeBitLength - es;

    if (exponentStart < 0) return 0;

    return (bits >> exponentStart) & ((1 << es) - 1);
  }

  /// Extracts the fraction field.
  static int extractFractionBits(int bits, int nbits, int es) {
    bits = negateIfNegative(bits, nbits);
    // Skip sign bit, regime bits, and exponent bits
    int regimeBitLength = extractRegimeBitLength(bits, nbits);
    int fractionBits = nbits - 1 - regimeBitLength - es;

    if (fractionBits <= 0) return 0;

    return bits & ((1 << fractionBits) - 1);
  }

  /// Extracts the k value.
  /// The k is the length of the regime bit run (consecutive identical bits) until the first bit flip
  static int extractKValue(int bits, int nbits) {
    bits = negateIfNegative(bits, nbits);
    int regimeBitLength = extractRegimeBitLength(bits, nbits);
    int regimeBits = extractRegimeBits(bits, nbits);
    // Check the first regime bit (MSB of regime)
    int firstBit = (regimeBits >> (regimeBitLength - 1)) & 1;

    // if regime bit run is terminated, subtract 1 as k is based on run length excluding the terminating opposite bit
    if (regimeBits != (1 << regimeBitLength) - 1 && regimeBits != 0) {
      regimeBitLength -= 1;
    }

    if (firstBit == 1) {
      return regimeBitLength - 1;
    } else {
      return -regimeBitLength;
    }
  }

  /// Extracts the useed value (2^(2^es)).
  static int calculateUseed(int es) {
    return 1 << (1 << es);
  }

  /// Calculates the actual fraction value.
  static double calculateFractionValue(int bits, int nbits, int es) {
    final fraction = extractFractionBits(bits, nbits, es);
    int regimeBits = extractRegimeBitLength(bits, nbits);
    int fractionLength = nbits - 1 - regimeBits - es;

    if (fraction <= 0) return 1;
    return 1 + (fraction / (1 << fractionLength));
  }

  /// Handle two's complement negation
  static int negate(int bits, int nbits) {
    final bitMask = (1 << nbits) - 1;
    final twosComplement = (~bits + 1) & bitMask;
    return twosComplement;
  }

  static int negateIfNegative(int bits, int nbits) {
    final sign = extractSignBit(bits, nbits);
    if (sign) {
      return negate(bits, nbits);
    }
    return bits;
  }

  /// Converts a double to a Posit representation.
  ///
  /// [value] - the double value to convert
  /// [nbits] - total number of bits (default 32)
  /// [es] - number of exponent bits (default 2)
  static int encodeFromDouble(double value, int nbits, int es) {
    if (!value.isFinite) {
      return _encodeNaR(nbits);
    }
    if (value == 0) {
      return _encodeZero(nbits);
    }
    // TODO: Implement encodeFromDouble to convert a double to a Posit representation
    return 0;
  }

  /// Encodes NaR representation.
  /// If the sign bit is 1 and all other bits are 0, the posit value is NaR ("not a real")
  static int _encodeNaR(int nbits) {
    return 1 << (nbits - 1);
  }

  /// Encodes zero representation.
  /// Zero is unsigned, and represented as all 0s
  static int _encodeZero(int nbits) {
    return 0;
  }
}
