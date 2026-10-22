import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/router/not_found_page.dart';
import '../cubit/contact_detail_cubit.dart';
import '../cubit/contact_detail_provider.dart';
import '../cubit/contact_detail_state.dart';
import 'contact_detail_content.dart';

class ContactDetailPage extends StatelessWidget {
  const ContactDetailPage({super.key, required this.contactId});

  final int contactId;

  @override
  Widget build(BuildContext context) {
    return ContactDetailProvider(
      contactId: contactId,
      child: BlocBuilder<ContactDetailCubit, ContactDetailState>(
        builder: (context, state) => switch (state) {
          ContactDetailNotFound() => const NotFoundPage(
            message: 'Contact not found',
          ),
          ContactDetailLoading() => _frame(
            context,
            title: 'Contact',
            body: const Center(child: CircularProgressIndicator()),
          ),
          ContactDetailError(:final message) => _frame(
            context,
            title: 'Contact',
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(message, textAlign: TextAlign.center),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.contacts),
                    child: const Text('Back to contacts'),
                  ),
                ],
              ),
            ),
          ),
          ContactDetailData(:final contact) => _frame(
            context,
            title: 'Contact',
            body: ContactDetailContent(contact: contact),
          ),
        },
      ),
    );
  }

  Widget _frame(
    BuildContext context, {
    required String title,
    required Widget body,
  }) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: body,
    );
  }
}
