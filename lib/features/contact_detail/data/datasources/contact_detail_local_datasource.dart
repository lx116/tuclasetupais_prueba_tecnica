import '../../../../core/contacts/data/contacts_availability.dart';
import '../../../../core/contacts/data/models/contact_model.dart';
import '../../../../core/contacts/data/service_get_contacts.dart';
import '../../domain/repositories/contact_detail_unavailable_exception.dart';

/// Reads one contact from the in-memory data. No simulated delay or dice: the
/// failure simulation belongs to the list.
class ContactDetailLocalDataSource {
  ContactDetailLocalDataSource(this._service, this._availability);

  final ServiceGetContacts _service;
  final ContactsAvailability _availability;

  /// `null` when the id does not exist. Throws
  /// [ContactDetailUnavailableException] when the list call failed.
  Future<ContactModel?> getContactById(int id) async {
    if (!_availability.isAvailable) {
      throw const ContactDetailUnavailableException();
    }

    for (final model in _service.read()) {
      if (model.id == id) return model;
    }
    return null;
  }
}
