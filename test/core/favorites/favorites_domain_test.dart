import 'package:flutter_test/flutter_test.dart';
import 'package:tuclasetupais_prueba_tecnica/core/favorites/domain/repositories/favorites_repository.dart';
import 'package:tuclasetupais_prueba_tecnica/core/favorites/domain/usecases/get_favorite_ids.dart';
import 'package:tuclasetupais_prueba_tecnica/core/favorites/domain/usecases/save_favorite_ids.dart';
import 'package:tuclasetupais_prueba_tecnica/core/favorites/domain/usecases/toggle_favorite.dart';

class _FakeRepository implements FavoritesRepository {
  _FakeRepository([Set<int>? ids]) : stored = ids ?? <int>{};
  Set<int> stored;

  @override
  Future<Set<int>> getIds() async => stored;

  @override
  Future<void> saveIds(Set<int> ids) async => stored = ids;
}

void main() {
  group('ToggleFavorite', () {
    const toggle = ToggleFavorite();

    test('adds a contact that is not a favorite', () {
      expect(toggle({1, 2}, 3), {1, 2, 3});
    });

    test('removes a contact that is a favorite', () {
      expect(toggle({1, 2, 3}, 2), {1, 3});
    });

    test('toggling twice is a no-op', () {
      expect(toggle(toggle({1}, 5), 5), {1});
    });

    test('does not change the set it receives', () {
      final original = {1, 2};
      toggle(original, 3);
      expect(original, {1, 2});
    });
  });

  test('GetFavoriteIds returns what the repository holds', () async {
    expect(await GetFavoriteIds(_FakeRepository({4, 7}))(), {4, 7});
    expect(await GetFavoriteIds(_FakeRepository())(), isEmpty);
  });

  test('SaveFavoriteIds hands the ids to the repository', () async {
    final repository = _FakeRepository();

    await SaveFavoriteIds(repository)({2, 9});

    expect(repository.stored, {2, 9});
  });
}
