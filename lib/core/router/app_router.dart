import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/contact_detail/presentation/ui/contact_detail_page.dart';
import '../../features/contacts/presentation/ui/contacts_shell.dart';
import '../../features/contacts/presentation/ui/detail_placeholder.dart';
import 'app_routes.dart';
import 'not_found_page.dart';

GoRouter createAppRouter({String initialLocation = AppRoutes.contacts}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(path: '/', redirect: (context, state) => AppRoutes.contacts),
      // The shell splits the screen into the contacts column and the detail
      // column (wide) or shows one of them (mobile). Its children render in
      // the detail column.
      ShellRoute(
        builder: (context, state, child) {
          final segments = state.uri.pathSegments;
          final detailOpen = segments.length > 1;
          return Scaffold(
            body: ContactsShell(
              search: state.uri.queryParameters[AppRoutes.searchParam] ?? '',
              detailOpen: detailOpen,
              selectedId: detailOpen ? int.tryParse(segments[1]) : null,
              detail: child,
            ),
          );
        },
        routes: [
          GoRoute(
            path: AppRoutes.contacts,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const DetailPlaceholder(),
            ),
            routes: [
              GoRoute(
                path: AppRoutes.contactDetailSegment,
                pageBuilder: (context, state) {
                  final id = int.tryParse(state.pathParameters['id'] ?? '');
                  return NoTransitionPage(
                    key: state.pageKey,
                    child: id == null
                        ? const NotFoundPage(message: 'Contacto no encontrado')
                        : ContactDetailPage(contactId: id),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => const Scaffold(body: NotFoundPage()),
  );
}
