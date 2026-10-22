import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tuclasetupais_prueba_tecnica/core/contacts/data/service_get_contacts.dart';
import 'package:tuclasetupais_prueba_tecnica/core/di/injection.dart';
import 'package:tuclasetupais_prueba_tecnica/core/router/app_router.dart';
import 'package:tuclasetupais_prueba_tecnica/core/theme/app_theme.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contact_detail/presentation/ui/contact_detail_page.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/data/datasources/dice_roller.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/presentation/ui/contact_list_item.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/presentation/ui/contacts_page.dart';

import '../support/contacts_fixtures.dart';

class _CountingDice implements DiceRoller {
  int rolls = 0;

  @override
  int roll() {
    rolls++;
    return 2;
  }
}

const _wide = Size(1280, 900);
const _mobile = Size(390, 844);
const _names = [
  'Ana Pérez',
  'Adriana Muñoz',
  'Matías Soto',
  'Juana López',
  'Bruno Díaz',
];

void main() {
  late _CountingDice dice;

  setUp(() async {
    await sl.reset();
    await initDependencies();
    dice = _CountingDice();
    final service = ServiceGetContacts(
      bundle: FakeAssetBundle({
        'lib/assets/contacs.json': jsonEncode([
          for (var i = 0; i < _names.length; i++)
            contactJson(id: i + 1, overrides: {'name': _names[i]}),
        ]),
      }),
      log: (message, {required level, error}) {},
    );
    await sl.unregister<ServiceGetContacts>();
    sl.registerSingleton<ServiceGetContacts>(service);
    await sl.unregister<DiceRoller>();
    sl.registerSingleton<DiceRoller>(dice);
    await startServices();
  });

  tearDown(() => sl.reset());

  void resize(WidgetTester tester, Size size) {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.reset);
  }

  Future<GoRouter> open(
    WidgetTester tester,
    String location, {
    Size size = _wide,
  }) async {
    resize(tester, size);
    final router = createAppRouter(initialLocation: location);
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
    await tester.pumpAndSettle();
    await tester.pump(contactsLatency);
    await tester.pumpAndSettle();
    return router;
  }

  Future<void> typeSearch(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextField), text);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
  }

  Uri uriOf(GoRouter router) => router.routeInformationProvider.value.uri;

  List<String> shownNames(WidgetTester tester) => tester
      .widgetList<ContactListItem>(find.byType(ContactListItem))
      .map((item) => item.contact.name)
      .toList();

  String inputText(WidgetTester tester) =>
      tester.widget<TextField>(find.byType(TextField)).controller!.text;

  testWidgets('typing filters the list live and writes ?search= to the URL', (
    tester,
  ) async {
    final router = await open(tester, '/contacts');
    expect(shownNames(tester), _names);

    await typeSearch(tester, 'ana');

    expect(uriOf(router).path, '/contacts');
    expect(uriOf(router).queryParameters, {'search': 'ana'});
    expect(shownNames(tester), ['Ana Pérez', 'Adriana Muñoz', 'Juana López']);
    expect(
      find.textContaining('3 resultados para “ana”', findRichText: true),
      findsOneWidget,
    );
    expect(dice.rolls, 1, reason: 'Searching must not call the list again.');
  });

  testWidgets('the results update after a pause, not on every key', (
    tester,
  ) async {
    final router = await open(tester, '/contacts');

    await tester.enterText(find.byType(TextField), 'bru');
    await tester.pump(const Duration(milliseconds: 100));

    expect(uriOf(router).queryParameters, isEmpty);
    expect(shownNames(tester), _names);

    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpAndSettle();

    expect(shownNames(tester), ['Bruno Díaz']);
  });

  testWidgets('clearing the text removes the param and shows everyone', (
    tester,
  ) async {
    final router = await open(tester, '/contacts?search=ana');
    expect(shownNames(tester), hasLength(3));

    await tester.tap(find.byTooltip('Limpiar búsqueda'));
    await tester.pumpAndSettle();

    expect(uriOf(router).queryParameters, isEmpty);
    expect(uriOf(router).toString(), '/contacts');
    expect(shownNames(tester), _names);
    expect(inputText(tester), '');
  });

  testWidgets('a shared link with ?search= fills the input and filters', (
    tester,
  ) async {
    await open(tester, '/contacts?search=ana');

    expect(inputText(tester), 'ana');
    expect(shownNames(tester), ['Ana Pérez', 'Adriana Muñoz', 'Juana López']);
    expect(dice.rolls, 1);
  });

  testWidgets('spaces and accents survive the round trip through the URL', (
    tester,
  ) async {
    final router = await open(tester, '/contacts');

    await typeSearch(tester, 'ana pé');
    final link = uriOf(router).toString();

    expect(link, startsWith('/contacts?search='));
    expect(shownNames(tester), ['Ana Pérez']);

    final opened = await open(tester, link);
    expect(uriOf(opened).queryParameters['search'], 'ana pé');
    expect(inputText(tester), 'ana pé');
    expect(shownNames(tester), ['Ana Pérez']);
  });

  testWidgets('ignores case and accents', (tester) async {
    await open(tester, '/contacts');

    await typeSearch(tester, 'MATIAS');
    expect(shownNames(tester), ['Matías Soto']);

    await typeSearch(tester, 'munoz');
    expect(shownNames(tester), ['Adriana Muñoz']);
  });

  testWidgets('no match shows the no-results state with a clear button', (
    tester,
  ) async {
    final router = await open(tester, '/contacts');

    await typeSearch(tester, 'zzz');

    expect(find.text('Sin resultados para “zzz”'), findsOneWidget);
    expect(find.byType(ContactListItem), findsNothing);
    expect(find.text('Aún no hay contactos'), findsNothing);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Limpiar búsqueda'));
    await tester.pumpAndSettle();

    expect(uriOf(router).queryParameters, isEmpty);
    expect(shownNames(tester), _names);
    expect(inputText(tester), '');
  });

  testWidgets('a URL change from outside updates the input and the list', (
    tester,
  ) async {
    final router = await open(tester, '/contacts?search=ana');

    router.go('/contacts?search=bruno');
    await tester.pumpAndSettle();

    expect(inputText(tester), 'bruno');
    expect(shownNames(tester), ['Bruno Díaz']);
  });

  testWidgets('wide: opening a contact keeps the search in the URL', (
    tester,
  ) async {
    final router = await open(tester, '/contacts?search=ana');

    await tester.tap(find.text('Juana López'));
    await tester.pumpAndSettle();

    expect(uriOf(router).path, '/contacts/4');
    expect(uriOf(router).queryParameters, {'search': 'ana'});
    expect(shownNames(tester), ['Ana Pérez', 'Adriana Muñoz', 'Juana López']);
    expect(
      find.descendant(
        of: find.byType(ContactDetailPage),
        matching: find.text('Juana López'),
      ),
      findsOneWidget,
    );
    expect(dice.rolls, 1);
  });

  testWidgets('wide: searching with a contact open keeps that contact', (
    tester,
  ) async {
    final router = await open(tester, '/contacts/3');

    await typeSearch(tester, 'ana');

    expect(uriOf(router).path, '/contacts/3');
    expect(uriOf(router).queryParameters, {'search': 'ana'});
    expect(
      find.descendant(
        of: find.byType(ContactDetailPage),
        matching: find.text('Matías Soto'),
      ),
      findsOneWidget,
      reason: 'The open contact stays even if the search hides it.',
    );
    expect(shownNames(tester), ['Ana Pérez', 'Adriana Muñoz', 'Juana López']);
  });

  testWidgets('mobile: going back from a contact keeps the search', (
    tester,
  ) async {
    final router = await open(tester, '/contacts?search=ana', size: _mobile);

    await tester.tap(find.text('Juana López'));
    await tester.pumpAndSettle();
    expect(uriOf(router).queryParameters, {'search': 'ana'});

    await tester.tap(find.byTooltip('Volver a contactos'));
    await tester.pumpAndSettle();

    expect(uriOf(router).toString(), '/contacts?search=ana');
    expect(inputText(tester), 'ana');
    expect(shownNames(tester), hasLength(3));
  });

  testWidgets('mobile: back from a deep-linked contact keeps the search', (
    tester,
  ) async {
    final router = await open(tester, '/contacts/4?search=ana', size: _mobile);

    await tester.tap(find.byTooltip('Volver a contactos'));
    await tester.pumpAndSettle();
    await tester.pump(contactsLatency);
    await tester.pumpAndSettle();

    expect(uriOf(router).toString(), '/contacts?search=ana');
    expect(shownNames(tester), hasLength(3));
  });

  testWidgets('resizing keeps the search, the results and no new call', (
    tester,
  ) async {
    await open(tester, '/contacts');
    await typeSearch(tester, 'ana');

    resize(tester, _mobile);
    await tester.pumpAndSettle();
    expect(inputText(tester), 'ana');
    expect(shownNames(tester), hasLength(3));

    resize(tester, _wide);
    await tester.pumpAndSettle();
    expect(inputText(tester), 'ana');
    expect(shownNames(tester), hasLength(3));
    expect(dice.rolls, 1);
  });

  testWidgets('the search field has its placeholder', (tester) async {
    await open(tester, '/contacts');

    expect(find.text('Buscar contactos'), findsOneWidget);
    expect(find.byType(ContactsPage), findsOneWidget);
  });
}
