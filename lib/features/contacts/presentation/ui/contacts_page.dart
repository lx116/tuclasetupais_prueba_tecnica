import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/layout/breakpoints.dart';
import '../../../../core/router/contacts_query.dart';
import '../../../../core/router/current_location.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/brand_header.dart';
import '../../../../core/widgets/header_nav.dart';
import '../../../../shared/presentation/widgets/search_input.dart';
import '../cubit/contacts_cubit.dart';
import '../cubit/contacts_provider.dart';
import 'contacts_list.dart';
import 'department_filter.dart';

/// The contacts column: owns the [ContactsCubit] through its provider.
///
/// [query] is the `?search=` and `?department=` of the URL, the single source
/// of truth: typing or picking a chip writes it back to the URL and the URL
/// drives the filter.
class ContactsPage extends StatelessWidget {
  const ContactsPage({
    super.key,
    this.selectedId,
    this.query = const ContactsQuery(),
  });

  final int? selectedId;
  final ContactsQuery query;

  @override
  Widget build(BuildContext context) {
    return ContactsProvider(
      initialSearch: query.search,
      initialDepartment: query.department,
      child: _ContactsView(selectedId: selectedId, query: query),
    );
  }
}

class _ContactsView extends StatefulWidget {
  const _ContactsView({required this.selectedId, required this.query});

  final int? selectedId;
  final ContactsQuery query;

  @override
  State<_ContactsView> createState() => _ContactsViewState();
}

class _ContactsViewState extends State<_ContactsView> {
  @override
  void didUpdateWidget(_ContactsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final cubit = context.read<ContactsCubit>();
    if (widget.query.search != oldWidget.query.search) {
      cubit.search(widget.query.search);
    }
    if (widget.query.department != oldWidget.query.department) {
      cubit.filterByDepartment(widget.query.department);
    }
  }

  /// Writes [next] to the URL; the path and any other parameter are kept. It
  /// uses `go` because `replace` does not update the URL of the location it
  /// replaces. Typing is debounced, so each pause adds one history entry.
  void _setQuery(ContactsQuery next) {
    final uri = currentUriOf(context);
    final params = {...uri.queryParameters}
      ..remove(ContactsQuery.searchParam)
      ..remove(ContactsQuery.departmentParam)
      ..addAll(next.toParams() ?? const {});
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
      value: widget.query.search,
      onChanged: (text) =>
          _setQuery(currentQueryOf(context).copyWith(search: text)),
      hintText: 'Buscar contactos',
      fontSize: wide ? 15 : 16,
    );
    final chips = DepartmentFilter(
      selected: widget.query.department,
      onChanged: (department) =>
          _setQuery(currentQueryOf(context).copyWith(department: department)),
      height: wide ? 34 : 36,
    );

    return Column(
      children: [
        if (wide)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [input, const SizedBox(height: 12), chips],
            ),
          )
        else ...[
          ColoredBox(
            color: AppColors.darkTeal,
            child: Column(
              children: [
                const BrandHeader(
                  compact: true,
                  trailing: HeaderNav(
                    current: HeaderSection.contacts,
                    compact: true,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: input,
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: chips,
          ),
        ],
        Expanded(
          child: ContactsList(
            selectedId: widget.selectedId,
            query: widget.query,
            onClear: () => _setQuery(const ContactsQuery()),
          ),
        ),
      ],
    );
  }
}
