import 'package:flutter/foundation.dart';

import '../../domain/entities/contact.dart';

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

class ContactsData extends ContactsState {
  const ContactsData(this.contacts);

  final List<Contact> contacts;

  @override
  bool operator ==(Object other) =>
      other is ContactsData && listEquals(other.contacts, contacts);

  @override
  int get hashCode => Object.hash(ContactsData, Object.hashAll(contacts));
}
