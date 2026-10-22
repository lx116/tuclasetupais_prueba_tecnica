import '../../../../../core/contacts/data/models/contact_model.dart';
import 'contacts_call.dart';

/// Simulates a successful call that found no contacts.
class CallEmpty implements ContactsCall {
  @override
  Future<List<ContactModel>> execute() async => const [];
}
