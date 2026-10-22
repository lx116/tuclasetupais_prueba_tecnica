import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tuclasetupais_prueba_tecnica/core/contacts/domain/entities/contact.dart';
import 'package:tuclasetupais_prueba_tecnica/core/di/injection.dart';
import 'package:tuclasetupais_prueba_tecnica/core/router/not_found_page.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contact_detail/domain/repositories/contact_detail_repository.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contact_detail/domain/repositories/contact_detail_unavailable_exception.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contact_detail/domain/usecases/get_contact_by_id.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contact_detail/presentation/cubit/contact_detail_cubit.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contact_detail/presentation/ui/contact_detail_page.dart';

const _contact = Contact(
  id: 3,
  name: 'Valentina Cid',
  role: 'QA Lead',
  department: 'Ingeniería',
  email: 'valentina.cid@empresa.cl',
  phone: '+56 9 3333 4444',
  active: false,
);

class _FakeRepository implements ContactDetailRepository {
  _FakeRepository(this.result);
  final Object? result;

  @override
  Future<Contact?> getContactById(int id) async {
    final value = result;
    if (value is Contact?) return value;
    throw value;
  }
}

Future<void> _pump(WidgetTester tester, Object? result) async {
  sl.registerFactory<ContactDetailCubit>(
    () => ContactDetailCubit(GetContactById(_FakeRepository(result))),
  );
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const ContactDetailPage(contactId: 3),
      ),
      GoRoute(
        path: '/contacts',
        builder: (context, state) => const Text('list page'),
      ),
    ],
  );
  await tester.pumpWidget(MaterialApp.router(routerConfig: router));
  expect(find.byType(CircularProgressIndicator), findsOneWidget);
  await tester.pump();
}

void main() {
  tearDown(() => sl.reset());

  testWidgets('shows every field of an existing contact', (tester) async {
    await _pump(tester, _contact);

    expect(find.text('Valentina Cid'), findsOneWidget);
    expect(find.text('QA Lead'), findsOneWidget);
    expect(find.text('Ingeniería'), findsWidgets);
    expect(find.text('valentina.cid@empresa.cl'), findsOneWidget);
    expect(find.text('+56 9 3333 4444'), findsOneWidget);
    expect(find.text('Inactivo'), findsOneWidget);
  });

  testWidgets('shows the 404 page for an id that does not exist', (
    tester,
  ) async {
    await _pump(tester, null);

    expect(find.byType(NotFoundPage), findsOneWidget);
    expect(find.text('Contacto no encontrado'), findsOneWidget);
  });

  testWidgets('shows a load error when the list failed, with a way back', (
    tester,
  ) async {
    await _pump(tester, const ContactDetailUnavailableException());

    expect(find.textContaining('no se cargó'), findsOneWidget);
    expect(find.byType(NotFoundPage), findsNothing);

    await tester.tap(find.text('Volver a contactos'));
    await tester.pumpAndSettle();

    expect(find.text('list page'), findsOneWidget);
  });
}
