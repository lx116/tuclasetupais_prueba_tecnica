import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tuclasetupais_prueba_tecnica/core/contacts/data/contacts_availability.dart';
import 'package:tuclasetupais_prueba_tecnica/core/contacts/data/service_get_contacts.dart';
import 'package:tuclasetupais_prueba_tecnica/features/favorites/data/datasources/favorite_contacts_local_datasource.dart';
import 'package:tuclasetupais_prueba_tecnica/features/favorites/data/repositories/favorite_contacts_repository_impl.dart';
import 'package:tuclasetupais_prueba_tecnica/features/favorites/domain/repositories/favorites_unavailable_exception.dart';

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

final _three = jsonEncode([
  contactJson(id: 1),
  contactJson(id: 2, overrides: {'name': 'Matías Soto'}),
  contactJson(id: 3, overrides: {'name': 'Bruno Díaz'}),
]);

void main() {
  group('FavoriteContactsLocalDataSource', () {
    test(
      'returns the contacts of those ids, in list order, from memory',
      () async {
        final datasource = FavoriteContactsLocalDataSource(
          await _service({_path: _three}),
          ContactsAvailability(),
        );

        final models = await datasource.getByIds({3, 1});

        expect(models.map((m) => m.id), [1, 3]);
      },
    );

    test('ids that do not exist are left out', () async {
      final datasource = FavoriteContactsLocalDataSource(
        await _service({_path: _three}),
        ContactsAvailability(),
      );

      expect((await datasource.getByIds({2, 99})).map((m) => m.id), [2]);
    });

    test('is empty when the JSON was missing', () async {
      final datasource = FavoriteContactsLocalDataSource(
        await _service({}),
        ContactsAvailability(),
      );

      expect(await datasource.getByIds({1}), isEmpty);
    });

    test('rethrows the format error when the data was invalid', () async {
      final datasource = FavoriteContactsLocalDataSource(
        await _service({_path: '{ nope'}),
        ContactsAvailability(),
      );

      expect(() => datasource.getByIds({1}), throwsFormatException);
    });

    test('is unavailable when the list call failed (no cache)', () async {
      final datasource = FavoriteContactsLocalDataSource(
        await _service({_path: _three}),
        ContactsAvailability()..markFailed(),
      );

      expect(
        () => datasource.getByIds({1}),
        throwsA(isA<FavoritesUnavailableException>()),
      );
    });
  });

  test('the repository maps the models to entities', () async {
    final repository = FavoriteContactsRepositoryImpl(
      FavoriteContactsLocalDataSource(
        await _service({_path: _three}),
        ContactsAvailability(),
      ),
    );

    final contacts = await repository.getContacts({2});

    expect(contacts.single.name, 'Matías Soto');
  });
}
