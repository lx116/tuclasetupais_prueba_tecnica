import 'package:flutter_test/flutter_test.dart';
import 'package:tuclasetupais_prueba_tecnica/core/favorites/domain/repositories/favorites_repository.dart';
import 'package:tuclasetupais_prueba_tecnica/core/favorites/domain/usecases/get_favorite_ids.dart';
import 'package:tuclasetupais_prueba_tecnica/core/favorites/domain/usecases/save_favorite_ids.dart';
import 'package:tuclasetupais_prueba_tecnica/core/favorites/domain/usecases/toggle_favorite.dart';
import 'package:tuclasetupais_prueba_tecnica/core/favorites/presentation/favorites_cubit.dart';
import 'package:tuclasetupais_prueba_tecnica/core/favorites/presentation/favorites_state.dart';

class _FakeRepository implements FavoritesRepository {
  _FakeRepository({
    Set<int>? stored,
    this.failReading = false,
    this.failSaving = false,
  }) : stored = stored ?? <int>{};

  Set<int> stored;
  final bool failReading;
  final bool failSaving;
  int saves = 0;

  @override
  Future<Set<int>> getIds() async {
    if (failReading) throw StateError('storage unavailable');
    return stored;
  }

  @override
  Future<void> saveIds(Set<int> ids) async {
    if (failSaving) throw StateError('storage unavailable');
    saves++;
    stored = ids;
  }
}

FavoritesCubit _cubit(_FakeRepository repository) => FavoritesCubit(
  GetFavoriteIds(repository),
  const ToggleFavorite(),
  SaveFavoriteIds(repository),
  log: (message, {error}) {},
);

void main() {
  test('starts with no favorites, not loaded', () {
    final cubit = _cubit(_FakeRepository());

    expect(cubit.state, const FavoritesState());
    expect(cubit.state.loaded, isFalse);
  });

  test('load brings the stored favorites', () async {
    final cubit = _cubit(_FakeRepository(stored: {2, 5}));

    await cubit.load();

    expect(cubit.state, const FavoritesState(ids: {2, 5}, loaded: true));
    expect(cubit.state.isFavorite(5), isTrue);
    expect(cubit.state.isFavorite(1), isFalse);
    expect(cubit.state.count, 2);
  });

  test('a storage failure on load starts with no favorites and logs', () async {
    final logs = <String>[];
    final cubit = FavoritesCubit(
      GetFavoriteIds(_FakeRepository(failReading: true)),
      const ToggleFavorite(),
      SaveFavoriteIds(_FakeRepository()),
      log: (message, {error}) => logs.add(message),
    );

    await cubit.load();

    expect(cubit.state, const FavoritesState(loaded: true));
    expect(logs, hasLength(1));
  });

  test('toggle adds and removes, persisting each change', () async {
    final repository = _FakeRepository();
    final cubit = _cubit(repository);
    await cubit.load();

    await cubit.toggle(4);
    expect(cubit.state.ids, {4});
    expect(repository.stored, {4});

    await cubit.toggle(4);
    expect(cubit.state.ids, isEmpty);
    expect(repository.stored, isEmpty);
  });

  test('toggle updates the state right away, before saving', () async {
    final cubit = _cubit(_FakeRepository());
    await cubit.load();

    final pending = cubit.toggle(3);

    expect(cubit.state.isFavorite(3), isTrue);
    await pending;
  });

  test('a failed save puts the previous favorites back and logs', () async {
    final logs = <String>[];
    final cubit = FavoritesCubit(
      GetFavoriteIds(_FakeRepository(stored: {1})),
      const ToggleFavorite(),
      SaveFavoriteIds(_FakeRepository(failSaving: true)),
      log: (message, {error}) => logs.add(message),
    );
    await cubit.load();

    await cubit.toggle(2);

    expect(cubit.state.ids, {1});
    expect(logs, hasLength(1));
  });

  test('quick toggles of different contacts all stick', () async {
    final repository = _FakeRepository();
    final cubit = _cubit(repository);
    await cubit.load();

    await Future.wait([cubit.toggle(1), cubit.toggle(2), cubit.toggle(3)]);

    expect(cubit.state.ids, {1, 2, 3});
    expect(repository.stored, {1, 2, 3});
  });

  test('state compares by value and is not editable from outside', () {
    expect(const FavoritesState(ids: {1}), const FavoritesState(ids: {1}));
    expect(
      const FavoritesState(ids: {1}),
      isNot(const FavoritesState(ids: {2})),
    );
    expect(
      () => const FavoritesState(ids: {1}).ids.add(2),
      throwsUnsupportedError,
    );
  });
}
