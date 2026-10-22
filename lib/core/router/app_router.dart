import 'package:go_router/go_router.dart';

import '../../features/contact_detail/presentation/ui/contact_detail_page.dart';
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
      GoRoute(
        path: AppRoutes.contactDetailPattern,
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id == null) {
            return const NotFoundPage(message: 'Contact not found');
          }
          return ContactDetailPage(contactId: id);
        },
      ),
    ],
    errorBuilder: (context, state) => const NotFoundPage(),
  );
}
