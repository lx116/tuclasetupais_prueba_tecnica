import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/layout/breakpoints.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/widgets/reload_button.dart';
import '../../../../core/widgets/secondary_button.dart';
import '../../../../core/widgets/state_message.dart';
import '../cubit/contacts_cubit.dart';
import '../cubit/contacts_state.dart';
import 'contact_list_item.dart';
import 'contacts_skeleton.dart';

/// Renders every [ContactsState]. [selectedId] is the contact open in the
/// detail column, if any. [search] is carried to the contact links so opening
/// a contact keeps the search; [onClearSearch] resets it from the no-results
/// state.
class ContactsList extends StatelessWidget {
  const ContactsList({
    super.key,
    this.selectedId,
    this.search = '',
    this.onClearSearch,
  });

  final int? selectedId;
  final String search;
  final VoidCallback? onClearSearch;

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
        ContactsNoResults(:final query) => StateMessage(
          icon: Icons.search_off,
          title: 'Sin resultados para “$query”',
          message: 'Prueba con otro término.',
          action: onClearSearch == null
              ? null
              : SecondaryButton(
                  label: 'Limpiar búsqueda',
                  onPressed: onClearSearch!,
                ),
        ),
        ContactsData(:final contacts, :final query) => Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: _Count(count: contacts.length, query: query),
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
                    onTap: () => context.go(
                      AppRoutes.contactDetail(contact.id, search: search),
                    ),
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
  const _Count({required this.count, required this.query});

  final int count;
  final String query;

  @override
  Widget build(BuildContext context) {
    final style = appText(size: 13, color: AppColors.muted);
    return Text.rich(
      TextSpan(
        style: style,
        children: [
          TextSpan(text: '$count', style: appText(size: 13, weight: 700)),
          TextSpan(
            text:
                (count == 1 ? ' resultado' : ' resultados') +
                (query.isEmpty ? '' : ' para “$query”'),
          ),
        ],
      ),
    );
  }
}
