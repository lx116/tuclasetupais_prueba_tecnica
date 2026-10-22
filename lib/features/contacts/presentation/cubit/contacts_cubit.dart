import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/contacts/domain/entities/contact.dart';
import '../../domain/repositories/contacts_connection_exception.dart';
import '../../domain/usecases/get_contacts.dart';
import '../../domain/usecases/search_contacts.dart';
import 'contacts_state.dart';

const String _connectionMessage = 'Revisa tu conexión e inténtalo de nuevo.';

class ContactsCubit extends Cubit<ContactsState> {
  ContactsCubit(this._getContacts, this._searchContacts)
    : super(const ContactsLoading());

  final GetContacts _getContacts;
  final SearchContacts _searchContacts;

  // Everything the last load returned; searching filters this in memory, it
  // never calls the source again.
  List<Contact> _all = const [];
  String _query = '';

  /// Loads the contacts. Also serves as the retry action after an error.
  Future<void> load() async {
    if (state is! ContactsLoading) emit(const ContactsLoading());

    final ContactsState next;
    try {
      _all = await _getContacts();
      next = _present();
    } catch (error) {
      if (isClosed) return;
      emit(ContactsError(_describe(error)));
      return;
    }

    if (!isClosed) emit(next);
  }

  /// Filters the loaded contacts by name. Before the data arrives it only
  /// remembers [query], which is applied when it does.
  void search(String query) {
    if (query == _query) return;
    _query = query;
    if (state is ContactsData || state is ContactsNoResults) {
      emit(_present());
    }
  }

  ContactsState _present() {
    if (_all.isEmpty) return const ContactsEmpty();

    final query = _query.trim();
    final matches = _searchContacts(_all, query);
    if (matches.isEmpty) return ContactsNoResults(query);
    return ContactsData(matches, query: query);
  }

  String _describe(Object error) => switch (error) {
    ContactsConnectionException() => _connectionMessage,
    _ => '$error',
  };
}
