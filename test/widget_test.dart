import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:tuclasetupais_prueba_tecnica/core/di/injection.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/data/datasources/dice_roller.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/presentation/ui/contact_list_item.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/presentation/ui/contacts_list.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/presentation/ui/contacts_skeleton.dart';
import 'package:tuclasetupais_prueba_tecnica/main.dart';

import 'features/contacts/support/contacts_fixtures.dart';

/// Boots the app with the dice fixed on [roll] and waits out the 800ms call.
Future<void> _pumpApp(
  WidgetTester tester, {
  required int roll,
  String location = '/contacts',
}) async {
  await tester.runAsync(() async {
    await initDependencies();
    await sl.unregister<DiceRoller>();
    sl.registerSingleton<DiceRoller>(FixedDice(roll));
    await startServices();
  });

  await tester.pumpWidget(MyApp(initialLocation: location));
  await tester.pump();
}

/// Boots on the list and waits out the simulated 800ms call.
Future<void> _pumpList(WidgetTester tester, {required int roll}) async {
  await _pumpApp(tester, roll: roll);
  expect(find.byType(ContactsSkeleton), findsOneWidget);
  await tester.pump(contactsLatency);
  await tester.pump();
}

void main() {
  tearDown(() => sl.reset());

  testWidgets('a successful call shows the bundled contacts', (tester) async {
    await _pumpList(tester, roll: 2);

    expect(find.text('Contactos'), findsOneWidget);
    expect(find.byType(ContactsList), findsOneWidget);
    expect(find.byType(ContactListItem), findsWidgets);
    expect(find.text('Camila Reyes'), findsOneWidget);
    expect(find.byType(ContactsSkeleton), findsNothing);
  });

  testWidgets('a broken connection shows the error with retry', (tester) async {
    await _pumpList(tester, roll: 1);

    expect(find.textContaining('Revisa tu conexión'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
    expect(find.text('Aún no hay contactos'), findsNothing);
  });

  testWidgets('an empty call shows no contacts, not an error', (tester) async {
    await _pumpList(tester, roll: 6);

    expect(find.text('Aún no hay contactos'), findsOneWidget);
    expect(find.text('Recargar'), findsOneWidget);
    expect(find.text('Reintentar'), findsNothing);
  });

  group('contact detail by URL', () {
    testWidgets('a shared link loads the contact straight away', (
      tester,
    ) async {
      await _pumpApp(tester, roll: 1, location: '/contacts/2');

      expect(find.text('matias.soto@empresa.cl'), findsOneWidget);
      expect(find.byType(ContactsSkeleton), findsNothing);
    });

    testWidgets('an id that does not exist shows the 404 page', (tester) async {
      await _pumpApp(tester, roll: 2, location: '/contacts/999');

      expect(find.text('404'), findsOneWidget);
      expect(find.text('Contacto no encontrado'), findsOneWidget);
    });

    testWidgets('tapping a contact in the list opens its detail', (
      tester,
    ) async {
      await _pumpList(tester, roll: 2);

      await tester.tap(find.text('Matías Soto'));
      await tester.pumpAndSettle();

      expect(find.text('matias.soto@empresa.cl'), findsOneWidget);
    });

    testWidgets('after a list load error the detail cannot be opened', (
      tester,
    ) async {
      await _pumpList(tester, roll: 1);
      expect(find.textContaining('Revisa tu conexión'), findsOneWidget);

      GoRouter.of(tester.element(find.text('Reintentar'))).go('/contacts/2');
      await tester.pumpAndSettle();

      expect(find.textContaining('no se cargó'), findsOneWidget);
      expect(find.text('matias.soto@empresa.cl'), findsNothing);
      expect(find.text('404'), findsNothing);
    });
  });
}
