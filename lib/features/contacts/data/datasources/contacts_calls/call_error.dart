import '../../../domain/repositories/contacts_connection_exception.dart';
import '../../models/contact_model.dart';
import 'contacts_call.dart';

/// Simulates a broken connection: no data comes back.
class CallError implements ContactsCall {
  @override
  Future<List<ContactModel>> execute() =>
      Future.error(const ContactsConnectionException());
}
