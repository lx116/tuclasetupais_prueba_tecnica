import '../../../../core/contacts/domain/entities/contact.dart';
import '../repositories/favorite_contacts_repository.dart';

class GetFavoriteContacts {
  const GetFavoriteContacts(this._repository);

  final FavoriteContactsRepository _repository;

  /// No favorites means no contacts, so the repository is not asked.
  Future<List<Contact>> call(Set<int> ids) async {
    if (ids.isEmpty) return const [];
    return _repository.getContacts(ids);
  }
}
