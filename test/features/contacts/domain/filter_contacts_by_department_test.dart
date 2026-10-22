import 'package:flutter_test/flutter_test.dart';
import 'package:tuclasetupais_prueba_tecnica/core/contacts/domain/entities/contact.dart';
import 'package:tuclasetupais_prueba_tecnica/core/contacts/domain/entities/contact_catalog.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/domain/usecases/filter_contacts_by_department.dart';

Contact _in(int id, String department) => Contact(
  id: id,
  name: 'Contacto $id',
  role: 'QA Lead',
  department: department,
  email: 'x$id@empresa.cl',
  phone: '+56 9 1111 2222',
  active: true,
);

final _contacts = [
  _in(1, 'Ingeniería'),
  _in(2, 'Diseño'),
  _in(3, 'Ingeniería'),
  _in(4, 'Comercial'),
];

List<int> _ids(String department) => const FilterContactsByDepartment()(
  _contacts,
  department,
).map((c) => c.id).toList();

void main() {
  test('an empty department keeps every contact', () {
    expect(_ids(''), [1, 2, 3, 4]);
    expect(_ids('  '), [1, 2, 3, 4]);
  });

  test('keeps only the contacts of that department, in order', () {
    expect(_ids('Ingeniería'), [1, 3]);
    expect(_ids('Comercial'), [4]);
  });

  test('ignores case and accents, so the URL form matches', () {
    expect(_ids('ingenieria'), [1, 3]);
    expect(_ids('DISENO'), [2]);
  });

  test('is an exact department, not a partial one', () {
    expect(_ids('ingen'), isEmpty);
  });

  test('an unknown department matches nothing', () {
    expect(_ids('marketing'), isEmpty);
  });

  group('ContactDepartments.match', () {
    test('finds the catalog department for its URL form', () {
      expect(ContactDepartments.match('ingenieria'), 'Ingeniería');
      expect(ContactDepartments.match('DISEÑO'), 'Diseño');
    });

    test('is null for blank or unknown values', () {
      expect(ContactDepartments.match(''), isNull);
      expect(ContactDepartments.match('marketing'), isNull);
    });
  });
}
