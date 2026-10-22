import 'package:flutter/foundation.dart';

import '../../../../core/contacts/domain/entities/contact.dart';

sealed class FavoriteContactsState {
  const FavoriteContactsState();
}

class FavoriteContactsLoading extends FavoriteContactsState {
  const FavoriteContactsLoading();

  @override
  bool operator ==(Object other) => other is FavoriteContactsLoading;

  @override
  int get hashCode => (FavoriteContactsLoading).hashCode;
}

class FavoriteContactsEmpty extends FavoriteContactsState {
  const FavoriteContactsEmpty();

  @override
  bool operator ==(Object other) => other is FavoriteContactsEmpty;

  @override
  int get hashCode => (FavoriteContactsEmpty).hashCode;
}

class FavoriteContactsError extends FavoriteContactsState {
  const FavoriteContactsError(this.message);

  final String message;

  @override
  bool operator ==(Object other) =>
      other is FavoriteContactsError && other.message == message;

  @override
  int get hashCode => Object.hash(FavoriteContactsError, message);
}

class FavoriteContactsData extends FavoriteContactsState {
  const FavoriteContactsData(this.contacts);

  final List<Contact> contacts;

  @override
  bool operator ==(Object other) =>
      other is FavoriteContactsData && listEquals(other.contacts, contacts);

  @override
  int get hashCode =>
      Object.hash(FavoriteContactsData, Object.hashAll(contacts));
}
