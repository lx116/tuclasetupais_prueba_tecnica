import 'contact.dart';
import 'contact_catalog.dart';

/// Business rules for [Contact]. Each validator returns an error message, or
/// `null` when the value is valid.
class ContactValidators {
  const ContactValidators._();

  static final RegExp _email = RegExp(r'^[^\s@]+@([^\s@.]+\.)+[^\s@.]+$');

  static String? role(String value) => ContactRoles.contains(value)
      ? null
      : 'Role "$value" is not one of: ${ContactRoles.all.join(', ')}';

  static String? department(String value) => ContactDepartments.contains(value)
      ? null
      : 'Department "$value" is not one of: '
            '${ContactDepartments.all.join(', ')}';

  static String? email(String value) =>
      _email.hasMatch(value) ? null : 'Email "$value" is not a valid email';

  static String? uniqueIds(List<Contact> contacts) {
    final seen = <int>{};
    final repeated = <int>{};
    for (final contact in contacts) {
      if (!seen.add(contact.id)) repeated.add(contact.id);
    }
    return repeated.isEmpty
        ? null
        : 'Repeated contact ids: ${repeated.join(', ')}';
  }
}
