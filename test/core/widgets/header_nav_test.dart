import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuclasetupais_prueba_tecnica/core/theme/app_colors.dart';
import 'package:tuclasetupais_prueba_tecnica/core/theme/app_theme.dart';
import 'package:tuclasetupais_prueba_tecnica/core/widgets/header_nav.dart';

import '../../support/favorites_fixtures.dart';

Future<void> _pump(
  WidgetTester tester,
  HeaderNav nav, {
  Set<int> favorites = const {},
  List<String>? visited,
}) async {
  final cubit = favoritesCubitFor(InMemoryFavoritesRepository(favorites));
  await cubit.load();
  addTearDown(cubit.close);
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => Scaffold(body: withFavorites(cubit, nav)),
      ),
      GoRoute(
        path: '/contacts',
        builder: (context, state) {
          visited?.add('/contacts');
          return const Text('contacts page');
        },
      ),
      GoRoute(
        path: '/favorites',
        builder: (context, state) {
          visited?.add('/favorites');
          return const Text('favorites page');
        },
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    MaterialApp.router(theme: AppTheme.light, routerConfig: router),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('wide', () {
    testWidgets('shows both sections and the favorites count', (tester) async {
      await _pump(
        tester,
        const HeaderNav(current: HeaderSection.contacts),
        favorites: {1, 2, 3},
      );

      expect(find.text('Contactos'), findsOneWidget);
      expect(find.text('Favoritos'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('hides the badge while there are no favorites', (tester) async {
      await _pump(tester, const HeaderNav(current: HeaderSection.contacts));

      expect(find.text('0'), findsNothing);
    });

    testWidgets('the badge follows the favorites', (tester) async {
      final cubit = favoritesCubitFor(InMemoryFavoritesRepository());
      await cubit.load();
      addTearDown(cubit.close);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: withFavorites(
              cubit,
              const HeaderNav(current: HeaderSection.contacts),
            ),
          ),
        ),
      );
      expect(find.text('1'), findsNothing);

      await cubit.toggle(9);
      await tester.pump();

      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('the current section is the cyan pill', (tester) async {
      await _pump(tester, const HeaderNav(current: HeaderSection.favorites));

      Color? colorOf(String label) => tester
          .widget<Material>(
            find
                .ancestor(of: find.text(label), matching: find.byType(Material))
                .first,
          )
          .color;

      expect(colorOf('Favoritos'), AppColors.strongCyan);
      expect(colorOf('Contactos'), isNot(AppColors.strongCyan));
    });

    testWidgets('the pills navigate', (tester) async {
      final visited = <String>[];
      await _pump(
        tester,
        const HeaderNav(current: HeaderSection.contacts),
        visited: visited,
      );

      await tester.tap(find.text('Favoritos'));
      await tester.pumpAndSettle();

      expect(visited, ['/favorites']);
    });
  });

  group('compact', () {
    testWidgets('on contacts it offers the favorites with the count', (
      tester,
    ) async {
      await _pump(
        tester,
        const HeaderNav(current: HeaderSection.contacts, compact: true),
        favorites: {1, 2},
      );

      expect(find.byTooltip('Favoritos'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('Contactos'), findsNothing);
    });

    testWidgets('on favorites it offers the contacts', (tester) async {
      final visited = <String>[];
      await _pump(
        tester,
        const HeaderNav(current: HeaderSection.favorites, compact: true),
        visited: visited,
      );

      await tester.tap(find.byTooltip('Contactos'));
      await tester.pumpAndSettle();

      expect(visited, ['/contacts']);
    });
  });
}
