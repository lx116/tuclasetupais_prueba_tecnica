import '../../models/contact_model.dart';

/// Command: one simulated outcome of the contacts back call.
abstract class ContactsCall {
  Future<List<ContactModel>> execute();
}
