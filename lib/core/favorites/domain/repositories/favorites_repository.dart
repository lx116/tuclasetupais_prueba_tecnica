abstract class FavoritesRepository {
  /// The ids of the contacts marked as favorite, as last saved.
  Future<Set<int>> getIds();

  Future<void> saveIds(Set<int> ids);
}
