import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../di/injection.dart';
import '../favorites/presentation/favorites_cubit.dart';

import '../../features/contact_detail/presentation/ui/contact_detail_page.dart';
import '../../features/contacts/presentation/ui/contacts_shell.dart';
import '../../features/contacts/presentation/ui/detail_placeholder.dart';
import '../../features/favorites/presentation/ui/favorites_page.dart';
import 'app_routes.dart';
import 'contacts_query.dart';
import 'not_found_page.dart';

GoRouter createAppRouter({String initialLocation = AppRoutes.contacts}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(path: '/', redirect: (context, state) => AppRoutes.contacts),
      // Provides the app-wide favorites to every page below.
      ShellRoute(
        builder: (context, state, child) => BlocProvider<FavoritesCubit>.value(
          value: sl<FavoritesCubit>(),
          child: child,
        ),
        routes: [
          GoRoute(
            path: AppRoutes.favorites,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const FavoritesPage(),
            ),
          ),
          // The shell splits the screen into the contacts column and the detail
          // column (wide) or shows one of them (mobile). Its children render in
          // the detail column.
          ShellRoute(
            builder: (context, state, child) {
              final segments = state.uri.pathSegments;
              final detailOpen = segments.length > 1;
              return Scaffold(
                body: ContactsShell(
                  query: ContactsQuery.fromUri(state.uri),
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
                            ? const NotFoundPage(
                                message: 'Contacto no encontrado',
                              )
                            : ContactDetailPage(contactId: id),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => const Scaffold(body: NotFoundPage()),
  );
}
