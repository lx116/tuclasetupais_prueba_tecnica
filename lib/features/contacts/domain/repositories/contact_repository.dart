import '../../../../core/contacts/domain/entities/contact.dart';

abstract class ContactRepository {
  Future<List<Contact>> getContacts();
}
