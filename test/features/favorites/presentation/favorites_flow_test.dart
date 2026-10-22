import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuclasetupais_prueba_tecnica/core/contacts/data/service_get_contacts.dart';
import 'package:tuclasetupais_prueba_tecnica/core/di/injection.dart';
import 'package:tuclasetupais_prueba_tecnica/core/favorites/presentation/favorites_cubit.dart';
import 'package:tuclasetupais_prueba_tecnica/core/router/app_router.dart';
import 'package:tuclasetupais_prueba_tecnica/core/theme/app_theme.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/data/datasources/dice_roller.dart';
import 'package:tuclasetupais_prueba_tecnica/features/favorites/presentation/ui/favorite_card.dart';
import 'package:tuclasetupais_prueba_tecnica/features/favorites/presentation/ui/favorites_page.dart';

import '../../contacts/support/contacts_fixtures.dart';

class _Dice implements DiceRoller {
  _Dice(this.value);
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
  late _Dice dice;

  Future<void> boot({int roll = 2, List<String> stored = const []}) async {
    SharedPreferences.setMockInitialValues({'favorite_contact_ids': stored});
    await sl.reset();
    await initDependencies();
    dice = _Dice(roll);
    final service = ServiceGetContacts(
      bundle: FakeAssetBundle({
        'lib/assets/contacs.json': jsonEncode([
          for (var id = 1; id <= 6; id++)
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
  }

  tearDown(() => sl.reset());

  Future<GoRouter> open(
    WidgetTester tester,
    String location, {
    Size size = _wide,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.reset);
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

  String path(GoRouter router) =>
      router.routeInformationProvider.value.uri.path;

  testWidgets('/favorites is a page of its own, with the saved favorites', (
    tester,
  ) async {
    await boot(stored: ['2', '5']);

    final router = await open(tester, '/favorites');

    expect(path(router), '/favorites');
    expect(find.byType(FavoritesPage), findsOneWidget);
    expect(find.byType(FavoriteCard), findsNWidgets(2));
    expect(find.text('Contacto 2'), findsOneWidget);
    expect(find.text('Contacto 5'), findsOneWidget);
  });

  testWidgets('a direct link does not need the list, so no dice roll', (
    tester,
  ) async {
    await boot(stored: ['1']);

    await open(tester, '/favorites');

    expect(find.byType(FavoriteCard), findsOneWidget);
    expect(dice.rolls, 0);
  });

  testWidgets('a star in the list shows up on the favorites page', (
    tester,
  ) async {
    await boot();
    final router = await open(tester, '/contacts');

    await tester.tap(find.byTooltip('Agregar a favoritos').at(2));
    await tester.pump();
    await tester.tap(find.text('Favoritos'));
    await tester.pumpAndSettle();

    expect(path(router), '/favorites');
    expect(find.byType(FavoriteCard), findsOneWidget);
    expect(find.text('Contacto 3'), findsOneWidget);
  });

  testWidgets('removing from the page updates the shared state', (
    tester,
  ) async {
    await boot(stored: ['4']);
    await open(tester, '/favorites');

    await tester.tap(find.byTooltip('Quitar de favoritos'));
    await tester.pumpAndSettle();

    expect(sl<FavoritesCubit>().state.ids, isEmpty);
    expect(find.text('Todavía no tienes favoritos'), findsOneWidget);
  });

  testWidgets('a card opens its contact in the master-detail layout', (
    tester,
  ) async {
    await boot(stored: ['3']);
    final router = await open(tester, '/favorites');

    await tester.tap(find.text('Contacto 3'));
    await tester.pumpAndSettle();
    await tester.pump(contactsLatency);
    await tester.pumpAndSettle();

    expect(path(router), '/contacts/3');
    expect(find.text('Agregar a favoritos'), findsNothing);
    expect(find.text('En favoritos'), findsOneWidget);
  });

  testWidgets('after a list load error the page shows the load error', (
    tester,
  ) async {
    await boot(roll: 1, stored: ['1']);
    final router = await open(tester, '/contacts');
    expect(find.text('No pudimos cargar los contactos'), findsOneWidget);

    router.go('/favorites');
    await tester.pumpAndSettle();

    expect(find.text('No pudimos cargar los favoritos'), findsOneWidget);
    expect(find.byType(FavoriteCard), findsNothing);
    expect(find.text('Todavía no tienes favoritos'), findsNothing);
  });

  testWidgets('stored ids with no contact are not shown', (tester) async {
    await boot(stored: ['2', '99']);

    await open(tester, '/favorites');

    expect(find.byType(FavoriteCard), findsOneWidget);
  });

  testWidgets('mobile: the star icon in the list header leads to favorites', (
    tester,
  ) async {
    await boot(stored: ['1']);
    final router = await open(tester, '/contacts', size: _mobile);

    await tester.tap(find.byTooltip('Favoritos'));
    await tester.pumpAndSettle();

    expect(path(router), '/favorites');
    expect(find.byType(FavoriteCard), findsOneWidget);
  });
}
