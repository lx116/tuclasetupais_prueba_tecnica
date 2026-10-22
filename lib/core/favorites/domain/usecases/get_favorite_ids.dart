import '../repositories/favorites_repository.dart';

class GetFavoriteIds {
  const GetFavoriteIds(this._repository);

  final FavoritesRepository _repository;

  Future<Set<int>> call() => _repository.getIds();
}
