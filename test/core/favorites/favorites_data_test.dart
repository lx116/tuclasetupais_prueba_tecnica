import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuclasetupais_prueba_tecnica/core/favorites/data/favorites_local_datasource.dart';
import 'package:tuclasetupais_prueba_tecnica/core/favorites/data/favorites_repository_impl.dart';

FavoritesLocalDataSource _datasource() =>
    FavoritesLocalDataSource(SharedPreferences.getInstance);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('starts with no favorites', () async {
    expect(await _datasource().read(), isEmpty);
  });

  test('what is written is read back', () async {
    final datasource = _datasource();

    await datasource.write({3, 1, 2});

    expect(await datasource.read(), {1, 2, 3});
  });

  test('survives a new datasource, as after a restart', () async {
    await _datasource().write({5, 8});

    expect(await _datasource().read(), {5, 8});
  });

  test('writing an empty set clears the favorites', () async {
    final datasource = _datasource();
    await datasource.write({1});

    await datasource.write({});

    expect(await datasource.read(), isEmpty);
  });

  test('ignores stored values that are not ids', () async {
    SharedPreferences.setMockInitialValues({
      'favorite_contact_ids': ['4', 'abc', '', '7'],
    });

    expect(await _datasource().read(), {4, 7});
  });

  test('the repository reads and saves through the datasource', () async {
    final repository = FavoritesRepositoryImpl(_datasource());

    await repository.saveIds({6, 2});

    expect(await repository.getIds(), {2, 6});
  });
}
