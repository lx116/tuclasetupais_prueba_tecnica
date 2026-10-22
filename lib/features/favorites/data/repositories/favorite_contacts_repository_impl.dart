import '../../../../core/contacts/domain/entities/contact.dart';
import '../../domain/repositories/favorite_contacts_repository.dart';
import '../datasources/favorite_contacts_local_datasource.dart';

class FavoriteContactsRepositoryImpl implements FavoriteContactsRepository {
  FavoriteContactsRepositoryImpl(this._datasource);

  final FavoriteContactsLocalDataSource _datasource;

  @override
  Future<List<Contact>> getContacts(Set<int> ids) async {
    final models = await _datasource.getByIds(ids);
    return models.map((model) => model.toEntity()).toList();
  }
}
