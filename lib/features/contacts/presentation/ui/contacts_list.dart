import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/layout/breakpoints.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/widgets/reload_button.dart';
import '../../../../core/widgets/state_message.dart';
import '../cubit/contacts_cubit.dart';
import '../cubit/contacts_state.dart';
import 'contact_list_item.dart';
import 'contacts_skeleton.dart';

/// Renders every [ContactsState]. [selectedId] is the contact open in the
/// detail column, if any.
class ContactsList extends StatelessWidget {
  const ContactsList({super.key, this.selectedId});

  final int? selectedId;

  @override
  Widget build(BuildContext context) {
    final wide = isWideWidth(MediaQuery.sizeOf(context).width);

    return BlocBuilder<ContactsCubit, ContactsState>(
      builder: (context, state) => switch (state) {
        ContactsLoading() => const SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: ContactsSkeleton(),
        ),
        ContactsEmpty() => StateMessage(
          icon: Icons.person_outline,
          title: 'Aún no hay contactos',
          message: 'Cuando existan contactos aparecerán aquí.',
          action: ReloadButton(
            label: 'Recargar',
            onPressed: () => context.read<ContactsCubit>().load(),
          ),
        ),
        ContactsError(:final message) => StateMessage(
          isError: true,
          icon: Icons.wifi_off,
          title: 'No pudimos cargar los contactos',
          message: message,
          action: ReloadButton(
            label: 'Reintentar',
            onPressed: () => context.read<ContactsCubit>().load(),
          ),
        ),
        ContactsData(:final contacts) => Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: _Count(count: contacts.length),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: wide
                    ? EdgeInsets.zero
                    : const EdgeInsets.fromLTRB(12, 0, 12, 16),
                itemCount: contacts.length,
                separatorBuilder: (context, index) =>
                    SizedBox(height: wide ? 0 : 8),
                itemBuilder: (context, index) {
                  final contact = contacts[index];
                  return ContactListItem(
                    contact: contact,
                    card: !wide,
                    selected: contact.id == selectedId,
                    onTap: () =>
                        context.go(AppRoutes.contactDetail(contact.id)),
                  );
                },
              ),
            ),
          ],
        ),
      },
    );
  }
}

class _Count extends StatelessWidget {
  const _Count({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final style = appText(size: 13, color: AppColors.muted);
    return Text.rich(
      TextSpan(
        style: style,
        children: [
          TextSpan(text: '$count', style: appText(size: 13, weight: 700)),
          TextSpan(text: count == 1 ? ' resultado' : ' resultados'),
        ],
      ),
    );
  }
}
