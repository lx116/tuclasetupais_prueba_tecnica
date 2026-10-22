import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tuclasetupais_prueba_tecnica/core/contacts/data/service_get_contacts.dart';

import '../../../features/contacts/support/contacts_fixtures.dart';

const _path = 'lib/assets/contacs.json';

class _LogEntry {
  _LogEntry(this.message, this.level);
  final String message;
  final int level;
}

void main() {
  _readTests();

  late List<_LogEntry> logs;

  ServiceGetContacts serviceWith(Map<String, String> assets) =>
      ServiceGetContacts(
        bundle: FakeAssetBundle(assets),
        assetPath: _path,
        log: (message, {required level, error}) =>
            logs.add(_LogEntry(message, level)),
      );

  setUp(() => logs = []);

  test('is not loaded before load() runs', () {
    final service = serviceWith({});
    expect(service.status, ContactsLoadStatus.notLoaded);
    expect(service.contacts, isEmpty);
  });

  group('good path', () {
    test('loads valid data into memory without logging', () async {
      final service = serviceWith({
        _path: jsonEncode([contactJson(id: 1), contactJson(id: 2)]),
      });

      await service.load();

      expect(service.status, ContactsLoadStatus.loaded);
      expect(service.contacts.map((c) => c.id), [1, 2]);
      expect(service.error, isNull);
      expect(logs, isEmpty);
    });

    test('loaded contacts cannot be modified from outside', () async {
      final service = serviceWith({
        _path: jsonEncode([contactJson()]),
      });
      await service.load();
      expect(() => service.contacts.clear(), throwsUnsupportedError);
    });
  });

  group('bad path: JSON missing', () {
    test('cancels the load, leaves an empty list and logs the gap', () async {
      final service = serviceWith({});

      await service.load();

      expect(service.status, ContactsLoadStatus.missing);
      expect(service.contacts, isEmpty);
      expect(logs, hasLength(1));
      expect(logs.single.message, contains(_path));
      expect(logs.single.message, contains('not found'));
    });
  });

  group('bad path: data does not match the model', () {
    final cases = <String, String>{
      'invalid role': jsonEncode([
        contactJson(overrides: {'role': 'Wizard'}),
      ]),
      'repeated ids': jsonEncode([contactJson(id: 1), contactJson(id: 1)]),
      'missing field': jsonEncode([contactJson()..remove('email')]),
      'not a list': jsonEncode(contactJson()),
      'not json': '{ nope',
    };

    cases.forEach((name, content) {
      test('$name: keeps nothing in memory and logs the cause', () async {
        final service = serviceWith({_path: content});

        await service.load();

        expect(service.status, ContactsLoadStatus.invalid);
        expect(service.contacts, isEmpty);
        expect(service.error, isA<FormatException>());
        expect(logs, hasLength(1));
        expect(logs.single.message, contains(_path));
      });
    });
  });
}

void _readTests() {
  group('read()', () {
    test('returns the loaded contacts', () async {
      final service = ServiceGetContacts(
        bundle: FakeAssetBundle({
          _path: jsonEncode([contactJson(id: 1)]),
        }),
        assetPath: _path,
        log: (message, {required level, error}) {},
      );
      await service.load();

      expect(service.read().map((m) => m.id), [1]);
    });

    test('is empty when the JSON was missing', () async {
      final service = ServiceGetContacts(
        bundle: FakeAssetBundle({}),
        assetPath: _path,
        log: (message, {required level, error}) {},
      );
      await service.load();

      expect(service.read(), isEmpty);
    });

    test('rethrows the format error when the data was invalid', () async {
      final service = ServiceGetContacts(
        bundle: FakeAssetBundle({_path: '{ nope'}),
        assetPath: _path,
        log: (message, {required level, error}) {},
      );
      await service.load();

      expect(service.read, throwsFormatException);
    });

    test('fails loudly when the service never loaded', () {
      final service = ServiceGetContacts(
        bundle: FakeAssetBundle({}),
        assetPath: _path,
        log: (message, {required level, error}) {},
      );

      expect(service.read, throwsStateError);
    });
  });
}
