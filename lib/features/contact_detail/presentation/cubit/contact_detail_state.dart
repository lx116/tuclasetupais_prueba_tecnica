import '../../../../core/contacts/domain/entities/contact.dart';

sealed class ContactDetailState {
  const ContactDetailState();
}

class ContactDetailLoading extends ContactDetailState {
  const ContactDetailLoading();

  @override
  bool operator ==(Object other) => other is ContactDetailLoading;

  @override
  int get hashCode => (ContactDetailLoading).hashCode;
}

class ContactDetailNotFound extends ContactDetailState {
  const ContactDetailNotFound();

  @override
  bool operator ==(Object other) => other is ContactDetailNotFound;

  @override
  int get hashCode => (ContactDetailNotFound).hashCode;
}

class ContactDetailError extends ContactDetailState {
  const ContactDetailError(this.message);

  final String message;

  @override
  bool operator ==(Object other) =>
      other is ContactDetailError && other.message == message;

  @override
  int get hashCode => Object.hash(ContactDetailError, message);
}

class ContactDetailData extends ContactDetailState {
  const ContactDetailData(this.contact);

  final Contact contact;

  @override
  bool operator ==(Object other) =>
      other is ContactDetailData && other.contact == contact;

  @override
  int get hashCode => Object.hash(ContactDetailData, contact);
}
