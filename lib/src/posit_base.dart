import 'arithmetic.dart';
import 'encoding.dart';
import 'utils.dart';

/// A Posit (unum) number implementation.
class Posit implements Comparable<Posit> {
  /// Default number of bits for Posit numbers
  static const int defaultNbits = 32;

  /// Default number of exponent bits for Posit numbers
  static const int defaultEs = 2;

  final int _bits;
  final int _nbits;
  final int _es;

  /// Static constant for NaR (Not a Real) - sign bit is 1, all other bits are 0
  static const Posit naR = Posit._(0x80000000, defaultNbits, defaultEs);

  /// Static constant for Zero - all bits set to 0
  static const Posit zero = Posit._(0x00000000, defaultNbits, defaultEs);

  /// Creates a Posit from raw bits.
  ///
  /// [bits] - the raw bit representation
  /// [nbits] - total number of bits (default 32)
  /// [es] - number of exponent bits (default 2)
  const Posit._(this._bits, this._nbits, this._es);

  /// Creates a Posit from a number.
  factory Posit.fromNum(num value, {int nbits = defaultNbits, int es = defaultEs}) {
    _validatePositParams(nbits, es);
    final bits = PositEncoding.encodeFromDouble(value.toDouble(), nbits, es);
    return Posit._(bits, nbits, es);
  }

  /// Creates a Posit from raw bits.
  factory Posit.fromBits(int bits, {int nbits = defaultNbits, int es = defaultEs}) {
    _validatePositParams(nbits, es);
    return Posit._(bits, nbits, es);
  }

  /// Creates a NaR (Not a Real) Posit with the specified bit configuration.
  factory Posit.naRWithConfig({int nbits = defaultNbits, int es = defaultEs}) {
    _validatePositParams(nbits, es);
    final narBits = 1 << (nbits - 1); // Sign bit = 1, all other bits = 0
    return Posit._(narBits, nbits, es);
  }

  /// Creates a Zero Posit with the specified bit configuration.
  factory Posit.zeroWithConfig({int nbits = defaultNbits, int es = defaultEs}) {
    _validatePositParams(nbits, es);
    return Posit._(0, nbits, es);
  }

  /// Creates a Posit from its components using bitwise operations.
  factory Posit.fromComponents(
    int sign,
    int regime,
    int exponent,
    int fraction, {
    int nbits = defaultNbits,
    int es = defaultEs,
  }) {
    _validatePositParams(nbits, es);

    // Start with sign bit
    int result = sign << (nbits - 1);

    // Add regime bits
    if (regime >= 0) {
      // Positive regime: add 1s
      for (int i = 0; i < regime && i < nbits - 1; i++) {
        result |= (1 << (nbits - 2 - i));
      }
    } else {
      // Negative regime: add 0s
      for (int i = 0; i < -regime && i < nbits - 1; i++) {
        result &= ~(1 << (nbits - 2 - i));
      }
    }

    // Add exponent bits
    final regimeBits = regime >= 0 ? regime + 1 : -regime;
    final exponentStart = nbits - 1 - regimeBits - es;
    if (exponentStart >= 0) {
      result |= (exponent << exponentStart);
    }

    // Add fraction bits
    final fractionBits = nbits - 1 - regimeBits - es;
    if (fractionBits > 0) {
      result |= (fraction & ((1 << fractionBits) - 1));
    }

    return Posit._(result, nbits, es);
  }

  /// Parses a string containing a number literal into a Posit.
  ///
  /// The method first tries to read the [input] as integer, then as double.
  /// If that fails, it throws a [FormatException].
  static Posit parse(String input, {int nbits = defaultNbits, int es = defaultEs}) {
    _validatePositParams(nbits, es);
    final num? result = num.tryParse(input);
    if (result != null) {
      return Posit.fromNum(result, nbits: nbits, es: es);
    }
    throw FormatException('Invalid number: $input');
  }

  /// Parses a string containing a number literal into a Posit.
  ///
  /// Like [parse], except that this function returns `null` for invalid inputs
  /// instead of throwing.
  static Posit? tryParse(String input, {int nbits = defaultNbits, int es = defaultEs}) {
    _validatePositParams(nbits, es);
    final num? result = num.tryParse(input);
    if (result != null) {
      return Posit.fromNum(result, nbits: nbits, es: es);
    }
    return null;
  }

