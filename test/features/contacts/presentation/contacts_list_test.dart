import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/domain/entities/contact.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/domain/repositories/contact_repository.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/domain/usecases/get_contacts.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/presentation/cubit/contacts_cubit.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/presentation/ui/contact_list_item.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/presentation/ui/contacts_list.dart';

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
    testWidgets('shows name, role and department', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ContactListItem(contact: _contact(1))),
        ),
      );

      expect(find.text('Camila Reyes'), findsOneWidget);
      expect(find.text('Product Designer · Diseño'), findsOneWidget);
      expect(find.text('Inactive'), findsNothing);
    });

    testWidgets('flags an inactive contact', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContactListItem(contact: _contact(1, active: false)),
          ),
        ),
      );

      expect(find.text('Inactive'), findsOneWidget);
    });
  });

  group('ContactsList', () {
    testWidgets('shows a progress indicator while loading', (tester) async {
      await tester.pumpWidget(_app(_cubit([])));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
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

    testWidgets('shows the empty message when there are no contacts', (
      tester,
    ) async {
      final cubit = _cubit([<Contact>[]]);
      await cubit.load();

      await tester.pumpWidget(_app(cubit));

      expect(find.text('No contacts found'), findsOneWidget);
      expect(find.byType(ContactListItem), findsNothing);
    });

    testWidgets('shows the error and retries on tap', (tester) async {
      final cubit = _cubit([
        const FormatException('bad data'),
        [_contact(1)],
      ]);
      await cubit.load();

      await tester.pumpWidget(_app(cubit));
      expect(find.textContaining('bad data'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pump();
      await tester.pump();

      expect(find.byType(ContactListItem), findsOneWidget);
      expect(find.text('Retry'), findsNothing);
    });
  });
}
