import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tuclasetupais_prueba_tecnica/core/contacts/data/service_get_contacts.dart';
import 'package:tuclasetupais_prueba_tecnica/core/di/injection.dart';
import 'package:tuclasetupais_prueba_tecnica/core/router/app_router.dart';
import 'package:tuclasetupais_prueba_tecnica/core/router/not_found_page.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contact_detail/presentation/ui/contact_detail_page.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/data/datasources/dice_roller.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/presentation/ui/contacts_page.dart';

import '../../contacts/support/contacts_fixtures.dart';

class _CountingDice implements DiceRoller {
  _CountingDice(this.value);

  final int value;
  int rolls = 0;

  @override
  int roll() {
    rolls++;
    return value;
  }
}

void main() {
  late _CountingDice dice;
  late ServiceGetContacts service;

  setUp(() async {
    await sl.reset();
    await initDependencies();
    dice = _CountingDice(2);
    service = ServiceGetContacts(
      bundle: FakeAssetBundle({
        'lib/assets/contacs.json': jsonEncode([
          contactJson(id: 1),
          contactJson(
            id: 2,
            overrides: {
              'name': 'Matías Soto',
              'email': 'matias.soto@empresa.cl',
              'active': false,
            },
          ),
        ]),
      }),
      log: (message, {required level, error}) {},
    );
    // Preserve production DI wiring, replacing only IO and randomness.
    await sl.unregister<ServiceGetContacts>();
    sl.registerSingleton<ServiceGetContacts>(service);
    await sl.unregister<DiceRoller>();
    sl.registerSingleton<DiceRoller>(dice);
    await startServices();
  });

  tearDown(() => sl.reset());

  Future<GoRouter> openUrl(WidgetTester tester, String url) async {
    final router = createAppRouter(initialLocation: url);
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    return router;
  }

  testWidgets(
    'a direct contact URL loads that contact without visiting the list',
    (tester) async {
      final router = await openUrl(tester, '/contacts/2');

      expect(router.routeInformationProvider.value.uri.path, '/contacts/2');
      expect(find.byType(ContactDetailPage), findsOneWidget);
      expect(find.byType(ContactsPage), findsNothing);
      expect(find.byType(NotFoundPage), findsNothing);
      expect(find.text('Matías Soto'), findsOneWidget);
      expect(find.text('matias.soto@empresa.cl'), findsOneWidget);
      expect(find.text('Camila Reyes'), findsNothing);
      expect(dice.rolls, 0, reason: 'Detail must not simulate a list request.');
    },
  );

  testWidgets('the URL restores detail after the router is recreated', (
    tester,
  ) async {
    final firstRouter = await openUrl(tester, '/contacts/2');
    final sharedUrl = firstRouter.routeInformationProvider.value.uri.toString();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    // No Contact object or navigation extra is passed to the new router.
    final restoredRouter = await openUrl(tester, sharedUrl);

    expect(
      restoredRouter.routeInformationProvider.value.uri.path,
      '/contacts/2',
    );
    expect(find.byType(ContactDetailPage), findsOneWidget);
    expect(find.text('Matías Soto'), findsOneWidget);
    expect(find.text('matias.soto@empresa.cl'), findsOneWidget);
    expect(dice.rolls, 0);
  });

  for (final url in ['/contacts/999', '/contacts/not-an-id']) {
    testWidgets('$url shows 404 rather than another contact', (tester) async {
      await openUrl(tester, url);

      expect(find.byType(NotFoundPage), findsOneWidget);
      expect(find.text('404'), findsOneWidget);
      expect(find.text('Camila Reyes'), findsNothing);
      expect(find.text('Matías Soto'), findsNothing);
      expect(dice.rolls, 0);
    });
  }

  testWidgets('/contacts remains the list, not a missing-id detail', (
    tester,
  ) async {
    await openUrl(tester, '/contacts');

    expect(find.byType(ContactsPage), findsOneWidget);
    expect(find.byType(ContactDetailPage), findsNothing);
    expect(find.byType(NotFoundPage), findsNothing);
    expect(find.text('Camila Reyes'), findsOneWidget);
    expect(dice.rolls, 1);
  });

  for (final id in [1, 999]) {
    testWidgets(
      'list failure blocks /contacts/$id as a load error, not a 404',
      (tester) async {
        dice = _CountingDice(1);
        await sl.unregister<DiceRoller>();
        sl.registerSingleton<DiceRoller>(dice);
        final router = await openUrl(tester, '/contacts');
        expect(
          find.text(
            'Could not reach the server. Check your connection and try again.',
          ),
          findsOneWidget,
        );
        expect(dice.rolls, 1);
        // Startup data exists, but must not bypass the failed list request.
        expect(service.status, ContactsLoadStatus.loaded);
        expect(service.contacts, hasLength(2));

        router.go('/contacts/$id');
        await tester.pumpAndSettle();

        expect(find.byType(NotFoundPage), findsNothing);
        expect(find.text('404'), findsNothing);
        expect(find.text('Camila Reyes'), findsNothing);
        expect(find.text('Matías Soto'), findsNothing);
        expect(find.textContaining('list failed to load'), findsOneWidget);
        expect(find.text('Back to contacts'), findsOneWidget);
        expect(
          dice.rolls,
          1,
          reason: 'Detail must not retry the list simulation.',
        );
      },
    );
  }
}
