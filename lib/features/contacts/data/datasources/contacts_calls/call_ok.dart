import '../../models/contact_model.dart';
import '../service_get_contacts.dart';
import 'contacts_call.dart';

/// Simulates a successful call: answers with what the service loaded.
class CallOk implements ContactsCall {
  CallOk(this._service);

  final ServiceGetContacts _service;

  /// Empty when the JSON was missing. Throws a [FormatException] when the
  /// data did not match the model, and a [StateError] if the service never ran.
  @override
  Future<List<ContactModel>> execute() async {
    switch (_service.status) {
      case ContactsLoadStatus.loaded:
        return _service.contacts;
      case ContactsLoadStatus.missing:
        return const [];
      case ContactsLoadStatus.invalid:
        throw _service.error as FormatException;
      case ContactsLoadStatus.notLoaded:
        throw StateError(
          'ServiceGetContacts.load() must complete before reading contacts',
        );
    }
  }
}