  /// Validates posit parameters.
  static void _validatePositParams(int nbits, int es) {
    if (nbits < 2 || nbits > 64) {
      throw ArgumentError('nbits must be between 2 and 64, got $nbits');
    }
    if (es < 0 || es > nbits - 2) {
      throw ArgumentError('es must be between 0 and ${nbits - 2}, got $es');
    }
  }

  /// Returns the raw bit representation.
  int get bits => _bits;

  /// Returns the total number of bits.
  int get nbits => _nbits;

  /// Returns the number of exponent bits.
  int get es => _es;

  /// Extracts the sign bit (1 if negative, 0 if positive).
  int get signBit => PositEncoding.extractSignBit(_bits, _nbits) ? 1 : 0;

  /// Extracts the regime field using bitwise operations.
  int get regime => PositEncoding.extractRegimeBits(_bits, _nbits);

  /// Extracts the exponent field using bitwise operations.
  int get exponent => PositEncoding.extractExponentBits(_bits, _nbits, _es);

  /// Extracts the fraction field using bitwise operations.
  int get fraction => PositEncoding.extractFractionBits(_bits, _nbits, _es);

  /// Extracts the useed value (2^(2^es)).
  int get useed => PositEncoding.calculateUseed(_es);

  /// Extracts the k value.
  int get k => PositEncoding.extractKValue(_bits, _nbits);

  double get fractionValue => PositEncoding.calculateFractionValue(_bits, _nbits, _es);

  /// Checks if this Posit represents NaR (Not a Real).
  /// NaR is represented as sign bit = 1 and all other bits = 0
  bool get isNaR => _bits == (1 << (_nbits - 1));

  /// Checks if this Posit represents a special value (NaR or Zero).
  bool get isSpecial => isNaR || isZero;

  /// Checks if this Posit is zero.
  /// Zero is represented as all bits set to 0
  bool get isZero => _bits == 0;

  /// Checks if this Posit is negative.
  bool get isNegative => signBit == 1 && !isNaR;

  /// Checks if this Posit is positive.
  bool get isPositive => signBit == 0 && !isZero;

  /// Checks if this Posit is finite.
  bool get isFinite => !isNaR;

  /// Converts this Posit to a double.
  double toDouble() {
    return PositEncoding.decodeToDouble(this, _nbits, _es);
  }

  /// Converts this Posit to an int.
  int toInt() {
    return toDouble().round();
  }

  /// Returns the remainder of the truncating division of `this` by [other].
  Posit remainder(Object other) {
    if (other is Posit) {
      return Posit.fromNum(toDouble().remainder(other.toDouble()), nbits: _nbits, es: _es);
    } else if (other is num) {
      return Posit.fromNum(toDouble().remainder(other.toDouble()), nbits: _nbits, es: _es);
    } else {
      throw UnsupportedError('Remainder not supported for $other');
    }
  }

  /// Euclidean modulo of this number by [other].
  Posit operator %(Object other) {
    if (other is Posit) {
      return Posit.fromNum(toDouble() % other.toDouble(), nbits: _nbits, es: _es);
    } else if (other is num) {
      return Posit.fromNum(toDouble() % other.toDouble(), nbits: _nbits, es: _es);
    } else {
      throw UnsupportedError('Modulo not supported for $other');
    }
  }

  /// Truncating division operator.
  int operator ~/(Object other) {
    if (other is Posit) {
      return (toDouble() / other.toDouble()).truncate();
    } else if (other is num) {
      return (toDouble() / other.toDouble()).truncate();
    } else {
      throw UnsupportedError('Truncating division not supported for $other');
    }
  }

  /// Whether this number is numerically smaller than [other].
  bool operator <(Object other) {
    if (other is Posit) {
      return compareTo(other) < 0;
    } else if (other is num) {
      return compareTo(Posit.fromNum(other, nbits: _nbits, es: _es)) < 0;
    } else {
      return false;
    }
  }

