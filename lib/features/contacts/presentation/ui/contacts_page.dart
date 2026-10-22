import 'package:flutter/material.dart';

import '../cubit/contacts_provider.dart';
import 'contacts_list.dart';

/// The contacts column: owns the [ContactsCubit] through its provider.
class ContactsPage extends StatelessWidget {
  const ContactsPage({super.key, this.selectedId});

  final int? selectedId;

  @override
  Widget build(BuildContext context) {
    return ContactsProvider(child: ContactsList(selectedId: selectedId));
  }
}
