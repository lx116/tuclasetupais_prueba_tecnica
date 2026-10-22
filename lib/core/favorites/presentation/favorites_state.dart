import 'package:flutter/foundation.dart';

/// The contacts marked as favorite. [loaded] is false until the stored
/// favorites were read.
class FavoritesState {
  const FavoritesState({this.ids = const {}, this.loaded = false});

  final Set<int> ids;
  final bool loaded;

  int get count => ids.length;

  bool isFavorite(int contactId) => ids.contains(contactId);

  @override
  bool operator ==(Object other) =>
      other is FavoritesState &&
      other.loaded == loaded &&
      setEquals(other.ids, ids);

  @override
  int get hashCode => Object.hash(loaded, Object.hashAllUnordered(ids));
}
