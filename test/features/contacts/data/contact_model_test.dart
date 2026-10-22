import 'dart:convert';
import 'dart:io';

import 'package:cellphone_validator/cellphone_validator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/data/models/contact_model.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/data/models/phone_number_validator.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/domain/entities/contact.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/domain/entities/contact_validators.dart';

Map<String, dynamic> _json({Map<String, dynamic>? overrides}) => {
  'id': 1,
  'name': 'Camila Reyes',
  'role': 'Product Designer',
  'department': 'Diseño',
  'email': 'camila.reyes@empresa.cl',
  'phone': '+56 9 1111 2222',
  'active': true,
  ...?overrides,
};

void main() {
  group('PhoneNumberValidator', () {
    test('accepts a valid international phone number', () {
      expect(PhoneNumberValidator.validate('+56 9 1111 2222'), isNull);
    });

    test('rejects malformed phone numbers', () {
      for (final value in ['', 'abc', '12345', '+56 9 11', '56 9 1111 2222']) {
        expect(PhoneNumberValidator.validate(value), isNotNull, reason: value);
      }
    });

    test('does not mutate the package country list', () {
      final before = CellPhoneValidator.countries
          .map((c) => c.isoCode)
          .toList();
      PhoneNumberValidator.validate('+56 9 1111 2222');
      expect(CellPhoneValidator.countries.map((c) => c.isoCode), before);
    });
  });

  group('ContactModel.fromJson', () {
    test('parses a valid record into the entity', () {
      final contact = ContactModel.fromJson(_json()).toEntity();
      expect(
        contact,
        const Contact(
          id: 1,
          name: 'Camila Reyes',
          role: 'Product Designer',
          department: 'Diseño',
          email: 'camila.reyes@empresa.cl',
          phone: '+56 9 1111 2222',
          active: true,
        ),
      );
    });

    test('round-trips through toJson', () {
      expect(ContactModel.fromJson(_json()).toJson(), _json());
    });

    test('maps an entity back to a model', () {
      final contact = ContactModel.fromJson(_json()).toEntity();
      expect(ContactModel.fromEntity(contact).toJson(), _json());
    });

    test('rejects each invalid field with a FormatException', () {
      final invalid = <String, Object?>{
        'role': 'Wizard',
        'department': 'Marketing',
        'email': 'not-an-email',
        'phone': '12345',
      };
      invalid.forEach((field, value) {
        expect(
          () => ContactModel.fromJson(_json(overrides: {field: value})),
          throwsFormatException,
          reason: field,
        );
      });
    });

    test('rejects missing or wrongly typed fields with a FormatException', () {
      expect(
        () => ContactModel.fromJson(_json()..remove('name')),
        throwsFormatException,
      );
      expect(
        () => ContactModel.fromJson(_json(overrides: {'id': '1'})),
        throwsFormatException,
      );
      expect(
        () => ContactModel.fromJson(_json(overrides: {'active': 'yes'})),
        throwsFormatException,
      );
    });
  });

  test('every record in the bundled contacts.json is valid and unique', () {
    final raw =
        jsonDecode(File('lib/assets/contacs.json').readAsStringSync())
            as List<dynamic>;
    final contacts = raw
        .map((e) => ContactModel.fromJson(e as Map<String, dynamic>).toEntity())
        .toList();
    expect(contacts, hasLength(18));
    expect(ContactValidators.uniqueIds(contacts), isNull);
  });
}
