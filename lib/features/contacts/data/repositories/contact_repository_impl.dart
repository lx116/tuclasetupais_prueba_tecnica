import '../../domain/entities/contact.dart';
import '../../domain/repositories/contact_repository.dart';
import '../datasources/contacts_local_datasource.dart';

class ContactRepositoryImpl implements ContactRepository {
  ContactRepositoryImpl(this._datasource);

  final ContactsLocalDataSource _datasource;

  @override
  Future<List<Contact>> getContacts() async {
    final models = await _datasource.getContacts();
    return models.map((model) => model.toEntity()).toList();
  }
}
