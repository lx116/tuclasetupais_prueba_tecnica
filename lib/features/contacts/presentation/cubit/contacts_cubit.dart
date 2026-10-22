import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/contacts_connection_exception.dart';
import '../../domain/usecases/get_contacts.dart';
import 'contacts_state.dart';

const String _connectionMessage = 'Revisa tu conexión e inténtalo de nuevo.';

class ContactsCubit extends Cubit<ContactsState> {
  ContactsCubit(this._getContacts) : super(const ContactsLoading());

  final GetContacts _getContacts;

  /// Loads the contacts. Also serves as the retry action after an error.
  Future<void> load() async {
    if (state is! ContactsLoading) emit(const ContactsLoading());

    final ContactsState next;
    try {
      final contacts = await _getContacts();
      next = contacts.isEmpty ? const ContactsEmpty() : ContactsData(contacts);
    } catch (error) {
      if (isClosed) return;
      emit(ContactsError(_describe(error)));
      return;
    }

    if (!isClosed) emit(next);
  }

  String _describe(Object error) => switch (error) {
    ContactsConnectionException() => _connectionMessage,
    _ => '$error',
  };
}
