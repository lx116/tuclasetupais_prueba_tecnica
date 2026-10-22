import '../../../../core/contacts/domain/entities/contact.dart';
import '../repositories/contact_detail_repository.dart';
import 'contact_not_found_exception.dart';

class GetContactById {
  const GetContactById(this._repository);

  final ContactDetailRepository _repository;

  /// Throws [ContactNotFoundException] when the id does not exist.
  Future<Contact> call(int id) async {
    final contact = await _repository.getContactById(id);
    if (contact == null) throw ContactNotFoundException(id);
    return contact;
  }
}
