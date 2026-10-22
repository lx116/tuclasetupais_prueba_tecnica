import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuclasetupais_prueba_tecnica/core/contacts/domain/entities/contact.dart';
import 'package:tuclasetupais_prueba_tecnica/core/di/injection.dart';
import 'package:tuclasetupais_prueba_tecnica/core/router/app_router.dart';
import 'package:tuclasetupais_prueba_tecnica/core/router/app_routes.dart';
import 'package:tuclasetupais_prueba_tecnica/core/router/not_found_page.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contact_detail/domain/repositories/contact_detail_repository.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contact_detail/domain/usecases/get_contact_by_id.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contact_detail/presentation/cubit/contact_detail_cubit.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contact_detail/presentation/ui/contact_detail_page.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/domain/repositories/contact_repository.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/domain/usecases/get_contacts.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/domain/usecases/search_contacts.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/presentation/cubit/contacts_cubit.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/presentation/ui/contacts_page.dart';

class _EmptyRepository implements ContactRepository {
  @override
  Future<List<Contact>> getContacts() async => const [];
}

class _DetailRepository implements ContactDetailRepository {
  @override
  Future<Contact?> getContactById(int id) async => id == 1
      ? const Contact(
          id: 1,
          name: 'Camila Reyes',
          role: 'Product Designer',
          department: 'Diseño',
          email: 'camila.reyes@empresa.cl',
          phone: '+56 9 1111 2222',
          active: true,
        )
      : null;
}

Future<void> _pump(WidgetTester tester, String location) async {
  sl.registerFactory<ContactsCubit>(
    () =>
        ContactsCubit(GetContacts(_EmptyRepository()), const SearchContacts()),
  );
  sl.registerFactory<ContactDetailCubit>(
    () => ContactDetailCubit(GetContactById(_DetailRepository())),
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

  testWidgets('/contacts/:id loads the contact of the URL', (tester) async {
    await _pump(tester, '/contacts/1');

    expect(find.byType(ContactDetailPage), findsOneWidget);
    expect(find.text('camila.reyes@empresa.cl'), findsOneWidget);
    expect(find.byType(ContactsPage), findsNothing);
  });

  testWidgets('/contacts/:id with an unknown id shows the 404 page', (
    tester,
  ) async {
    await _pump(tester, '/contacts/999');

    expect(find.byType(NotFoundPage), findsOneWidget);
    expect(find.text('Contacto no encontrado'), findsOneWidget);
  });

  testWidgets('/contacts/:id with a non-numeric id shows the 404 page', (
    tester,
  ) async {
    await _pump(tester, '/contacts/abc');

    expect(find.byType(NotFoundPage), findsOneWidget);
    expect(find.byType(ContactDetailPage), findsNothing);
  });

  testWidgets('an unknown route shows the 404 page', (tester) async {
    await _pump(tester, '/nope');

    expect(find.byType(NotFoundPage), findsOneWidget);
    expect(find.text('404'), findsOneWidget);
  });

  testWidgets('the 404 page links back to the list', (tester) async {
    await _pump(tester, '/nope');

    await tester.tap(find.text('Volver a contactos'));
    await tester.pumpAndSettle();

    expect(find.byType(ContactsPage), findsOneWidget);
  });
}
