import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuclasetupais_prueba_tecnica/core/favorites/presentation/favorite_button.dart';
import 'package:tuclasetupais_prueba_tecnica/core/theme/app_colors.dart';
import 'package:tuclasetupais_prueba_tecnica/core/theme/app_theme.dart';

import '../../support/favorites_fixtures.dart';

Future<InMemoryFavoritesRepository> _pump(
  WidgetTester tester,
  Widget button, {
  Set<int> favorites = const {},
}) async {
  final repository = InMemoryFavoritesRepository(favorites);
  final cubit = favoritesCubitFor(repository);
  await cubit.load();
  addTearDown(cubit.close);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: withFavorites(cubit, button)),
    ),
  );
  return repository;
}

void main() {
  group('FavoriteButton', () {
    testWidgets('offers to add a contact that is not a favorite', (
      tester,
    ) async {
      await _pump(tester, const FavoriteButton(contactId: 3));

      expect(find.byTooltip('Agregar a favoritos'), findsOneWidget);
      expect(find.byIcon(Icons.star_border), findsOneWidget);
      expect(find.byIcon(Icons.star), findsNothing);
    });

    testWidgets('offers to remove a contact that is a favorite', (
      tester,
    ) async {
      await _pump(tester, const FavoriteButton(contactId: 3), favorites: {3});

      expect(find.byTooltip('Quitar de favoritos'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('tapping toggles it, updates the star and saves', (
      tester,
    ) async {
      final repository = await _pump(
        tester,
        const FavoriteButton(contactId: 3),
      );

      await tester.tap(find.byTooltip('Agregar a favoritos'));
      await tester.pump();

      expect(find.byTooltip('Quitar de favoritos'), findsOneWidget);
      expect(repository.stored, {3});

      await tester.tap(find.byTooltip('Quitar de favoritos'));
      await tester.pump();

      expect(find.byTooltip('Agregar a favoritos'), findsOneWidget);
      expect(repository.stored, isEmpty);
    });

    testWidgets('only reacts to its own contact', (tester) async {
      await _pump(
        tester,
        const Column(
          children: [
            FavoriteButton(contactId: 1),
            FavoriteButton(contactId: 2),
          ],
        ),
      );

      await tester.tap(find.byTooltip('Agregar a favoritos').first);
      await tester.pump();

      expect(find.byTooltip('Quitar de favoritos'), findsOneWidget);
      expect(find.byTooltip('Agregar a favoritos'), findsOneWidget);
    });
  });

  group('FavoritePillButton', () {
    testWidgets('says "Agregar a favoritos" and flips to "En favoritos"', (
      tester,
    ) async {
      final repository = await _pump(
        tester,
        const FavoritePillButton(contactId: 4),
      );
      expect(find.text('Agregar a favoritos'), findsOneWidget);

      await tester.tap(find.text('Agregar a favoritos'));
      await tester.pump();

      expect(find.text('En favoritos'), findsOneWidget);
      expect(repository.stored, {4});
    });

    testWidgets('is cyan when the contact is a favorite', (tester) async {
      await _pump(
        tester,
        const FavoritePillButton(contactId: 4),
        favorites: {4},
      );

      final material = tester.widget<Material>(
        find
            .descendant(
              of: find.byType(FavoritePillButton),
              matching: find.byType(Material),
            )
            .first,
      );
      expect(material.color, AppColors.strongCyan);
    });
  });
}
