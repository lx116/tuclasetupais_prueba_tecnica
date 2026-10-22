import 'package:tuclasetupais_prueba_tecnica/core/contacts/data/contacts_availability.dart';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tuclasetupais_prueba_tecnica/core/di/injection.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/data/datasources/contacts_local_datasource.dart';
import 'package:tuclasetupais_prueba_tecnica/core/contacts/data/service_get_contacts.dart';
import 'package:tuclasetupais_prueba_tecnica/core/contacts/data/models/contact_model.dart';
import 'package:tuclasetupais_prueba_tecnica/main.dart' as app;

import 'features/contacts/support/contacts_fixtures.dart';

void main() {
  testWidgets(
    'main starts the service and exposes bundled contacts in memory',
    (tester) async {
      await sl.reset();
      addTearDown(() => sl.reset());
      final records =
          jsonDecode(File('lib/assets/contacs.json').readAsStringSync())
              as List<dynamic>;
      final expected = records
          .map(
            (record) => ContactModel.fromJson(
              record as Map<String, dynamic>,
            ).toEntity(),
          )
          .toList();
      expect(expected, isNotEmpty);

      // Exercise the real entry point, not a replacement bootstrap in the test.
      await tester.runAsync(app.main);
      await tester.pump();

      expect(find.byType(app.MyApp), findsOneWidget);
      final service = sl<ServiceGetContacts>();
      expect(service.status, ContactsLoadStatus.loaded);
      expect(service.contacts.map((model) => model.toEntity()), expected);
      // The app's own call rolls random dice; read through a fixed one.
      await sl.unregister<ContactsLocalDataSource>();
      final datasource = ContactsLocalDataSource(
        service,
        dice: FixedDice(2),
        latency: Duration.zero,
        availability: ContactsAvailability(),
      );
      final contacts = await datasource.getContacts();
      expect(contacts.map((model) => model.toEntity()), expected);

      // Let the app's simulated 800ms call finish before the test ends.
      await tester.pump(contactsLatency);
    },
  );
}
