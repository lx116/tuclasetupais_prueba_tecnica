import '../../../../core/contacts/data/contacts_availability.dart';
import '../../../../core/contacts/data/models/contact_model.dart';
import '../../../../core/contacts/data/service_get_contacts.dart';
import '../../domain/repositories/favorites_unavailable_exception.dart';

/// Reads the favorite contacts from the in-memory data. No simulated delay or
/// dice: the failure simulation belongs to the list.
class FavoriteContactsLocalDataSource {
  FavoriteContactsLocalDataSource(this._service, this._availability);

  final ServiceGetContacts _service;
  final ContactsAvailability _availability;

  /// Throws [FavoritesUnavailableException] when the list call failed.
  Future<List<ContactModel>> getByIds(Set<int> ids) async {
    if (!_availability.isAvailable) {
      throw const FavoritesUnavailableException();
    }
    return _service.read().where((model) => ids.contains(model.id)).toList();
  }
}
