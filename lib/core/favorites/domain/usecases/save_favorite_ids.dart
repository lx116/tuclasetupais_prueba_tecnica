import '../repositories/favorites_repository.dart';

class SaveFavoriteIds {
  const SaveFavoriteIds(this._repository);

  final FavoritesRepository _repository;

  Future<void> call(Set<int> ids) => _repository.saveIds(ids);
}
