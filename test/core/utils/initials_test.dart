import 'package:flutter_test/flutter_test.dart';
import 'package:tuclasetupais_prueba_tecnica/core/utils/initials.dart';

void main() {
  test('takes the first letter of the first two words, uppercased', () {
    expect(initialsOf('Camila Reyes'), 'CR');
    expect(initialsOf('  ana   maría perez '), 'AM');
  });

  test('works with a single word and falls back for an empty name', () {
    expect(initialsOf('Ana'), 'A');
    expect(initialsOf('   '), '?');
  });
}
