import 'package:flutter_test/flutter_test.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/domain/entities/contact.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/domain/repositories/contact_repository.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/domain/repositories/contacts_connection_exception.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/domain/usecases/get_contacts.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/presentation/cubit/contacts_cubit.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/presentation/cubit/contacts_state.dart';

const _contact = Contact(
  id: 1,
  name: 'Camila Reyes',
  role: 'Product Designer',
  department: 'Diseño',
  email: 'camila.reyes@empresa.cl',
  phone: '+56 9 1111 2222',
  active: true,
);

class _FakeRepository implements ContactRepository {
  _FakeRepository(this.results);

  /// Each call consumes one result: a list to return or an object to throw.
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

void main() {
  test('starts in the loading state', () {
    expect(_cubit([]).state, const ContactsLoading());
  });

  test('load emits data when there are contacts', () async {
    final cubit = _cubit([
      [_contact],
    ]);
    final states = expectLater(
      cubit.stream,
      emitsInOrder([
        const ContactsData([_contact]),
        emitsDone,
      ]),
    );

    await cubit.load();
    await cubit.close();
    await states;
  });

  test('load emits empty when the list is empty', () async {
    final cubit = _cubit([<Contact>[]]);
    final states = expectLater(
      cubit.stream,
      emitsInOrder([const ContactsEmpty(), emitsDone]),
    );

    await cubit.load();
    await cubit.close();
    await states;
  });

  test('load emits error with the cause when the use case throws', () async {
    final cubit = _cubit([const FormatException('bad data')]);

    await cubit.load();

    expect(cubit.state, isA<ContactsError>());
    expect((cubit.state as ContactsError).message, contains('bad data'));
  });

  test('a broken connection is an error, not an empty list', () async {
    final cubit = _cubit([const ContactsConnectionException()]);

    await cubit.load();

    expect(cubit.state, isA<ContactsError>());
    expect(
      (cubit.state as ContactsError).message,
      contains('Check your connection'),
    );
  });

  test('load again after an error emits loading and then the result', () async {
    final cubit = _cubit([
      const FormatException('bad data'),
      [_contact],
    ]);
    await cubit.load();

    final states = expectLater(
      cubit.stream,
      emitsInOrder([
        const ContactsLoading(),
        const ContactsData([_contact]),
        emitsDone,
      ]),
    );
    await cubit.load();
    await cubit.close();
    await states;
  });

  test('does not emit after the cubit is closed', () async {
    final cubit = _cubit([
      [_contact],
    ]);
    final pending = cubit.load();
    await cubit.close();

    await pending;

    expect(cubit.state, const ContactsLoading());
  });

  test('states compare by value', () {
    expect(const ContactsData([_contact]), const ContactsData([_contact]));
    expect(const ContactsError('x'), const ContactsError('x'));
    expect(const ContactsError('x'), isNot(const ContactsError('y')));
    expect(const ContactsEmpty(), const ContactsEmpty());
  });
}
