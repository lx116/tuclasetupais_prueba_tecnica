import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tuclasetupais_prueba_tecnica/core/contacts/data/service_get_contacts.dart';
import 'package:tuclasetupais_prueba_tecnica/core/di/injection.dart';
import 'package:tuclasetupais_prueba_tecnica/core/router/app_router.dart';
import 'package:tuclasetupais_prueba_tecnica/core/theme/app_theme.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contact_detail/presentation/ui/contact_detail_page.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/data/datasources/dice_roller.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/presentation/cubit/contacts_cubit.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/presentation/ui/contact_list_item.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/presentation/ui/contacts_list.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/presentation/ui/contacts_page.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/presentation/ui/detail_placeholder.dart';

import '../support/contacts_fixtures.dart';

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

const _wide = Size(1280, 900);
const _mobile = Size(390, 844);

void main() {
  late _CountingDice dice;

  setUp(() async {
    await sl.reset();
    await initDependencies();
    dice = _CountingDice(2);
    final service = ServiceGetContacts(
      bundle: FakeAssetBundle({
        'lib/assets/contacs.json': jsonEncode([
          for (var id = 1; id <= 18; id++)
            contactJson(id: id, overrides: {'name': 'Contacto $id'}),
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
    required Size size,
  }) async {
    resize(tester, size);
    final router = createAppRouter(initialLocation: location);
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
    await tester.pump(contactsLatency);
    await tester.pumpAndSettle();
    return router;
  }

  Finder inDetail(String text) => find.descendant(
    of: find.byType(ContactDetailPage),
    matching: find.text(text),
  );

  double listOffset(WidgetTester tester) => tester
      .state<ScrollableState>(
        find.descendant(
          of: find.byType(ContactsList),
          matching: find.byType(Scrollable),
        ),
      )
      .position
      .pixels;

  group('layout', () {
    testWidgets('wide: the list and the detail are side by side', (
      tester,
    ) async {
      await open(tester, '/contacts/2', size: _wide);

      expect(find.byType(ContactsPage), findsOneWidget);
      expect(find.byType(ContactDetailPage), findsOneWidget);
      expect(inDetail('Contacto 2'), findsOneWidget);
      expect(find.byType(ContactListItem), findsWidgets);
    });

    testWidgets('wide without a selection shows the placeholder', (
      tester,
    ) async {
      await open(tester, '/contacts', size: _wide);

      expect(find.byType(ContactsPage), findsOneWidget);
      expect(find.byType(DetailPlaceholder), findsOneWidget);
      expect(find.text('Selecciona un contacto'), findsOneWidget);
    });

    testWidgets('mobile at /contacts shows only the list', (tester) async {
      await open(tester, '/contacts', size: _mobile);

      expect(find.byType(ContactsPage), findsOneWidget);
      expect(find.byType(DetailPlaceholder), findsNothing);
      expect(find.text('Selecciona un contacto'), findsNothing);
    });

    testWidgets('mobile at /contacts/:id shows only the detail', (
      tester,
    ) async {
      await open(tester, '/contacts/2', size: _mobile);

      expect(find.byType(ContactDetailPage), findsOneWidget);
      expect(find.byType(ContactsPage), findsNothing);
      expect(dice.rolls, 0, reason: 'The list is not needed on mobile.');
    });

    testWidgets('900px is mobile and 901px is wide', (tester) async {
      await open(tester, '/contacts/2', size: const Size(900, 800));
      expect(find.byType(ContactsPage), findsNothing);

      resize(tester, const Size(901, 800));
      await tester.pumpAndSettle();
      await tester.pump(contactsLatency);
      await tester.pumpAndSettle();

      expect(find.byType(ContactsPage), findsOneWidget);
      expect(find.byType(ContactDetailPage), findsOneWidget);
    });
  });

  group('resizing keeps the content', () {
    testWidgets('the loaded list survives wide -> mobile -> wide', (
      tester,
    ) async {
      await open(tester, '/contacts/2', size: _wide);
      final cubit = tester
          .element(find.byType(ContactsList))
          .read<ContactsCubit>();
      expect(dice.rolls, 1);

      resize(tester, _mobile);
      await tester.pumpAndSettle();
      expect(find.byType(ContactDetailPage), findsOneWidget);
      expect(
        find.byType(ContactsPage, skipOffstage: false),
        findsOneWidget,
        reason: 'The list stays alive while the detail is on screen.',
      );

      resize(tester, _wide);
      await tester.pumpAndSettle();

      expect(find.byType(ContactListItem), findsWidgets);
      expect(
        tester.element(find.byType(ContactsList)).read<ContactsCubit>(),
        same(cubit),
      );
      expect(dice.rolls, 1, reason: 'Resizing must not reload the list.');
    });

    testWidgets('the selected contact (URL) survives the resize', (
      tester,
    ) async {
      final router = await open(tester, '/contacts/5', size: _wide);

      resize(tester, _mobile);
      await tester.pumpAndSettle();

      expect(router.routeInformationProvider.value.uri.path, '/contacts/5');
      expect(inDetail('Contacto 5'), findsOneWidget);

      resize(tester, _wide);
      await tester.pumpAndSettle();

      expect(inDetail('Contacto 5'), findsOneWidget);
    });

    testWidgets('the list scroll position survives the resize', (tester) async {
      await open(tester, '/contacts', size: _mobile);
      await tester.drag(find.byType(ContactsList), const Offset(0, -400));
      await tester.pumpAndSettle();
      final before = listOffset(tester);
      expect(before, greaterThan(0));

      resize(tester, _wide);
      await tester.pumpAndSettle();
      expect(listOffset(tester), before);

      resize(tester, _mobile);
      await tester.pumpAndSettle();
      expect(listOffset(tester), before);
      expect(dice.rolls, 1);
    });

    testWidgets('a list error survives the resize without a new roll', (
      tester,
    ) async {
      dice = _CountingDice(1);
      await sl.unregister<DiceRoller>();
      sl.registerSingleton<DiceRoller>(dice);
      await open(tester, '/contacts', size: _mobile);
      expect(find.text('No pudimos cargar los contactos'), findsOneWidget);

      resize(tester, _wide);
      await tester.pumpAndSettle();

      expect(find.text('No pudimos cargar los contactos'), findsOneWidget);
      expect(dice.rolls, 1);
    });
  });

  group('navigation', () {
    testWidgets('wide: tapping a row changes the detail, not the list', (
      tester,
    ) async {
      final router = await open(tester, '/contacts', size: _wide);

      await tester.tap(find.text('Contacto 3'));
      await tester.pumpAndSettle();

      expect(router.routeInformationProvider.value.uri.path, '/contacts/3');
      expect(inDetail('Contacto 3'), findsOneWidget);
      expect(find.byType(ContactListItem), findsWidgets);
      expect(dice.rolls, 1);
    });

    testWidgets('wide: the open contact is highlighted in the list', (
      tester,
    ) async {
      await open(tester, '/contacts/4', size: _wide);

      final selected = tester
          .widgetList<ContactListItem>(find.byType(ContactListItem))
          .where((item) => item.selected)
          .map((item) => item.contact.id);

      expect(selected, [4]);
    });

    testWidgets('mobile: opening a detail and going back keeps the list', (
      tester,
    ) async {
      final router = await open(tester, '/contacts', size: _mobile);
      await tester.drag(find.byType(ContactsList), const Offset(0, -400));
      await tester.pumpAndSettle();
      final before = listOffset(tester);

      await tester.tap(find.text('Contacto 8'));
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, '/contacts/8');
      expect(find.byType(ContactDetailPage), findsOneWidget);
      expect(find.byType(ContactsPage), findsNothing);

      await tester.tap(find.byTooltip('Volver a contactos'));
      await tester.pumpAndSettle();

      expect(router.routeInformationProvider.value.uri.path, '/contacts');
      expect(find.byType(ContactsPage), findsOneWidget);
      expect(listOffset(tester), before);
      expect(dice.rolls, 1);
    });

    testWidgets('mobile: back from a deep-linked detail goes to the list', (
      tester,
    ) async {
      final router = await open(tester, '/contacts/2', size: _mobile);

      await tester.tap(find.byTooltip('Volver a contactos'));
      await tester.pumpAndSettle();
      await tester.pump(contactsLatency);
      await tester.pumpAndSettle();

      expect(router.routeInformationProvider.value.uri.path, '/contacts');
      expect(find.byType(ContactsPage), findsOneWidget);
      expect(find.byType(ContactListItem), findsWidgets);
    });
  });
}
