# Posit

A Dart implementation of Posit (unum) numbers

[https://en.wikipedia.org/wiki/Unum_(number_format)](https://en.wikipedia.org/wiki/Unum_(number_format))

## Features

- [posit_base.dart](lib/src/posit_base.dart): Core Posit Class
- [encoding.dart](lib/src/encoding.dart): Bit-level encoding/decoding
- [arithmetic.dart](lib/src/arithmetic.dart): Arithmetic operations
- [utils.dart](lib/src/utils.dart): Utility functions

## Usage

```yaml
dependencies:
  posit: ^0.0.0
```

See the [example](example/posit_example.dart) for usage.

```dart
import 'package:posit/posit.dart';

void main() {
  final p1 = Posit.fromNum(3.14159);
  final p2 = Posit.fromNum(2.71828);
  
  final sum = p1 + p2;
  final product = p1 * p2;
}
```

## Development

To run tests:
```bash
fvm dart test
```

To run the example:
```bash
fvm dart run example/posit_example.dart
```
