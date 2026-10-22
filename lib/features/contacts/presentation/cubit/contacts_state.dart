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

/// The contacts to show. [query] is the search that produced them, empty when
/// every contact is shown.
class ContactsData extends ContactsState {
  const ContactsData(this.contacts, {this.query = ''});

  final List<Contact> contacts;
  final String query;

  @override
  bool operator ==(Object other) =>
      other is ContactsData &&
      other.query == query &&
      listEquals(other.contacts, contacts);

  @override
  int get hashCode =>
      Object.hash(ContactsData, query, Object.hashAll(contacts));
}

/// There are contacts, but none matches the search [query].
class ContactsNoResults extends ContactsState {
  const ContactsNoResults(this.query);

  final String query;

  @override
  bool operator ==(Object other) =>
      other is ContactsNoResults && other.query == query;

  @override
  int get hashCode => Object.hash(ContactsNoResults, query);
}
