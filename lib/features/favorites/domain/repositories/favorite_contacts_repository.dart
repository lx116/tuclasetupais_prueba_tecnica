import '../../../../core/contacts/domain/entities/contact.dart';

abstract class FavoriteContactsRepository {
  /// The contacts with those [ids], in list order. Ids with no contact are
  /// left out.
  Future<List<Contact>> getContacts(Set<int> ids);
}
