import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tuclasetupais_prueba_tecnica/core/contacts/data/contacts_availability.dart';
import 'package:tuclasetupais_prueba_tecnica/core/contacts/data/service_get_contacts.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contact_detail/data/datasources/contact_detail_local_datasource.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contact_detail/data/repositories/contact_detail_repository_impl.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contact_detail/domain/repositories/contact_detail_unavailable_exception.dart';

import '../../contacts/support/contacts_fixtures.dart';

const _path = 'lib/assets/contacs.json';

Future<ServiceGetContacts> _service(Map<String, String> assets) async {
  final service = ServiceGetContacts(
    bundle: FakeAssetBundle(assets),
    assetPath: _path,
    log: (message, {required level, error}) {},
  );
  await service.load();
  return service;
}

final _two = jsonEncode([
  contactJson(id: 1),
  contactJson(id: 2, overrides: {'name': 'Matías Soto'}),
]);

void main() {
  group('ContactDetailLocalDataSource', () {
    test('finds a contact by id in memory, without any delay', () async {
      final datasource = ContactDetailLocalDataSource(
        await _service({_path: _two}),
        ContactsAvailability(),
      );

      expect((await datasource.getContactById(2))?.name, 'Matías Soto');
    });

    test('returns null for an id that does not exist', () async {
      final datasource = ContactDetailLocalDataSource(
        await _service({_path: _two}),
        ContactsAvailability(),
      );

      expect(await datasource.getContactById(99), isNull);
    });

    test('returns null when the JSON was missing', () async {
      final datasource = ContactDetailLocalDataSource(
        await _service({}),
        ContactsAvailability(),
      );

      expect(await datasource.getContactById(1), isNull);
    });

    test('rethrows the format error when the data was invalid', () async {
      final datasource = ContactDetailLocalDataSource(
        await _service({_path: '{ nope'}),
        ContactsAvailability(),
      );

      expect(() => datasource.getContactById(1), throwsFormatException);
    });

    test('is unavailable when the list call failed (no cache)', () async {
      final availability = ContactsAvailability()..markFailed();
      final datasource = ContactDetailLocalDataSource(
        await _service({_path: _two}),
        availability,
      );

      expect(
        () => datasource.getContactById(1),
        throwsA(isA<ContactDetailUnavailableException>()),
      );
    });

    test('works again once the list call succeeds', () async {
      final availability = ContactsAvailability()..markFailed();
      final datasource = ContactDetailLocalDataSource(
        await _service({_path: _two}),
        availability,
      );

      availability.markAvailable();

      expect((await datasource.getContactById(1))?.id, 1);
    });
  });

  group('ContactDetailRepositoryImpl', () {
    test('maps the model to a domain entity', () async {
      final repo = ContactDetailRepositoryImpl(
        ContactDetailLocalDataSource(
          await _service({_path: _two}),
          ContactsAvailability(),
        ),
      );

      final contact = await repo.getContactById(1);

      expect(contact?.email, 'camila.reyes@empresa.cl');
    });

    test('returns null when the contact does not exist', () async {
      final repo = ContactDetailRepositoryImpl(
        ContactDetailLocalDataSource(
          await _service({_path: _two}),
          ContactsAvailability(),
        ),
      );

      expect(await repo.getContactById(99), isNull);
    });
  });
}
