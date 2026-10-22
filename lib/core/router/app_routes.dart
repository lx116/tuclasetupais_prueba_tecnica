class AppRoutes {
  const AppRoutes._();

  static const String contacts = '/contacts';

  /// Child segment of [contacts]: the full route is `/contacts/:id`.
  static const String contactDetailSegment = ':id';

  /// Query parameter with the search text: `/contacts?search=ana`.
  static const String searchParam = 'search';

  /// The list, carrying [search] in the URL when it is not empty.
  static String contactsLocation({String search = ''}) =>
      _withSearch(contacts, search);

  /// A contact, carrying [search] in the URL when it is not empty.
  static String contactDetail(int id, {String search = ''}) =>
      _withSearch('$contacts/$id', search);

  static String _withSearch(String path, String search) => search.isEmpty
      ? path
      : Uri(path: path, queryParameters: {searchParam: search}).toString();
}
