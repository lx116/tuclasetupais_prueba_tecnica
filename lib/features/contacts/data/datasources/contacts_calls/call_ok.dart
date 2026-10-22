import '../../../../../core/contacts/data/models/contact_model.dart';
import '../../../../../core/contacts/data/service_get_contacts.dart';
import 'contacts_call.dart';

/// Simulates a successful call: answers with what the service loaded.
class CallOk implements ContactsCall {
  CallOk(this._service);

  final ServiceGetContacts _service;

  @override
  Future<List<ContactModel>> execute() async => _service.read();
}
