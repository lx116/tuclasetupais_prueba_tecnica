import 'package:flutter_test/flutter_test.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/domain/entities/contact.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/domain/entities/contact_catalog.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/domain/entities/contact_validators.dart';

Contact _contact(int id) => Contact(
  id: id,
  name: 'Camila Reyes',
  role: 'Product Designer',
  department: 'Diseño',
  email: 'camila.reyes@empresa.cl',
  phone: '+56 9 1111 2222',
  active: true,
);

void main() {
  group('ContactValidators.role', () {
    test('accepts every role in the catalog', () {
      for (final role in ContactRoles.all) {
        expect(ContactValidators.role(role), isNull);
      }
    });

    test('rejects a role outside the catalog and an empty one', () {
      expect(ContactValidators.role('Wizard'), isNotNull);
      expect(ContactValidators.role(''), isNotNull);
    });
  });

  group('ContactValidators.department', () {
    test('accepts every department in the catalog', () {
      for (final department in ContactDepartments.all) {
        expect(ContactValidators.department(department), isNull);
      }
    });

    test('rejects a department outside the catalog', () {
      expect(ContactValidators.department('Marketing'), isNotNull);
    });
  });

  group('ContactValidators.email', () {
    test('accepts well-formed emails', () {
      expect(ContactValidators.email('camila.reyes@empresa.cl'), isNull);
      expect(ContactValidators.email('a@b.co'), isNull);
    });

    test('rejects malformed emails', () {
      for (final value in ['', 'abc', 'a@b', '@b.cl', 'a b@c.cl', 'a@b.']) {
        expect(ContactValidators.email(value), isNotNull, reason: value);
      }
    });
  });

  group('ContactValidators.uniqueIds', () {
    test('accepts a list without repeated ids', () {
      expect(ContactValidators.uniqueIds([_contact(1), _contact(2)]), isNull);
    });

    test('reports the repeated id', () {
      final error = ContactValidators.uniqueIds([
        _contact(1),
        _contact(2),
        _contact(1),
      ]);
      expect(error, contains('1'));
    });
  });

  test('Contact has value equality', () {
    expect(_contact(1), _contact(1));
    expect(_contact(1), isNot(_contact(2)));
  });
}
