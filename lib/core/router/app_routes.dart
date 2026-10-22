import 'contacts_query.dart';

class AppRoutes {
  const AppRoutes._();

  static const String contacts = '/contacts';

  /// Child segment of [contacts]: the full route is `/contacts/:id`.
  static const String contactDetailSegment = ':id';

  /// The list, carrying the search and the filter when there are any.
  static String contactsLocation({
    ContactsQuery query = const ContactsQuery(),
  }) => _withQuery(contacts, query);

  /// A contact, carrying the search and the filter when there are any.
  static String contactDetail(
    int id, {
    ContactsQuery query = const ContactsQuery(),
  }) => _withQuery('$contacts/$id', query);

  static String _withQuery(String path, ContactsQuery query) =>
      Uri(path: path, queryParameters: query.toParams()).toString();
}
