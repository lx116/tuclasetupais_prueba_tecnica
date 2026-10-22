import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuclasetupais_prueba_tecnica/core/contacts/domain/entities/contact.dart';
import 'package:tuclasetupais_prueba_tecnica/core/di/injection.dart';
import 'package:tuclasetupais_prueba_tecnica/core/router/app_router.dart';
import 'package:tuclasetupais_prueba_tecnica/core/router/app_routes.dart';
import 'package:tuclasetupais_prueba_tecnica/core/router/not_found_page.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/domain/repositories/contact_repository.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/domain/usecases/get_contacts.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/presentation/cubit/contacts_cubit.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/presentation/ui/contacts_page.dart';

class _EmptyRepository implements ContactRepository {
  @override
  Future<List<Contact>> getContacts() async => const [];
}

Future<void> _pump(WidgetTester tester, String location) async {
  sl.registerFactory<ContactsCubit>(
    () => ContactsCubit(GetContacts(_EmptyRepository())),
  );
  await tester.pumpWidget(
    MaterialApp.router(
      routerConfig: createAppRouter(initialLocation: location),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  tearDown(() => sl.reset());

  test('builds the detail location from an id', () {
    expect(AppRoutes.contactDetail(7), '/contacts/7');
  });

  testWidgets('the list lives at /contacts', (tester) async {
    await _pump(tester, AppRoutes.contacts);

    expect(find.byType(ContactsPage), findsOneWidget);
  });

  testWidgets('the root redirects to the list', (tester) async {
    await _pump(tester, '/');

    expect(find.byType(ContactsPage), findsOneWidget);
  });

  testWidgets('an unknown route shows the 404 page', (tester) async {
    await _pump(tester, '/nope');

    expect(find.byType(NotFoundPage), findsOneWidget);
    expect(find.text('404'), findsOneWidget);
  });

  testWidgets('the 404 page links back to the list', (tester) async {
    await _pump(tester, '/nope');

    await tester.tap(find.text('Back to contacts'));
    await tester.pumpAndSettle();

    expect(find.byType(ContactsPage), findsOneWidget);
  });
}
