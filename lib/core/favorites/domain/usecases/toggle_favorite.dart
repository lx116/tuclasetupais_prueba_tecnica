/// Business rule of the star: tapping it adds a contact that is not a
/// favorite and removes one that is. Returns a new set; [favorites] is left
/// untouched.
class ToggleFavorite {
  const ToggleFavorite();

  Set<int> call(Set<int> favorites, int contactId) {
    final next = {...favorites};
    if (!next.remove(contactId)) next.add(contactId);
    return next;
  }
}
