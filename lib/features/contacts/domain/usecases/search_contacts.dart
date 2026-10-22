import '../../../../core/contacts/domain/entities/contact.dart';

/// Business rule of the search: a contact matches when its name contains the
/// query, ignoring case, accents and surrounding spaces. A blank query matches
/// every contact. The order of [contacts] is kept.
class SearchContacts {
  const SearchContacts();

  static final RegExp _accented = RegExp(r'[áàäâãéèëêíìïîóòöôõúùüûñç]');

  static const Map<String, String> _plain = {
    'á': 'a', 'à': 'a', 'ä': 'a', 'â': 'a', 'ã': 'a', //
    'é': 'e', 'è': 'e', 'ë': 'e', 'ê': 'e', //
    'í': 'i', 'ì': 'i', 'ï': 'i', 'î': 'i', //
    'ó': 'o', 'ò': 'o', 'ö': 'o', 'ô': 'o', 'õ': 'o', //
    'ú': 'u', 'ù': 'u', 'ü': 'u', 'û': 'u', //
    'ñ': 'n', 'ç': 'c',
  };

  List<Contact> call(List<Contact> contacts, String query) {
    final needle = _fold(query.trim());
    if (needle.isEmpty) return contacts;
    return contacts
        .where((contact) => _fold(contact.name).contains(needle))
        .toList();
  }

  static String _fold(String value) => value.toLowerCase().replaceAllMapped(
    _accented,
    (match) => _plain[match.group(0)]!,
  );
}
