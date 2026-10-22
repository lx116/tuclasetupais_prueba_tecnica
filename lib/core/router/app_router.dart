import 'package:go_router/go_router.dart';

import '../../features/contacts/presentation/ui/contacts_page.dart';
import 'app_routes.dart';
import 'not_found_page.dart';

GoRouter createAppRouter({String initialLocation = AppRoutes.contacts}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(path: '/', redirect: (context, state) => AppRoutes.contacts),
      GoRoute(
        path: AppRoutes.contacts,
        builder: (context, state) => const ContactsPage(),
      ),
    ],
    errorBuilder: (context, state) => const NotFoundPage(),
  );
}
