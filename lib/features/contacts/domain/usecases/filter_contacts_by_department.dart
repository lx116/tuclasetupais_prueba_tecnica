import '../../../../core/contacts/domain/entities/contact.dart';
import '../../../../core/utils/text_folding.dart';

/// Business rule of the department filter: a contact matches when its
/// department is exactly [department], ignoring case and accents (so the URL
/// form `ingenieria` matches "Ingeniería"). A blank department matches every
/// contact. The order of [contacts] is kept.
class FilterContactsByDepartment {
  const FilterContactsByDepartment();

  List<Contact> call(List<Contact> contacts, String department) {
    final wanted = foldText(department.trim());
    if (wanted.isEmpty) return contacts;
    return contacts
        .where((contact) => foldText(contact.department) == wanted)
        .toList();
  }
}
