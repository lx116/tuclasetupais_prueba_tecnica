class ContactNotFoundException implements Exception {
  const ContactNotFoundException(this.id);

  final int id;

  @override
  String toString() => 'ContactNotFoundException: no contact with id $id';
}
