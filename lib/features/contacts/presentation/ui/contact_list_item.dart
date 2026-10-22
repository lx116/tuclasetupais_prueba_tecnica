import 'package:flutter/material.dart';

import '../../../../core/contacts/domain/entities/contact.dart';

/// Temporary row for a single [Contact].
class ContactListItem extends StatelessWidget {
  const ContactListItem({super.key, required this.contact, this.onTap});

  final Contact contact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(child: Text(contact.name.characters.first)),
      title: Text(contact.name),
      subtitle: Text('${contact.role} · ${contact.department}'),
      trailing: contact.active ? null : const Text('Inactive'),
    );
  }
}
