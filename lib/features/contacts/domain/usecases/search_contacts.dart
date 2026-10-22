import '../../../../core/contacts/domain/entities/contact.dart';
import '../../../../core/utils/text_folding.dart';

/// Business rule of the search: a contact matches when its name contains the
/// query, ignoring case, accents and surrounding spaces. A blank query matches
/// every contact. The order of [contacts] is kept.
class SearchContacts {
  const SearchContacts();

  List<Contact> call(List<Contact> contacts, String query) {
    final needle = foldText(query.trim());
    if (needle.isEmpty) return contacts;
    return contacts
        .where((contact) => foldText(contact.name).contains(needle))
        .toList();
  }
}
