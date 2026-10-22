import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/contacts_cubit.dart';
import '../cubit/contacts_state.dart';
import 'contact_list_item.dart';

/// Temporary list that renders every [ContactsState].
class ContactsList extends StatelessWidget {
  const ContactsList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContactsCubit, ContactsState>(
      builder: (context, state) => switch (state) {
        ContactsLoading() => const Center(child: CircularProgressIndicator()),
        ContactsEmpty() => const Center(child: Text('No contacts found')),
        ContactsError(:final message) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message),
              TextButton(
                onPressed: () => context.read<ContactsCubit>().load(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        ContactsData(:final contacts) => ListView.builder(
          itemCount: contacts.length,
          itemBuilder: (context, index) =>
              ContactListItem(contact: contacts[index]),
        ),
      },
    );
  }
}
