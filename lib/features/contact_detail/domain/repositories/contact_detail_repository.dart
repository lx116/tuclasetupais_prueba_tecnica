import '../../../../core/contacts/domain/entities/contact.dart';

abstract class ContactDetailRepository {
  /// The contact with [id], or `null` when it does not exist.
  Future<Contact?> getContactById(int id);
}
