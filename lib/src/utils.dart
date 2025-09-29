import 'dart:math' as math;

import 'encoding.dart';
import 'posit_base.dart';

/// Utility functions for Posit numbers.
///
/// This module provides helper functions for common operations
/// and conversions with Posit numbers.
class PositUtils {
  /// Calculates the absolute value of a Posit.
  ///
  /// [a] - the Posit number
  static Posit abs(Posit a) {
    if (a.isNegative) {
      // Convert from two's complement to get positive representation
      final positiveBits = PositEncoding.negateIfNegative(a.bits, a.nbits);
      return Posit.fromBits(positiveBits, nbits: a.nbits, es: a.es);
    }
    return a;
  }

  /// Calculates the square root of a Posit.
  ///
  /// [a] - the Posit number
  static Posit sqrt(Posit a) {
    if (a.isNegative) {
      return Posit.naRWithConfig(nbits: a.nbits, es: a.es);
    }
    return Posit.fromNum(math.sqrt(a.toDouble()), nbits: a.nbits, es: a.es);
  }

  /// Calculates the power of a Posit.
  ///
  /// [base] - the base Posit
  /// [exponent] - the exponent (can be num or Posit)
  static Posit pow(Posit base, Object exponent) {
    final baseValue = base.toDouble();
    final expValue = exponent is Posit ? exponent.toDouble() : (exponent as num).toDouble();

    if (baseValue == 0 && expValue < 0) {
      return Posit.naRWithConfig(nbits: base.nbits, es: base.es);
    }

    return Posit.fromNum(math.pow(baseValue, expValue).toDouble(), nbits: base.nbits, es: base.es);
  }

  /// Calculates the natural logarithm of a Posit.
  ///
  /// [a] - the Posit number
  static Posit log(Posit a) {
    if (a.isZero || a.isNegative) {
      return Posit.naRWithConfig(nbits: a.nbits, es: a.es);
    }
    return Posit.fromNum(math.log(a.toDouble()), nbits: a.nbits, es: a.es);
  }

  /// Calculates the base-10 logarithm of a Posit.
  ///
  /// [a] - the Posit number
  static Posit log10(Posit a) {
    if (a.isZero || a.isNegative) {
      return Posit.naRWithConfig(nbits: a.nbits, es: a.es);
    }
    return Posit.fromNum(math.log(a.toDouble()) / math.ln10, nbits: a.nbits, es: a.es);
  }

  /// Calculates the sine of a Posit.
  ///
  /// [a] - the Posit number (in radians)
  static Posit sin(Posit a) {
    return Posit.fromNum(math.sin(a.toDouble()), nbits: a.nbits, es: a.es);
  }

  /// Calculates the cosine of a Posit.
  ///
  /// [a] - the Posit number (in radians)
  static Posit cos(Posit a) {
    return Posit.fromNum(math.cos(a.toDouble()), nbits: a.nbits, es: a.es);
  }

  /// Calculates the tangent of a Posit.
  ///
  /// [a] - the Posit number (in radians)
  static Posit tan(Posit a) {
    return Posit.fromNum(math.tan(a.toDouble()), nbits: a.nbits, es: a.es);
  }

  /// Calculates the arcsine of a Posit.
  ///
  /// [a] - the Posit number
  static Posit asin(Posit a) {
    final value = a.toDouble();
    if (value < -1 || value > 1) {
      return Posit.naRWithConfig(nbits: a.nbits, es: a.es);
    }
    return Posit.fromNum(math.asin(value), nbits: a.nbits, es: a.es);
  }

  /// Calculates the arccosine of a Posit.
  ///
  /// [a] - the Posit number
  static Posit acos(Posit a) {
    final value = a.toDouble();
    if (value < -1 || value > 1) {
      return Posit.naRWithConfig(nbits: a.nbits, es: a.es);
    }
    return Posit.fromNum(math.acos(value), nbits: a.nbits, es: a.es);
  }

  /// Calculates the arctangent of a Posit.
  ///
  /// [a] - the Posit number
  static Posit atan(Posit a) {
    return Posit.fromNum(math.atan(a.toDouble()), nbits: a.nbits, es: a.es);
  }

  /// Calculates the ceiling of a Posit.
  ///
  /// [a] - the Posit number
  static Posit ceil(Posit a) {
    return Posit.fromNum(a.toDouble().ceil().toDouble(), nbits: a.nbits, es: a.es);
  }

  /// Calculates the floor of a Posit.
  ///
  /// [a] - the Posit number
  static Posit floor(Posit a) {
    return Posit.fromNum(a.toDouble().floor().toDouble(), nbits: a.nbits, es: a.es);
  }

  /// Calculates the round of a Posit.
  ///
  /// [a] - the Posit number
  static Posit round(Posit a) {
    return Posit.fromNum(a.toDouble().round().toDouble(), nbits: a.nbits, es: a.es);
  }

  /// Returns the minimum of two Posit numbers.
  ///
  /// [a] - first Posit
  /// [b] - second Posit
  static Posit min(Posit a, Posit b) {
    return a.compareTo(b) <= 0 ? a : b;
  }

  /// Returns the maximum of two Posit numbers.
  ///
  /// [a] - first Posit
  /// [b] - second Posit
  static Posit max(Posit a, Posit b) {
    return a.compareTo(b) >= 0 ? a : b;
  }

  /// Clamps a Posit value between min and max.
  ///
  /// [value] - the value to clamp
  /// [min] - minimum value
  /// [max] - maximum value
  static Posit clamp(Posit value, Posit min, Posit max) {
    if (value.compareTo(min) < 0) return min;
    if (value.compareTo(max) > 0) return max;
    return value;
  }
}
