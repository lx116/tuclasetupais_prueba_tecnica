class AppRoutes {
  const AppRoutes._();

  static const String contacts = '/contacts';

  /// Route pattern for go_router: `/contacts/:id`.
  static const String contactDetailPattern = '$contacts/:id';

  static String contactDetail(int id) => '$contacts/$id';
}
