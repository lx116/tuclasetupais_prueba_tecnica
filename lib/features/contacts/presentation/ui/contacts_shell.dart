import 'package:flutter/material.dart';

import '../../../../core/layout/breakpoints.dart';
import '../../../../core/router/contacts_query.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/brand_header.dart';
import '../../../../core/widgets/header_nav.dart';
import 'contacts_page.dart';

const double _listColumnWidth = 400;

/// Frame of the ShellRoute: the contacts column plus the detail column.
///
/// Wide (> 900px): both columns side by side. Mobile: the list (which brings
/// its own header), or the detail when one is open. The list and the detail are keyed and, once built, kept
/// in the tree, so resizing across the breakpoint moves them instead of
/// recreating them: the cubit, the loaded data and the scroll position stay.
class ContactsShell extends StatefulWidget {
  const ContactsShell({
    super.key,
    required this.detail,
    required this.detailOpen,
    this.selectedId,
    this.query = const ContactsQuery(),
  });

  /// The ShellRoute child: the placeholder or the open contact.
  final Widget detail;

  /// Whether the location is `/contacts/:id`.
  final bool detailOpen;

  /// The id of the open contact, when the URL holds a numeric one.
  final int? selectedId;

  /// The search and filter of the URL.
  final ContactsQuery query;

  @override
  State<ContactsShell> createState() => _ContactsShellState();
}

class _ContactsShellState extends State<ContactsShell> {
  final GlobalKey _listKey = GlobalKey();
  final GlobalKey _detailKey = GlobalKey();

  // The list loads the first time it is needed (a direct link to a detail on
  // mobile does not need it) and then stays alive.
  bool _listBuilt = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = isWideWidth(constraints.maxWidth);
        if (wide || !widget.detailOpen) _listBuilt = true;

        final list = _listBuilt
            ? ContactsPage(
                key: _listKey,
                selectedId: widget.selectedId,
                query: widget.query,
              )
            : const SizedBox.shrink();
        final detail = KeyedSubtree(key: _detailKey, child: widget.detail);

        if (wide) {
          return Column(
            children: [
              const BrandHeader(
                trailing: HeaderNav(current: HeaderSection.contacts),
              ),
              Expanded(
                child: Row(
                  children: [
                    SizedBox(
                      width: _listColumnWidth,
                      child: DecoratedBox(
                        decoration: const BoxDecoration(
                          color: AppColors.surface,
                          border: Border(
                            right: BorderSide(color: AppColors.border),
                          ),
                        ),
                        child: list,
                      ),
                    ),
                    Expanded(child: detail),
                  ],
                ),
              ),
            ],
          );
        }

        return Column(
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Offstage(offstage: widget.detailOpen, child: list),
                  Offstage(offstage: !widget.detailOpen, child: detail),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
