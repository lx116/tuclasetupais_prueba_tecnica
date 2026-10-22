import '../domain/repositories/favorites_repository.dart';
import 'favorites_local_datasource.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  FavoritesRepositoryImpl(this._datasource);

  final FavoritesLocalDataSource _datasource;

  @override
  Future<Set<int>> getIds() => _datasource.read();

  @override
  Future<void> saveIds(Set<int> ids) => _datasource.write(ids);
}
