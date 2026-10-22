import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/data/datasources/contacts_calls/call_empty.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/data/datasources/contacts_calls/call_error.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/data/datasources/contacts_calls/call_ok.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/data/datasources/contacts_local_datasource.dart';
import 'package:tuclasetupais_prueba_tecnica/core/contacts/data/service_get_contacts.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/domain/repositories/contacts_connection_exception.dart';

import '../support/contacts_fixtures.dart';

const _path = 'lib/assets/contacs.json';

ServiceGetContacts _service(Map<String, String> assets) => ServiceGetContacts(
  bundle: FakeAssetBundle(assets),
  assetPath: _path,
  log: (message, {required level, error}) {},
);

ContactsLocalDataSource _datasource(
  ServiceGetContacts service, {
  int roll = 2,
  Duration latency = Duration.zero,
}) => ContactsLocalDataSource(service, dice: FixedDice(roll), latency: latency);

Future<ServiceGetContacts> _loaded(Map<String, String> assets) async {
  final service = _service(assets);
  await service.load();
  return service;
}

void main() {
  group('commands', () {
    test('CallError simulates a broken connection', () {
      expect(CallError().execute, throwsA(isA<ContactsConnectionException>()));
    });

    test('CallEmpty simulates an empty list', () async {
      expect(await CallEmpty().execute(), isEmpty);
    });

    test('CallOk returns the in-memory contacts', () async {
      final service = await _loaded({
        _path: jsonEncode([contactJson(id: 1), contactJson(id: 2)]),
      });

      final models = await CallOk(service).execute();

      expect(models.map((m) => m.id), [1, 2]);
    });
  });

  group('dice picks the command', () {
    final assets = {
      _path: jsonEncode([contactJson()]),
    };

    for (final roll in [1, 3, 5]) {
      test('$roll fails with a connection error', () async {
        final datasource = _datasource(await _loaded(assets), roll: roll);
        expect(
          datasource.getContacts,
          throwsA(isA<ContactsConnectionException>()),
        );
      });
    }

    for (final roll in [2, 4]) {
      test('$roll succeeds with the contacts', () async {
        final datasource = _datasource(await _loaded(assets), roll: roll);
        expect(await datasource.getContacts(), hasLength(1));
      });
    }

    test('6 succeeds with an empty list', () async {
      final datasource = _datasource(await _loaded(assets), roll: 6);
      expect(await datasource.getContacts(), isEmpty);
    });

    test('rejects a roll outside 1..6', () async {
      final datasource = _datasource(await _loaded(assets), roll: 7);
      expect(datasource.getContacts, throwsRangeError);
    });
  });

  test('waits for the simulated latency before answering', () async {
    final service = await _loaded({
      _path: jsonEncode([contactJson()]),
    });
    final datasource = _datasource(
      service,
      latency: const Duration(milliseconds: 100),
    );

    final stopwatch = Stopwatch()..start();
    await datasource.getContacts();

    expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(95));
  });

  group('local data (command CallOk)', () {
    test('fails loudly when the service has not loaded yet', () {
      final datasource = _datasource(_service({}));
      expect(datasource.getContacts, throwsStateError);
    });

    test('returns an empty list when the JSON was missing', () async {
      final datasource = _datasource(await _loaded({}));
      expect(await datasource.getContacts(), isEmpty);
    });

    test('rethrows the format error when the data was invalid', () async {
      final datasource = _datasource(await _loaded({_path: '{ nope'}));
      expect(datasource.getContacts, throwsFormatException);
    });
  });
}
