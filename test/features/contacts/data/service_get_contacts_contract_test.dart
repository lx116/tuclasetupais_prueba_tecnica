import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/data/datasources/contacts_local_datasource.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/data/datasources/service_get_contacts.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/data/models/contact_model.dart';

import '../support/contacts_fixtures.dart';

const _path = 'lib/assets/contacs.json';

class _CountingBundle extends FakeAssetBundle {
  _CountingBundle(super.assets);

  final reads = <String>[];

  @override
  Future<ByteData> load(String key) {
    reads.add(key);
    return super.load(key);
  }
}

void main() {
  late _CountingBundle bundle;
  late List<String> logs;
  late ServiceGetContacts service;

  setUp(() {
    bundle = _CountingBundle({});
    logs = [];
    service = ServiceGetContacts(
      bundle: bundle,
      assetPath: _path,
      log: (message, {required level, error}) => logs.add(message),
    );
  });

  group('JSON loading contract', () {
    test('missing asset cancels loading and remains auditable', () async {
      await service.load();

      expect(service.status, ContactsLoadStatus.missing);
      expect(service.contacts, isEmpty);
      expect(
        await ContactsLocalDataSource(
          service,
          dice: FixedDice(2),
          latency: Duration.zero,
        ).getContacts(),
        isEmpty,
      );
      expect(bundle.reads, [_path]);
      expect(logs, hasLength(1));
      expect(logs.single, contains(_path));
      expect(logs.single, contains('not found'));
    });

    test('an existing empty JSON array is not a missing asset', () async {
      bundle.assets[_path] = '[]';

      await service.load();

      expect(service.status, ContactsLoadStatus.loaded);
      expect(service.contacts, isEmpty);
      expect(service.error, isNull);
      expect(
        await ContactsLocalDataSource(
          service,
          dice: FixedDice(2),
          latency: Duration.zero,
        ).getContacts(),
        isEmpty,
      );
      expect(logs, isEmpty);
    });

    test(
      'datasource serves every field from memory without reading again',
      () async {
        final records = [
          contactJson(id: 1),
          contactJson(id: 2, overrides: {'active': false}),
        ];
        bundle.assets[_path] = jsonEncode(records);
        final expected = records
            .map((record) => ContactModel.fromJson(record).toEntity())
            .toList();

        await service.load();
        // Removing the backing asset proves reads use memory after startup.
        bundle.assets.clear();
        final datasource = ContactsLocalDataSource(
          service,
          dice: FixedDice(2),
          latency: Duration.zero,
        );

        for (var read = 0; read < 2; read++) {
          final contacts = await datasource.getContacts();
          expect(contacts.map((model) => model.toEntity()), expected);
        }
        expect(service.status, ContactsLoadStatus.loaded);
        expect(service.contacts.map((model) => model.toEntity()), expected);
        expect(service.error, isNull);
        expect(bundle.reads, [_path]);
        expect(logs, isEmpty);
      },
    );

    final invalidRecords = <String, Object?>{
      'wrong id type': contactJson(overrides: {'id': '2'}),
      'missing name': contactJson(id: 2)..remove('name'),
      'invalid role': contactJson(id: 2, overrides: {'role': 'Wizard'}),
      'invalid department': contactJson(
        id: 2,
        overrides: {'department': 'Unknown'},
      ),
      'invalid email': contactJson(id: 2, overrides: {'email': 'invalid'}),
      'invalid phone': contactJson(id: 2, overrides: {'phone': 'abc'}),
      'wrong active type': contactJson(id: 2, overrides: {'active': 'yes'}),
      'non-object record': 42,
    };

    for (final entry in invalidRecords.entries) {
      test(
        '${entry.key} rejects the entire load, including valid records',
        () async {
          bundle.assets[_path] = jsonEncode([contactJson(), entry.value]);

          await service.load();

          expect(service.status, ContactsLoadStatus.invalid);
          expect(service.contacts, isEmpty);
          expect(service.error, isA<FormatException>());
          await expectLater(
            ContactsLocalDataSource(
              service,
              dice: FixedDice(2),
              latency: Duration.zero,
            ).getContacts,
            throwsFormatException,
          );
          expect(logs, hasLength(1));
          expect(logs.single, contains(_path));
        },
      );
    }
  });
}
