import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/layout/breakpoints.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/router/current_location.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/brand_header.dart';
import '../../../../shared/presentation/widgets/search_input.dart';
import '../cubit/contacts_cubit.dart';
import '../cubit/contacts_provider.dart';
import 'contacts_list.dart';

/// The contacts column: owns the [ContactsCubit] through its provider.
///
/// [search] is the `?search=` text of the URL, the single source of truth:
/// typing writes it back to the URL and the URL drives the filter.
class ContactsPage extends StatelessWidget {
  const ContactsPage({super.key, this.selectedId, this.search = ''});

  final int? selectedId;
  final String search;

  @override
  Widget build(BuildContext context) {
    return ContactsProvider(
      initialSearch: search,
      child: _ContactsView(selectedId: selectedId, search: search),
    );
  }
}

class _ContactsView extends StatefulWidget {
  const _ContactsView({required this.selectedId, required this.search});

  final int? selectedId;
  final String search;

  @override
  State<_ContactsView> createState() => _ContactsViewState();
}

class _ContactsViewState extends State<_ContactsView> {
  @override
  void didUpdateWidget(_ContactsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.search != oldWidget.search) {
      context.read<ContactsCubit>().search(widget.search);
    }
  }

  /// Writes the search to the URL; the rest of the location is kept. It uses
  /// `go` because `replace` does not update the URL of the location it
  /// replaces. Typing is debounced, so each pause adds one history entry.
  void _setSearch(String text) {
    final uri = currentUriOf(context);
    final params = {...uri.queryParameters};
    if (text.isEmpty) {
      params.remove(AppRoutes.searchParam);
    } else {
      params[AppRoutes.searchParam] = text;
    }
    context.go(
      Uri(
        path: uri.path,
        queryParameters: params.isEmpty ? null : params,
      ).toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wide = isWideWidth(MediaQuery.sizeOf(context).width);
    final input = SearchInput(
      value: widget.search,
      onChanged: _setSearch,
      hintText: 'Buscar contactos',
      fontSize: wide ? 15 : 16,
    );

    return Column(
      children: [
        if (wide)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: input,
          )
        else
          ColoredBox(
            color: AppColors.darkTeal,
            child: Column(
              children: [
                const BrandHeader(compact: true),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: input,
                ),
              ],
            ),
          ),
        Expanded(
          child: ContactsList(
            selectedId: widget.selectedId,
            search: widget.search,
            onClearSearch: () => _setSearch(''),
          ),
        ),
      ],
    );
  }
}
