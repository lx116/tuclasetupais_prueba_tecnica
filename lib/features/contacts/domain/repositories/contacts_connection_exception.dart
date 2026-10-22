/// The contacts source could not be reached. Different from an empty list:
/// there is no data to show because the call failed.
class ContactsConnectionException implements Exception {
  const ContactsConnectionException([
    this.message = 'The connection to the contacts service was lost',
  ]);

  final String message;

  @override
  String toString() => 'ContactsConnectionException: $message';
}
