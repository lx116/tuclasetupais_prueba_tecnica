import 'package:flutter_test/flutter_test.dart';
import 'package:tuclasetupais_prueba_tecnica/core/contacts/domain/entities/contact.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/domain/repositories/contact_repository.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/domain/repositories/contacts_connection_exception.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/domain/usecases/filter_contacts_by_department.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/domain/usecases/get_contacts.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/domain/usecases/search_contacts.dart';
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

ContactsCubit _cubit(List<Object> results) => ContactsCubit(
  GetContacts(_FakeRepository(results)),
  const SearchContacts(),
  const FilterContactsByDepartment(),
);

extension on Contact {
  Contact copyOf({required int id, required String name, String? department}) =>
      Contact(
        id: id,
        name: name,
        role: role,
        department: department ?? this.department,
        email: email,
        phone: phone,
        active: active,
      );
}

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
      contains('Revisa tu conexión'),
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

  group('search', () {
    final ana = _contact.copyOf(id: 1, name: 'Ana Pérez');
    final bruno = _contact.copyOf(id: 2, name: 'Bruno Díaz');

    test(
      'filters the loaded contacts without calling the source again',
      () async {
        final cubit = _cubit([
          [ana, bruno],
        ]);
        await cubit.load();

        cubit.search('ana');

        expect(cubit.state, ContactsData([ana], query: 'ana'));
      },
    );

    test('an empty query shows every contact again', () async {
      final cubit = _cubit([
        [ana, bruno],
      ]);
      await cubit.load();
      cubit.search('ana');

      cubit.search('');

      expect(cubit.state, ContactsData([ana, bruno]));
    });

    test('a query with no match is no results, not empty or error', () async {
      final cubit = _cubit([
        [ana, bruno],
      ]);
      await cubit.load();

      cubit.search('zzz');

      expect(cubit.state, const ContactsNoResults(query: 'zzz'));
    });

    test(
      'a query set before the load is applied when the data arrives',
      () async {
        final cubit = _cubit([
          [ana, bruno],
        ]);

        cubit.search('bruno');
        expect(cubit.state, const ContactsLoading());
        await cubit.load();

        expect(cubit.state, ContactsData([bruno], query: 'bruno'));
      },
    );

    test('reloading keeps the query', () async {
      final cubit = _cubit([
        [ana, bruno],
        [ana, bruno],
      ]);
      await cubit.load();
      cubit.search('ana');

      await cubit.load();

      expect(cubit.state, ContactsData([ana], query: 'ana'));
    });

    test('searching an empty source stays empty', () async {
      final cubit = _cubit([<Contact>[]]);
      await cubit.load();

      cubit.search('ana');

      expect(cubit.state, const ContactsEmpty());
    });

    test('searching does not hide a load error', () async {
      final cubit = _cubit([const ContactsConnectionException()]);
      await cubit.load();

      cubit.search('ana');

      expect(cubit.state, isA<ContactsError>());
    });

    test('the same query does not emit again', () async {
      final cubit = _cubit([
        [ana, bruno],
      ]);
      await cubit.load();
      cubit.search('ana');
      final emitted = <ContactsState>[];
      final subscription = cubit.stream.listen(emitted.add);

      cubit.search('ana');
      await Future<void>.delayed(Duration.zero);
      await subscription.cancel();

      expect(emitted, isEmpty);
    });
  });

  group('department filter', () {
    final ana = _contact.copyOf(id: 1, name: 'Ana Pérez', department: 'Diseño');
    final bruno = _contact.copyOf(
      id: 2,
      name: 'Bruno Díaz',
      department: 'Ingeniería',
    );
    final anita = _contact.copyOf(
      id: 3,
      name: 'Anita Gómez',
      department: 'Ingeniería',
    );

    ContactsCubit loaded() => _cubit([
      [ana, bruno, anita],
      [ana, bruno, anita],
    ]);

    test(
      'keeps only that department without calling the source again',
      () async {
        final cubit = loaded();
        await cubit.load();

        cubit.filterByDepartment('ingenieria');

        expect(
          cubit.state,
          ContactsData([bruno, anita], department: 'ingenieria'),
        );
      },
    );

    test('an empty department shows every contact again', () async {
      final cubit = loaded();
      await cubit.load();
      cubit.filterByDepartment('ingenieria');

      cubit.filterByDepartment('');

      expect(cubit.state, ContactsData([ana, bruno, anita]));
    });

    test('combines with the search: both must match', () async {
      final cubit = loaded();
      await cubit.load();

      cubit.filterByDepartment('ingenieria');
      cubit.search('an');

      expect(
        cubit.state,
        ContactsData([anita], query: 'an', department: 'ingenieria'),
      );
    });

    test(
      'no match for the combination is no results with both values',
      () async {
        final cubit = loaded();
        await cubit.load();
        cubit.filterByDepartment('diseno');

        cubit.search('bruno');

        expect(
          cubit.state,
          const ContactsNoResults(query: 'bruno', department: 'diseno'),
        );
      },
    );

    test('an unknown department is no results', () async {
      final cubit = loaded();
      await cubit.load();

      cubit.filterByDepartment('marketing');

      expect(cubit.state, const ContactsNoResults(department: 'marketing'));
    });

    test(
      'a department set before the load is applied when data arrives',
      () async {
        final cubit = loaded();

        cubit.filterByDepartment('diseno');
        expect(cubit.state, const ContactsLoading());
        await cubit.load();

        expect(cubit.state, ContactsData([ana], department: 'diseno'));
      },
    );

    test('reloading keeps the department', () async {
      final cubit = loaded();
      await cubit.load();
      cubit.filterByDepartment('diseno');

      await cubit.load();

      expect(cubit.state, ContactsData([ana], department: 'diseno'));
    });

    test('the same department does not emit again', () async {
      final cubit = loaded();
      await cubit.load();
      cubit.filterByDepartment('diseno');
      final emitted = <ContactsState>[];
      final subscription = cubit.stream.listen(emitted.add);

      cubit.filterByDepartment('diseno');
      await Future<void>.delayed(Duration.zero);
      await subscription.cancel();

      expect(emitted, isEmpty);
    });
  });

  test('states compare by value', () {
    expect(const ContactsData([_contact]), const ContactsData([_contact]));
    expect(const ContactsError('x'), const ContactsError('x'));
    expect(const ContactsError('x'), isNot(const ContactsError('y')));
    expect(const ContactsEmpty(), const ContactsEmpty());
  });
}
