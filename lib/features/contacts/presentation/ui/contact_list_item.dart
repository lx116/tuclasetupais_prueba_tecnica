import 'package:flutter/material.dart';

import '../../domain/entities/contact.dart';

/// Temporary row for a single [Contact].
class ContactListItem extends StatelessWidget {
  const ContactListItem({super.key, required this.contact});

  final Contact contact;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(child: Text(contact.name.characters.first)),
      title: Text(contact.name),
      subtitle: Text('${contact.role} · ${contact.department}'),
      trailing: contact.active ? null : const Text('Inactive'),
    );
  }
}
