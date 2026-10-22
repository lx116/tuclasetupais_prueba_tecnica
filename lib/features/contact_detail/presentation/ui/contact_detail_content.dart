import 'package:flutter/material.dart';

import '../../../../core/contacts/domain/entities/contact.dart';

/// Presentational body of the detail: every field of a [Contact].
class ContactDetailContent extends StatelessWidget {
  const ContactDetailContent({super.key, required this.contact});

  final Contact contact;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          leading: CircleAvatar(child: Text(contact.name.characters.first)),
          title: Text(contact.name),
          trailing: contact.active ? null : const Text('Inactive'),
        ),
        ListTile(
          leading: const Icon(Icons.work_outline),
          title: Text(contact.role),
          subtitle: const Text('Role'),
        ),
        ListTile(
          leading: const Icon(Icons.apartment),
          title: Text(contact.department),
          subtitle: const Text('Department'),
        ),
        ListTile(
          leading: const Icon(Icons.email_outlined),
          title: Text(contact.email),
          subtitle: const Text('Email'),
        ),
        ListTile(
          leading: const Icon(Icons.phone_outlined),
          title: Text(contact.phone),
          subtitle: const Text('Phone'),
        ),
      ],
    );
  }
}
