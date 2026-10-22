class AppRoutes {
  const AppRoutes._();

  static const String contacts = '/contacts';

  /// Child segment of [contacts]: the full route is `/contacts/:id`.
  static const String contactDetailSegment = ':id';

  static String contactDetail(int id) => '$contacts/$id';
}
