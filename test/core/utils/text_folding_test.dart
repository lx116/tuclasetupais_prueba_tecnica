import 'package:flutter_test/flutter_test.dart';
import 'package:tuclasetupais_prueba_tecnica/core/utils/text_folding.dart';

void main() {
  test('lowercases and removes Spanish accents', () {
    expect(foldText('Ingeniería'), 'ingenieria');
    expect(foldText('MUÑOZ'), 'munoz');
    expect(foldText('Diseño'), 'diseno');
    expect(foldText('ÁÉÍÓÚ üç'), 'aeiou uc');
  });

  test('leaves other characters alone', () {
    expect(foldText('Ana-María 2'), 'ana-maria 2');
    expect(foldText(''), '');
  });
}
