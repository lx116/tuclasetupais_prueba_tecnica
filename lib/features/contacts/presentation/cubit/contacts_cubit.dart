import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/contacts/domain/entities/contact.dart';
import '../../domain/repositories/contacts_connection_exception.dart';
import '../../domain/usecases/filter_contacts_by_department.dart';
import '../../domain/usecases/get_contacts.dart';
import '../../domain/usecases/search_contacts.dart';
import 'contacts_state.dart';

const String _connectionMessage = 'Revisa tu conexión e inténtalo de nuevo.';

class ContactsCubit extends Cubit<ContactsState> {
  ContactsCubit(
    this._getContacts,
    this._searchContacts,
    this._filterByDepartment,
  ) : super(const ContactsLoading());

  final GetContacts _getContacts;
  final SearchContacts _searchContacts;
  final FilterContactsByDepartment _filterByDepartment;

  // Everything the last load returned; searching and filtering work on this
  // in memory, they never call the source again.
  List<Contact> _all = const [];
  String _query = '';
  String _department = '';

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

  /// Keeps only the contacts of [department] (its URL form, `ingenieria`);
  /// empty shows every department. Combines with [search]. Like [search], it
  /// only remembers the value until the data arrives.
  void filterByDepartment(String department) {
    if (department == _department) return;
    _department = department;
    if (state is ContactsData || state is ContactsNoResults) {
      emit(_present());
    }
  }

  ContactsState _present() {
    if (_all.isEmpty) return const ContactsEmpty();

    final query = _query.trim();
    final department = _department.trim();
    final matches = _filterByDepartment(
      _searchContacts(_all, query),
      department,
    );
    if (matches.isEmpty) {
      return ContactsNoResults(query: query, department: department);
    }
    return ContactsData(matches, query: query, department: department);
  }

  String _describe(Object error) => switch (error) {
    ContactsConnectionException() => _connectionMessage,
    _ => '$error',
  };
}
