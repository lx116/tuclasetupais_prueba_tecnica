import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:tuclasetupais_prueba_tecnica/core/favorites/domain/repositories/favorites_repository.dart';
import 'package:tuclasetupais_prueba_tecnica/core/favorites/domain/usecases/get_favorite_ids.dart';
import 'package:tuclasetupais_prueba_tecnica/core/favorites/domain/usecases/save_favorite_ids.dart';
import 'package:tuclasetupais_prueba_tecnica/core/favorites/domain/usecases/toggle_favorite.dart';
import 'package:tuclasetupais_prueba_tecnica/core/favorites/presentation/favorites_cubit.dart';

/// Keeps the favorites in memory.
class InMemoryFavoritesRepository implements FavoritesRepository {
  InMemoryFavoritesRepository([Set<int>? ids]) : stored = {...?ids};

  Set<int> stored;

  @override
  Future<Set<int>> getIds() async => {...stored};

  @override
  Future<void> saveIds(Set<int> ids) async => stored = {...ids};
}

FavoritesCubit favoritesCubitFor(InMemoryFavoritesRepository repository) =>
    FavoritesCubit(
      GetFavoriteIds(repository),
      const ToggleFavorite(),
      SaveFavoriteIds(repository),
      log: (message, {error}) {},
    );

/// Provides [cubit] above [child], as the router does in the app.
Widget withFavorites(FavoritesCubit cubit, Widget child) =>
    BlocProvider<FavoritesCubit>.value(value: cubit, child: child);
