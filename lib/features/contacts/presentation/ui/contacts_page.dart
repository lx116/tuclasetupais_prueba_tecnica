import 'package:flutter/material.dart';

import '../cubit/contacts_provider.dart';
import 'contacts_list.dart';

class ContactsPage extends StatelessWidget {
  const ContactsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Contacts'),
      ),
      body: const ContactsProvider(child: ContactsList()),
    );
  }
}
