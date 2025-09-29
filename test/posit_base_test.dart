import 'package:posit/posit.dart';
import 'package:test/test.dart';

void main() {
  group('Posit Core Tests', () {
    test('Posit creation from number', () {
      final p = Posit.fromNum(3.14);
      expect(p.nbits, equals(32));
      expect(p.es, equals(2));
    });

    test('Posit creation with custom parameters', () {
      final p = Posit.fromNum(1.0, nbits: 16, es: 1);
      expect(p.nbits, equals(16));
      expect(p.es, equals(1));
    });

    test('Posit equality', () {
      final p1 = Posit.fromNum(2.5);
      final p2 = Posit.fromNum(2.5);
      expect(p1, equals(p2));
    });

    test('Posit inequality', () {
      final p1 = Posit.fromNum(2.5);
      final p2 = Posit.fromNum(3.0);
      expect(p1, isNot(equals(p2)));
    });

    test('Posit toString', () {
      final p = Posit.fromNum(3.14);
      // TODO: implement toString test
    });
  });
}
