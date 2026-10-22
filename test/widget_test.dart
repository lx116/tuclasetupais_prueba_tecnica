import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tuclasetupais_prueba_tecnica/core/di/injection.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/data/datasources/dice_roller.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/presentation/ui/contact_list_item.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/presentation/ui/contacts_list.dart';
import 'package:tuclasetupais_prueba_tecnica/main.dart';

import 'features/contacts/support/contacts_fixtures.dart';

/// Boots the app with the dice fixed on [roll] and waits out the 800ms call.
Future<void> _pumpApp(WidgetTester tester, {required int roll}) async {
  await tester.runAsync(() async {
    await initDependencies();
    await sl.unregister<DiceRoller>();
    sl.registerSingleton<DiceRoller>(FixedDice(roll));
    await startServices();
  });

  await tester.pumpWidget(const MyApp());
  expect(find.byType(CircularProgressIndicator), findsOneWidget);

  await tester.pump(contactsLatency);
  await tester.pump();
}

void main() {
  tearDown(() => sl.reset());

  testWidgets('a successful call shows the bundled contacts', (tester) async {
    await _pumpApp(tester, roll: 2);

    expect(find.text('Contacts'), findsOneWidget);
    expect(find.byType(ContactsList), findsOneWidget);
    expect(find.byType(ContactListItem), findsWidgets);
    expect(find.text('Camila Reyes'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('a broken connection shows the error with retry', (tester) async {
    await _pumpApp(tester, roll: 1);

    expect(find.textContaining('Check your connection'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    expect(find.text('No contacts found'), findsNothing);
  });

  testWidgets('an empty call shows no contacts, not an error', (tester) async {
    await _pumpApp(tester, roll: 6);

    expect(find.text('No contacts found'), findsOneWidget);
    expect(find.text('Retry'), findsNothing);
  });
}
