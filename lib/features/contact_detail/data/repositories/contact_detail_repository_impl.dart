import '../../../../core/contacts/domain/entities/contact.dart';
import '../../domain/repositories/contact_detail_repository.dart';
import '../datasources/contact_detail_local_datasource.dart';

class ContactDetailRepositoryImpl implements ContactDetailRepository {
  ContactDetailRepositoryImpl(this._datasource);

  final ContactDetailLocalDataSource _datasource;

  @override
  Future<Contact?> getContactById(int id) async {
    final model = await _datasource.getContactById(id);
    return model?.toEntity();
  }
}
