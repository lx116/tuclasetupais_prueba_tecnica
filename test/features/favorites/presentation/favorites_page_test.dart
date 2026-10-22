import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tuclasetupais_prueba_tecnica/core/contacts/domain/entities/contact.dart';
import 'package:tuclasetupais_prueba_tecnica/core/di/injection.dart';
import 'package:tuclasetupais_prueba_tecnica/core/theme/app_theme.dart';
import 'package:tuclasetupais_prueba_tecnica/features/favorites/domain/repositories/favorite_contacts_repository.dart';
import 'package:tuclasetupais_prueba_tecnica/features/favorites/domain/repositories/favorites_unavailable_exception.dart';
import 'package:tuclasetupais_prueba_tecnica/features/favorites/domain/usecases/get_favorite_contacts.dart';
import 'package:tuclasetupais_prueba_tecnica/features/favorites/presentation/cubit/favorite_contacts_cubit.dart';
import 'package:tuclasetupais_prueba_tecnica/features/favorites/presentation/ui/favorite_card.dart';
import 'package:tuclasetupais_prueba_tecnica/features/favorites/presentation/ui/favorites_page.dart';

import '../../../support/favorites_fixtures.dart';

Contact _named(int id, {String department = 'Ingeniería'}) => Contact(
  id: id,
  name: 'Contacto $id',
  role: 'QA Lead',
  department: department,
  email: 'x$id@empresa.cl',
  phone: '+56 9 1111 2222',
  active: true,
);

class _FakeRepository implements FavoriteContactsRepository {
  _FakeRepository(this.contacts, {this.error});
  final List<Contact> contacts;
  final Object? error;

  @override
  Future<List<Contact>> getContacts(Set<int> ids) async {
    if (error != null) throw error!;
    return contacts.where((c) => ids.contains(c.id)).toList();
  }
}

Future<InMemoryFavoritesRepository> _pump(
  WidgetTester tester, {
  Set<int> favorites = const {},
  Object? error,
  Size size = const Size(1280, 900),
  List<String>? visited,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);

  final storage = InMemoryFavoritesRepository(favorites);
  final cubit = favoritesCubitFor(storage);
  await cubit.load();
  addTearDown(cubit.close);
  sl.registerFactory<FavoriteContactsCubit>(
    () => FavoriteContactsCubit(
      GetFavoriteContacts(
        _FakeRepository([
          _named(1),
          _named(2, department: 'Diseño'),
          _named(3),
        ], error: error),
      ),
    ),
  );

  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) =>
            withFavorites(cubit, const FavoritesPage()),
      ),
      GoRoute(
        path: '/contacts',
        builder: (context, state) {
          visited?.add(state.uri.toString());
          return const Text('contacts page');
        },
      ),
      GoRoute(
        path: '/contacts/:id',
        builder: (context, state) {
          visited?.add(state.uri.toString());
          return Text('detail ${state.pathParameters['id']}');
        },
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    MaterialApp.router(theme: AppTheme.light, routerConfig: router),
  );
  await tester.pumpAndSettle();
  return storage;
}

void main() {
  tearDown(() => sl.reset());

  testWidgets('shows a card with the name and department per favorite', (
    tester,
  ) async {
    await _pump(tester, favorites: {1, 2});

    expect(find.text('Favoritos'), findsWidgets);
    expect(find.byType(FavoriteCard), findsNWidgets(2));
    expect(find.text('Contacto 1'), findsOneWidget);
    expect(find.text('Contacto 2'), findsOneWidget);
    expect(find.text('Contacto 3'), findsNothing);
    expect(find.text('Diseño'), findsOneWidget);
  });

  testWidgets('explains where the favorites are kept', (tester) async {
    await _pump(tester, favorites: {1});

    expect(
      find.text(
        'Tus contactos marcados con estrella. Se guardan en este dispositivo.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('without favorites it shows the empty state', (tester) async {
    final visited = <String>[];
    await _pump(tester, visited: visited);

    expect(find.text('Todavía no tienes favoritos'), findsOneWidget);
    expect(
      find.text('Toca la estrella de un contacto para guardarlo aquí.'),
      findsOneWidget,
    );
    expect(find.byType(FavoriteCard), findsNothing);

    await tester.tap(find.text('Ver contactos'));
    await tester.pumpAndSettle();

    expect(visited, ['/contacts']);
  });

  testWidgets('every card has a filled star that removes the favorite', (
    tester,
  ) async {
    final storage = await _pump(tester, favorites: {1, 2});
    expect(find.byTooltip('Quitar de favoritos'), findsNWidgets(2));

    await tester.tap(find.byTooltip('Quitar de favoritos').first);
    await tester.pumpAndSettle();

    expect(find.byType(FavoriteCard), findsOneWidget);
    expect(find.text('Contacto 1'), findsNothing);
    expect(storage.stored, {2});
  });

  testWidgets('removing the last favorite shows the empty state', (
    tester,
  ) async {
    await _pump(tester, favorites: {3});

    await tester.tap(find.byTooltip('Quitar de favoritos'));
    await tester.pumpAndSettle();

    expect(find.text('Todavía no tienes favoritos'), findsOneWidget);
  });

  testWidgets('tapping a card opens that contact', (tester) async {
    final visited = <String>[];
    await _pump(tester, favorites: {2}, visited: visited);

    await tester.tap(find.text('Contacto 2'));
    await tester.pumpAndSettle();

    expect(visited, ['/contacts/2']);
  });

  testWidgets('a failed contacts list is a load error with a way back', (
    tester,
  ) async {
    final visited = <String>[];
    await _pump(
      tester,
      favorites: {1},
      error: const FavoritesUnavailableException(),
      visited: visited,
    );

    expect(find.text('No pudimos cargar los favoritos'), findsOneWidget);
    expect(find.textContaining('no se cargó'), findsOneWidget);
    expect(find.text('Todavía no tienes favoritos'), findsNothing);

    await tester.tap(find.text('Volver a contactos'));
    await tester.pumpAndSettle();

    expect(visited, ['/contacts']);
  });

  testWidgets('the header marks Favoritos as the current section', (
    tester,
  ) async {
    await _pump(tester, favorites: {1, 2});

    expect(find.text('Contactos'), findsWidgets);
    expect(find.text('2'), findsOneWidget, reason: 'badge');
  });

  testWidgets('mobile: single column with the contacts icon in the header', (
    tester,
  ) async {
    await _pump(tester, favorites: {1, 2}, size: const Size(390, 844));

    expect(find.byType(FavoriteCard), findsNWidgets(2));
    expect(find.byTooltip('Contactos'), findsOneWidget);
    final first = tester.getTopLeft(find.byType(FavoriteCard).first);
    final second = tester.getTopLeft(find.byType(FavoriteCard).last);
    expect(second.dx, first.dx, reason: 'one column');
  });

  testWidgets('wide: cards sit side by side', (tester) async {
    await _pump(tester, favorites: {1, 2});

    final first = tester.getTopLeft(find.byType(FavoriteCard).first);
    final second = tester.getTopLeft(find.byType(FavoriteCard).last);
    expect(second.dy, first.dy, reason: 'same row');
    expect(second.dx, greaterThan(first.dx));
  });
}