  /// Whether this number is numerically smaller than or equal to [other].
  bool operator <=(Object other) {
    if (other is Posit) {
      return compareTo(other) <= 0;
    } else if (other is num) {
      return compareTo(Posit.fromNum(other, nbits: _nbits, es: _es)) <= 0;
    } else {
      return false;
    }
  }

  /// Whether this number is numerically greater than [other].
  bool operator >(Object other) {
    if (other is Posit) {
      return compareTo(other) > 0;
    } else if (other is num) {
      return compareTo(Posit.fromNum(other, nbits: _nbits, es: _es)) > 0;
    } else {
      return false;
    }
  }

  /// Whether this number is numerically greater than or equal to [other].
  bool operator >=(Object other) {
    if (other is Posit) {
      return compareTo(other) >= 0;
    } else if (other is num) {
      return compareTo(Posit.fromNum(other, nbits: _nbits, es: _es)) >= 0;
    } else {
      return false;
    }
  }

  /// The absolute value of this number.
  Posit abs() {
    return PositUtils.abs(this);
  }

  /// Negative one, zero or positive one depending on the sign and
  /// numerical value of this number.
  Posit get sign {
    if (isNaR) return Posit.fromNum(double.nan, nbits: _nbits, es: _es);
    if (isZero) return Posit.fromNum(0.0, nbits: _nbits, es: _es);
    return Posit.fromNum(isNegative ? -1.0 : 1.0, nbits: _nbits, es: _es);
  }

  /// The integer closest to this number.
  int round() {
    return toDouble().round();
  }

  /// The greatest integer no greater than this number.
  int floor() {
    return toDouble().floor();
  }

  /// The least integer no smaller than this number.
  int ceil() {
    return toDouble().ceil();
  }

  /// The integer obtained by discarding any fractional digits from this number.
  int truncate() {
    return toDouble().truncate();
  }

  /// The double integer value closest to this value.
  double roundToDouble() {
    return toDouble().roundToDouble();
  }

  /// Returns the greatest double integer value no greater than this.
  double floorToDouble() {
    return toDouble().floorToDouble();
  }

  /// Returns the least double integer value no smaller than this.
  double ceilToDouble() {
    return toDouble().ceilToDouble();
  }

  /// Returns the double integer value obtained by discarding any fractional
  /// digits from the double value of this.
  double truncateToDouble() {
    return toDouble().truncateToDouble();
  }

  /// Returns this number clamped to be in the range [lowerLimit]-[upperLimit].
  Posit clamp(Object lowerLimit, Object upperLimit) {
    if (lowerLimit is Posit && upperLimit is Posit) {
      return PositUtils.clamp(this, lowerLimit, upperLimit);
    }

    final lower = lowerLimit is Posit
        ? lowerLimit
        : Posit.fromNum((lowerLimit as num).toDouble(), nbits: _nbits, es: _es);
    final upper = upperLimit is Posit
        ? upperLimit
        : Posit.fromNum((upperLimit as num).toDouble(), nbits: _nbits, es: _es);
    return PositUtils.clamp(this, lower, upper);
  }

  /// A decimal-point string-representation of this number.
  String toStringAsFixed(int fractionDigits) {
    return toDouble().toStringAsFixed(fractionDigits);
  }

  /// An exponential string-representation of this number.
  String toStringAsExponential([int? fractionDigits]) {
    return toDouble().toStringAsExponential(fractionDigits);
  }

  /// A string representation with [precision] significant digits.
  String toStringAsPrecision(int precision) {
    return toDouble().toStringAsPrecision(precision);
  }

  @override
  int compareTo(Posit other) {
    if (isNaR && other.isNaR) return 0;
    if (isNaR) return 1; // NaR is greater than everything
    if (other.isNaR) return -1;

    if (isZero && other.isZero) return 0;

    if (signBit != other.signBit) {
      return signBit == 0 ? 1 : -1; // positive > negative
    }

    if (signBit == 0) {
      // Both positive
      return _compareMagnitude(other);
    } else {
      // Both negative: compare magnitude components and reverse result
      // For negative numbers: larger magnitude = smaller value
      return -_compareMagnitude(other);
    }
  }

