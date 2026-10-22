/// The contact cannot be loaded because the contacts list failed to load.
/// There is no cache, so without the list there is no detail data.
class ContactDetailUnavailableException implements Exception {
  const ContactDetailUnavailableException([
    this.message = 'The contacts list failed to load',
  ]);

  final String message;

  @override
  String toString() => 'ContactDetailUnavailableException: $message';
}
