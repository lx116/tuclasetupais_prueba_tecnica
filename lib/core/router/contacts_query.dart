/// The search and the department filter of the contacts list, as they travel
/// in the URL: `/contacts?search=ana&department=ingenieria`.
class ContactsQuery {
  const ContactsQuery({this.search = '', this.department = ''});

  factory ContactsQuery.fromUri(Uri uri) => ContactsQuery(
    search: uri.queryParameters[searchParam] ?? '',
    department: uri.queryParameters[departmentParam] ?? '',
  );

  static const String searchParam = 'search';
  static const String departmentParam = 'department';

  final String search;

  /// The department in its URL form (accent-free, lowercase): `ingenieria`.
  final String department;

  bool get isEmpty => search.isEmpty && department.isEmpty;

  /// The query parameters to write, or `null` when there are none.
  Map<String, String>? toParams() {
    if (isEmpty) return null;
    return {
      if (search.isNotEmpty) searchParam: search,
      if (department.isNotEmpty) departmentParam: department,
    };
  }

  ContactsQuery copyWith({String? search, String? department}) => ContactsQuery(
    search: search ?? this.search,
    department: department ?? this.department,
  );

  @override
  bool operator ==(Object other) =>
      other is ContactsQuery &&
      other.search == search &&
      other.department == department;

  @override
  int get hashCode => Object.hash(search, department);
}