  /// Compares the magnitude (absolute value) of this Posit with another.
  /// Returns positive if this > other, negative if this < other, 0 if equal.
  int _compareMagnitude(Posit other) {
    final thisPos = signBit == 0
        ? this
        : Posit.fromBits(PositEncoding.negateIfNegative(_bits, _nbits), nbits: _nbits, es: _es);
    final otherPos = other.signBit == 0
        ? other
        : Posit.fromBits(PositEncoding.negateIfNegative(other._bits, other._nbits), nbits: other._nbits, es: other._es);

    // Compare regime (k value)
    final thisK = thisPos.k;
    final otherK = otherPos.k;

    if (thisK != otherK) {
      return thisK.compareTo(otherK);
    }

    // Same regime, compare exponent
    final thisExp = thisPos.exponent;
    final otherExp = otherPos.exponent;

    if (thisExp != otherExp) {
      return thisExp.compareTo(otherExp);
    }

    // Same regime and exponent, compare fraction
    final thisFrac = thisPos.fraction;
    final otherFrac = otherPos.fraction;

    return thisFrac.compareTo(otherFrac);
  }

  @override
  bool operator ==(Object other) {
    if (other is! Posit) return false;
    return _bits == other._bits && _nbits == other._nbits && _es == other._es;
  }

  @override
  int get hashCode => Object.hash(_bits, _nbits, _es);

  @override
  String toString() {
    return 'Posit(${toDouble()})';
  }

  /// Returns a debug string showing the sign, regime, exponent, and fraction fields.
  ///
  /// [radix] - the radix for displaying numeric values (default: 2 for binary)
  String toDebugString({int radix = 2}) {
    final signStr = signBit.toRadixString(radix);
    final kString = k;
    final regimeStr = regime.toRadixString(radix);
    final exponentStr = exponent.toRadixString(radix);
    final fractionStr = fraction.toRadixString(radix);
    final bitsStr = _bits.toRadixString(radix).padLeft(radix == 2 ? _nbits : 0, '0');

    return 'Posit(sign: $signStr, k: $kString, regime: $regimeStr, exponent: $exponentStr, fraction: $fractionStr, bits: $bitsStr)';
  }

  // Arithmetic operations
  Posit operator +(Object other) {
    if (other is Posit) {
      return addPosits(this, other);
    } else if (other is num) {
      return addPosits(this, Posit.fromNum(other, nbits: _nbits, es: _es));
    } else {
      throw UnsupportedError('Addition not supported for $other');
    }
  }

  Posit operator -(Object other) {
    if (other is Posit) {
      return subtractPosits(this, other);
    } else if (other is num) {
      return subtractPosits(this, Posit.fromNum(other, nbits: _nbits, es: _es));
    } else {
      throw UnsupportedError('Subtraction not supported for $other');
    }
  }

  Posit operator *(Object other) {
    if (other is Posit) {
      return multiplyPosits(this, other);
    } else if (other is num) {
      return multiplyPosits(this, Posit.fromNum(other, nbits: _nbits, es: _es));
    } else {
      throw UnsupportedError('Multiplication not supported for $other');
    }
  }

  Posit operator /(Object other) {
    if (other is Posit) {
      return dividePosits(this, other);
    } else if (other is num) {
      return dividePosits(this, Posit.fromNum(other, nbits: _nbits, es: _es));
    } else {
      throw UnsupportedError('Division not supported for $other');
    }
  }

  Posit operator -() {
    return negatePosit(this);
  }

  // Delegate to arithmetic module
  static Posit addPosits(Posit a, Posit b) {
    return PositArithmetic.add(a, b);
  }

  static Posit subtractPosits(Posit a, Posit b) {
    return PositArithmetic.subtract(a, b);
  }

  static Posit multiplyPosits(Posit a, Posit b) {
    return PositArithmetic.multiply(a, b);
  }

  static Posit dividePosits(Posit a, Posit b) {
    return PositArithmetic.divide(a, b);
  }

  static Posit negatePosit(Posit a) {
    return PositArithmetic.negate(a);
  }
}
