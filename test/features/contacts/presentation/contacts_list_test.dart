import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tuclasetupais_prueba_tecnica/core/contacts/domain/entities/contact.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/domain/repositories/contact_repository.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/domain/usecases/get_contacts.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/presentation/cubit/contacts_cubit.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/presentation/ui/contact_list_item.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/presentation/ui/contacts_list.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/presentation/ui/contacts_skeleton.dart';

Contact _contact(int id, {String name = 'Camila Reyes', bool active = true}) =>
    Contact(
      id: id,
      name: name,
      role: 'Product Designer',
      department: 'Diseño',
      email: 'camila.reyes@empresa.cl',
      phone: '+56 9 1111 2222',
      active: active,
    );

class _FakeRepository implements ContactRepository {
  _FakeRepository(this.results);
  final List<Object> results;

  @override
  Future<List<Contact>> getContacts() async {
    final next = results.removeAt(0);
    if (next is List<Contact>) return next;
    throw next;
  }
}

ContactsCubit _cubit(List<Object> results) =>
    ContactsCubit(GetContacts(_FakeRepository(results)));

Widget _app(ContactsCubit cubit) => MaterialApp(
  home: Scaffold(
    body: BlocProvider.value(value: cubit, child: const ContactsList()),
  ),
);

void main() {
  group('ContactListItem', () {
    testWidgets('shows name and email in the flat row', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ContactListItem(contact: _contact(1))),
        ),
      );

      expect(find.text('Camila Reyes'), findsOneWidget);
      expect(find.text('camila.reyes@empresa.cl'), findsOneWidget);
      expect(find.text('Inactivo'), findsNothing);
    });

    testWidgets('the card row shows the department instead', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContactListItem(contact: _contact(1), card: true),
          ),
        ),
      );

      expect(find.text('Diseño'), findsOneWidget);
      expect(find.text('camila.reyes@empresa.cl'), findsNothing);
    });

    testWidgets('reports taps', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContactListItem(contact: _contact(1), onTap: () => taps++),
          ),
        ),
      );

      await tester.tap(find.text('Camila Reyes'));

      expect(taps, 1);
    });

    testWidgets('flags an inactive contact', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContactListItem(contact: _contact(1, active: false)),
          ),
        ),
      );

      expect(find.text('Inactivo'), findsOneWidget);
    });
  });

  group('ContactsList', () {
    testWidgets('shows the skeleton while loading', (tester) async {
      await tester.pumpWidget(_app(_cubit([])));

      expect(find.byType(ContactsSkeleton), findsOneWidget);
    });

    testWidgets('shows one item per contact when there is data', (
      tester,
    ) async {
      final cubit = _cubit([
        [_contact(1), _contact(2, name: 'Matías Soto')],
      ]);
      await cubit.load();

      await tester.pumpWidget(_app(cubit));

      expect(find.byType(ContactListItem), findsNWidgets(2));
      expect(find.text('Matías Soto'), findsOneWidget);
    });

    testWidgets('tapping an item opens its detail route', (tester) async {
      final cubit = _cubit([
        [_contact(1), _contact(2, name: 'Matías Soto')],
      ]);
      await cubit.load();
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: BlocProvider.value(
                value: cubit,
                child: const ContactsList(),
              ),
            ),
          ),
          GoRoute(
            path: '/contacts/:id',
            builder: (context, state) =>
                Text('detail ${state.pathParameters['id']}'),
          ),
        ],
      );
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      await tester.tap(find.text('Matías Soto'));
      await tester.pumpAndSettle();

      expect(find.text('detail 2'), findsOneWidget);
    });

    testWidgets('shows the empty message when there are no contacts', (
      tester,
    ) async {
      final cubit = _cubit([<Contact>[]]);
      await cubit.load();

      await tester.pumpWidget(_app(cubit));

      expect(find.text('Aún no hay contactos'), findsOneWidget);
      expect(find.byType(ContactListItem), findsNothing);
    });

    testWidgets('the empty state has a reload button that loads again', (
      tester,
    ) async {
      final cubit = _cubit([
        <Contact>[],
        [_contact(1)],
      ]);
      await cubit.load();
      await tester.pumpWidget(_app(cubit));
      expect(find.text('Recargar'), findsOneWidget);

      await tester.tap(find.text('Recargar'));
      await tester.pump();
      await tester.pump();

      expect(find.byType(ContactListItem), findsOneWidget);
      expect(find.text('Recargar'), findsNothing);
    });

    testWidgets('shows the error and retries on tap', (tester) async {
      final cubit = _cubit([
        const FormatException('bad data'),
        [_contact(1)],
      ]);
      await cubit.load();

      await tester.pumpWidget(_app(cubit));
      expect(find.textContaining('bad data'), findsOneWidget);

      await tester.tap(find.text('Reintentar'));
      await tester.pump();
      await tester.pump();

      expect(find.byType(ContactListItem), findsOneWidget);
      expect(find.text('Reintentar'), findsNothing);
    });
  });
}
