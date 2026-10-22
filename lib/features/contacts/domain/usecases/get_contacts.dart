import '../entities/contact.dart';
import '../repositories/contact_repository.dart';

class GetContacts {
  const GetContacts(this._repository);

  final ContactRepository _repository;

  Future<List<Contact>> call() => _repository.getContacts();
}
