/// The favorite contacts cannot be loaded because the contacts list failed to
/// load. There is no cache, so without the list there is nothing to show.
class FavoritesUnavailableException implements Exception {
  const FavoritesUnavailableException([
    this.message = 'The contacts list failed to load',
  ]);

  final String message;

  @override
  String toString() => 'FavoritesUnavailableException: $message';
}
