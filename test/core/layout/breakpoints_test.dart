import 'package:flutter_test/flutter_test.dart';
import 'package:tuclasetupais_prueba_tecnica/core/layout/breakpoints.dart';

void main() {
  test('a screen is wide only once it passes 900px', () {
    expect(isWideWidth(899), isFalse);
    expect(isWideWidth(900), isFalse);
    expect(isWideWidth(900.5), isTrue);
    expect(isWideWidth(1280), isTrue);
  });
}
