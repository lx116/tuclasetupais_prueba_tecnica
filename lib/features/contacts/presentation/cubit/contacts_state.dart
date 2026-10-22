import 'package:flutter/foundation.dart';

import '../../../../core/contacts/domain/entities/contact.dart';

sealed class ContactsState {
  const ContactsState();
}

class ContactsLoading extends ContactsState {
  const ContactsLoading();

  @override
  bool operator ==(Object other) => other is ContactsLoading;

  @override
  int get hashCode => (ContactsLoading).hashCode;
}

class ContactsEmpty extends ContactsState {
  const ContactsEmpty();

  @override
  bool operator ==(Object other) => other is ContactsEmpty;

  @override
  int get hashCode => (ContactsEmpty).hashCode;
}

class ContactsError extends ContactsState {
  const ContactsError(this.message);

  final String message;

  @override
  bool operator ==(Object other) =>
      other is ContactsError && other.message == message;

  @override
  int get hashCode => Object.hash(ContactsError, message);
}

/// The contacts to show. [query] and [department] are the search and filter
/// that produced them, empty when they were not used.
class ContactsData extends ContactsState {
  const ContactsData(this.contacts, {this.query = '', this.department = ''});

  final List<Contact> contacts;
  final String query;
  final String department;

  @override
  bool operator ==(Object other) =>
      other is ContactsData &&
      other.query == query &&
      other.department == department &&
      listEquals(other.contacts, contacts);

  @override
  int get hashCode =>
      Object.hash(ContactsData, query, department, Object.hashAll(contacts));
}

/// There are contacts, but none matches the search [query] and the
/// [department] filter.
class ContactsNoResults extends ContactsState {
  const ContactsNoResults({this.query = '', this.department = ''});

  final String query;
  final String department;

  @override
  bool operator ==(Object other) =>
      other is ContactsNoResults &&
      other.query == query &&
      other.department == department;

  @override
  int get hashCode => Object.hash(ContactsNoResults, query, department);
}
