import 'package:flutter_test/flutter_test.dart';
import 'package:tuclasetupais_prueba_tecnica/core/contacts/domain/entities/contact.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/domain/usecases/search_contacts.dart';

Contact _named(int id, String name) => Contact(
  id: id,
  name: name,
  role: 'QA Lead',
  department: 'Ingeniería',
  email: 'x$id@empresa.cl',
  phone: '+56 9 1111 2222',
  active: true,
);

final _contacts = [
  _named(1, 'Ana Pérez'),
  _named(2, 'Adriana Muñoz'),
  _named(3, 'Matías Soto'),
  _named(4, 'Juana López'),
  _named(5, 'Bruno Díaz'),
];

List<int> _ids(String query) =>
    const SearchContacts()(_contacts, query).map((c) => c.id).toList();

void main() {
  test('an empty or blank query returns every contact', () {
    expect(_ids(''), [1, 2, 3, 4, 5]);
    expect(_ids('   '), [1, 2, 3, 4, 5]);
  });

  test('matches any part of the name', () {
    expect(_ids('ana'), [1, 2, 4]);
    expect(_ids('soto'), [3]);
  });

  test('ignores case', () {
    expect(_ids('ANA'), [1, 2, 4]);
    expect(_ids('bRuNo'), [5]);
  });

  test('ignores accents on both sides', () {
    expect(_ids('matias'), [3]);
    expect(_ids('MATÍAS'), [3]);
    expect(_ids('munoz'), [2]);
    expect(_ids('perez'), [1]);
    expect(_ids('diaz'), [5]);
  });

  test('ignores surrounding spaces and keeps inner ones', () {
    expect(_ids('  ana  '), [1, 2, 4]);
    expect(_ids('ana p'), [1]);
  });

  test('searches the name only, not the email or role', () {
    expect(_ids('empresa'), isEmpty);
    expect(_ids('qa lead'), isEmpty);
  });

  test('returns nothing when no name matches and keeps the order', () {
    expect(_ids('zzz'), isEmpty);
    expect(_ids('a').first, 1);
  });
}
