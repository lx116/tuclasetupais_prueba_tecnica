import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/data/datasources/contacts_local_datasource.dart';
import 'package:tuclasetupais_prueba_tecnica/core/contacts/data/service_get_contacts.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/data/repositories/contact_repository_impl.dart';
import 'package:tuclasetupais_prueba_tecnica/core/contacts/domain/entities/contact.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/domain/repositories/contacts_connection_exception.dart';

import '../support/contacts_fixtures.dart';

const _path = 'lib/assets/contacs.json';

Future<ContactRepositoryImpl> _repo(
  Map<String, String> assets, {
  int roll = 2,
}) async {
  final service = ServiceGetContacts(
    bundle: FakeAssetBundle(assets),
    assetPath: _path,
    log: (message, {required level, error}) {},
  );
  await service.load();
  return ContactRepositoryImpl(
    ContactsLocalDataSource(
      service,
      dice: FixedDice(roll),
      latency: Duration.zero,
    ),
  );
}

void main() {
  test('maps datasource models to domain entities', () async {
    final repo = await _repo({
      _path: jsonEncode([contactJson(id: 7)]),
    });

    final contacts = await repo.getContacts();

    expect(contacts, [isA<Contact>().having((c) => c.id, 'id', 7)]);
  });

  test('returns an empty list when there is no data', () async {
    final repo = await _repo({});
    expect(await repo.getContacts(), isEmpty);
  });

  test('returns an empty list on an empty call (not an error)', () async {
    final repo = await _repo({
      _path: jsonEncode([contactJson()]),
    }, roll: 6);
    expect(await repo.getContacts(), isEmpty);
  });

  test('propagates the connection error', () async {
    final repo = await _repo({
      _path: jsonEncode([contactJson()]),
    }, roll: 1);
    expect(repo.getContacts, throwsA(isA<ContactsConnectionException>()));
  });
}
